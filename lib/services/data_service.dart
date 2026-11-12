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

  static Future<void> clearAppData() async {
    final directory = await getApplicationDocumentsDirectory();
    await for (final entity in directory.list()) {
      if (entity is! File) continue;

      final name = entity.uri.pathSegments.last.toLowerCase();
      if (name.endsWith('.json') || name == _whitelistFile) {
        await entity.delete();
      }
    }
  }

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
      final files = (await directory.list().toList())
          .where(
            (f) =>
                f is File &&
                f.uri.pathSegments.last.toLowerCase().startsWith(
                  prefix.toLowerCase(),
                ) &&
                f.path.toLowerCase().endsWith('.json'),
          )
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
          final parsedUsers = await compute(parseUsersJson, content);
          usersMap.addAll(parsedUsers);
          totalUsersParsed += parsedUsers.length;
        } catch (e) {
          debugPrint('   -> Errore parsing file ${file.path}: $e');
        }
      }
      debugPrint(
        '✅ TOTALE $label: $filesFound file, ${usersMap.length} utenti unici (parsati: $totalUsersParsed)',
      );
    } catch (e) {
      debugPrint('Errore durante caricamento $label: $e');
    }

    return usersMap;
  }

  @visibleForTesting
  static Map<String, InstagramUser> parseUsersJson(String content) {
    final users = <String, InstagramUser>{};
    final entries = _extractUserEntries(json.decode(content));
    for (final entry in entries) {
      try {
        final user = InstagramUser.fromJson(entry);
        if (user.username.isNotEmpty) users[user.username] = user;
      } catch (_) {
        // A malformed entry must not discard valid profiles from the file.
      }
    }
    return users;
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
        await savedFile.writeAsBytes(await file.readAsBytes());

        debugPrint('📥 File \'${file.name}\' salvato/aggiornato con successo.');
      } catch (e) {
        debugPrint('❌ Errore salvataggio \'${file.name}\': $e');
      }
    }
  }

  static Future<void> saveInstagramArchive(PlatformFile archiveFile) async {
    final Uint8List bytes = await archiveFile.readAsBytes();
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
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle:
          'Seleziona file JSON di Instagram (followers_*.json, following_*.json)',
    );

    return files.isEmpty ? null : files;
  }

  static Future<PlatformFile?> pickInstagramArchive() async {
    return FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      dialogTitle: 'Seleziona l’archivio ZIP di Instagram',
    );
  }

  @visibleForTesting
  static Map<String, List<int>> decodeInstagramArchive(List<int> bytes) =>
      _decodeInstagramArchive(bytes);

  // Count JSON files with given prefix
  static Future<int> countFilesWithPrefix(String prefix) async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      final files = (await directory.list().toList())
          .where(
            (f) =>
                f is File &&
                f.uri.pathSegments.last.toLowerCase().startsWith(
                  prefix.toLowerCase(),
                ) &&
                f.path.toLowerCase().endsWith('.json'),
          )
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
    return following.values
        .where((user) =>
            !followers.containsKey(user.username) &&
            !whitelist.contains(user.username))
        .toList();
  }

  // Get summary stats
  static Map<String, int> getStats(
    Map<String, InstagramUser> followers,
    Map<String, InstagramUser> following,
    Set<String> whitelist,
  ) {
    var notFollowingBack = 0;
    var visibleCount = 0;
    for (final username in following.keys) {
      if (followers.containsKey(username)) continue;
      notFollowingBack++;
      if (!whitelist.contains(username)) visibleCount++;
    }

    return {
      'following': following.length,
      'followers': followers.length,
      'whitelist': whitelist.length,
      'notFollowingBackTotal': notFollowingBack,
      'visibleCount': visibleCount,
    };
  }
}
