import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

Map<String, List<int>> _decodeInstagramArchive(List<int> bytes) {
  final files = <String, List<int>>{};
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final entry in archive) {
    if (!entry.isFile) continue;

    final name = entry.name.split(RegExp(r'[/\\]')).last.toLowerCase();
    if (!name.endsWith('.json') ||
        !(name.startsWith('followers') || name.startsWith('following'))) {
      continue;
    }

    if (files.containsKey(name)) {
      throw FormatException('Nome file duplicato nell’archivio: $name');
    }

    final content = entry.readBytes();
    if (content == null) {
      throw FormatException('Impossibile leggere il file $name nell’archivio');
    }
    files[name] = content;
  }

  if (files.isEmpty) {
    throw const FormatException(
      'Nell’archivio non sono stati trovati file followers*.json o following*.json',
    );
  }

  return files;
}

class DataService {
  static const String _whitelistFile = 'whitelist.txt';

  // Load users from JSON files matching pattern
  static Future<Map<String, InstagramUser>> loadUsersFromFiles({
    required String prefix,
    required String label,
  }) async {
    final Map<String, InstagramUser> usersMap = {};
    final directory = await getApplicationDocumentsDirectory();
    int filesFound = 0;
    int totalUsersParsed = 0;

    try {
      final files = directory
          .listSync()
          .where((f) =>
              f is File &&
              f.uri.pathSegments.last
                  .toLowerCase()
                  .startsWith(prefix.toLowerCase()) &&
              f.path.toLowerCase().endsWith('.json'))
          .cast<File>()
          .toList();

      filesFound = files.length;

      if (files.isEmpty) {
        debugPrint('❌ Nessun file trovato per: $prefix*.json');
        return usersMap;
      }

      for (final file in files) {
        debugPrint('Leggendo file: ${file.path}...');
        try {
          final content = await file.readAsString();
          final jsonData = json.decode(content);
          int countInFile = 0;

          // DEBUG: Print JSON structure
          if (jsonData is Map) {
            debugPrint(
                '   -> Chiavi JSON principali: ${jsonData.keys.toList()}');
            for (final entry in jsonData.entries) {
              debugPrint(
                  '   -> Chiave "${entry.key}": tipo=${entry.value.runtimeType}');
              if (entry.value is List) {
                debugPrint('      -> Lista di ${entry.value.length} elementi');
                if (entry.value.isNotEmpty) {
                  debugPrint('      -> Primo elemento: ${entry.value.first}');
                }
              } else if (entry.value is Map) {
                debugPrint(
                    '      -> Mappa con chiavi: ${(entry.value as Map).keys.toList()}');
              }
            }
          } else if (jsonData is List) {
            debugPrint('   -> Array diretto di ${jsonData.length} elementi');
            if (jsonData.isNotEmpty) {
              debugPrint('   -> Primo elemento: ${jsonData.first}');
            }
          }

          final itemsToProcess = _extractUserEntries(jsonData);

          debugPrint(
              '   -> Voci estratte per parsing: ${itemsToProcess.length}');

          for (final entry in itemsToProcess) {
            final user = InstagramUser.fromJson(entry);
            if (user.username.isNotEmpty) {
              usersMap[user.username] = user;
              countInFile++;
            } else {
              debugPrint('   -> Voce scartata (username vuoto): $entry');
            }
          }
          debugPrint('   -> Utenti validi: $countInFile');
          totalUsersParsed += countInFile;
        } catch (e) {
          debugPrint('   -> Errore parsing file ${file.path}: $e');
        }
      }
      debugPrint(
          '✅ TOTALE $label: $filesFound file, ${usersMap.length} utenti unici (parsati: $totalUsersParsed)');
    } catch (e) {
      debugPrint('Errore durante caricamento $label: $e');
    }

    return usersMap;
  }

  // Extract user entries from various Instagram JSON structures
  static List<dynamic> _extractUserEntries(dynamic jsonData) {
    final items = <dynamic>[];

    if (jsonData is List) {
      items.addAll(jsonData);
    } else if (jsonData is Map) {
      // Handle Instagram export formats:
      // 1. { "relationships_following": [...] }
      // 2. { "relationships_followers": [...] }
      // 3. { "following": [...], "followers": [...] }
      // 4. Direct arrays in values

      for (final entry in jsonData.entries) {
        final value = entry.value;
        if (value is List) {
          items.addAll(value);
        } else if (value is Map) {
          // Nested structure like { "string_list_data": [...] }
          for (final nestedValue in value.values) {
            if (nestedValue is List) {
              items.addAll(nestedValue);
            }
          }
        }
      }
    }

    return items;
  }

  // Save uploaded JSON files
  static Future<void> saveJsonFiles(List<PlatformFile> files) async {
    final directory = await getApplicationDocumentsDirectory();

    for (final file in files) {
      if (!file.name.toLowerCase().endsWith('.json')) continue;

      try {
        final savedFile = File('${directory.path}/${file.name}');

        if (file.bytes != null) {
          // Web or when withData: true is used
          await savedFile.writeAsBytes(file.bytes!);
        } else if (file.path != null) {
          // Android/iOS - read from the source path
          final sourceFile = File(file.path!);
          final bytes = await sourceFile.readAsBytes();
          await savedFile.writeAsBytes(bytes);
        } else {
          debugPrint(
              '⚠️ Impossibile salvare \'${file.name}\': né bytes né path disponibili');
          continue;
        }

        debugPrint('📥 File \'${file.name}\' salvato/aggiornato con successo.');
      } catch (e) {
        debugPrint('❌ Errore salvataggio \'${file.name}\': $e');
      }
    }
  }

  static Future<void> saveInstagramArchive(PlatformFile archiveFile) async {
    final Uint8List bytes;
    if (archiveFile.bytes != null) {
      bytes = archiveFile.bytes!;
    } else if (archiveFile.path != null) {
      bytes = await File(archiveFile.path!).readAsBytes();
    } else {
      throw const FormatException('Impossibile leggere l’archivio selezionato');
    }

    final extractedFiles = await compute(_decodeInstagramArchive, bytes);
    final directory = await getApplicationDocumentsDirectory();
    for (final entry in extractedFiles.entries) {
      await File('${directory.path}/${entry.key}').writeAsBytes(entry.value);
    }
  }

  // Load whitelist
  static Future<Set<String>> loadWhitelist() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_whitelistFile');
    final whitelist = <String>{};

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        for (final line in content.split('\n')) {
          final name = line.trim();
          if (name.isNotEmpty) {
            whitelist.add(name);
          }
        }
        debugPrint('✅ Caricati ${whitelist.length} profili dalla whitelist.');
      } catch (e) {
        debugPrint('❌ Errore lettura whitelist: $e');
      }
    }
    return whitelist;
  }

  // Save whitelist
  static Future<void> saveWhitelist(Set<String> whitelist) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_whitelistFile');

    try {
      final content = whitelist.map((u) => '$u\n').join();
      await file.writeAsString(content);
      debugPrint('✅ Whitelist salvata (${whitelist.length} utenti)');
    } catch (e) {
      debugPrint('❌ Errore salvataggio whitelist: $e');
    }
  }

  // Pick JSON files
  static Future<List<PlatformFile>?> pickJsonFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: true,
      dialogTitle:
          'Seleziona file JSON di Instagram (followers_*.json, following_*.json)',
      // withData: true would load file bytes into memory (useful for web)
      // On mobile, we read from path instead for better memory efficiency
    );

    if (result == null) {
      // User cancelled the picker
      return null;
    }

    if (result.files.isEmpty) {
      throw Exception('Nessun file selezionato');
    }

    return result.files;
  }

  static Future<PlatformFile?> pickInstagramArchive() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
      dialogTitle: 'Seleziona l’archivio ZIP di Instagram',
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.single;
  }

  @visibleForTesting
  static Map<String, List<int>> decodeInstagramArchive(List<int> bytes) =>
      _decodeInstagramArchive(bytes);

  // Count JSON files with given prefix
  static Future<int> countFilesWithPrefix(String prefix) async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      final files = directory
          .listSync()
          .where((f) =>
              f is File &&
              f.uri.pathSegments.last
                  .toLowerCase()
                  .startsWith(prefix.toLowerCase()) &&
              f.path.toLowerCase().endsWith('.json'))
          .cast<File>()
          .toList();
      return files.length;
    } catch (e) {
      return 0;
    }
  }

  // Compute non-followers
  static List<InstagramUser> computeNonFollowers(
    Map<String, InstagramUser> followers,
    Map<String, InstagramUser> following,
    Set<String> whitelist,
  ) {
    final followersSet = followers.keys.toSet();
    final followingSet = following.keys.toSet();

    final notFollowingBack = followingSet.difference(followersSet);
    final visibleUsers = notFollowingBack.difference(whitelist);

    return visibleUsers.map((username) => following[username]!).toList();
  }

  // Get summary stats
  static Map<String, int> getStats(
    Map<String, InstagramUser> followers,
    Map<String, InstagramUser> following,
    Set<String> whitelist,
  ) {
    final followersSet = followers.keys.toSet();
    final followingSet = following.keys.toSet();
    final notFollowingBack = followingSet.difference(followersSet);
    final visibleCount = notFollowingBack.difference(whitelist).length;

    return {
      'following': followingSet.length,
      'followers': followersSet.length,
      'whitelist': whitelist.length,
      'notFollowingBackTotal': notFollowingBack.length,
      'visibleCount': visibleCount,
    };
  }
}
