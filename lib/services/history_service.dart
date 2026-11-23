import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_strings.dart';
import '../models/import_snapshot.dart';
import '../models/user.dart';
import '../models/username_change.dart';
import 'data_service.dart';

class DuplicateFollowerFileException implements Exception {
  const DuplicateFollowerFileException(this.name);

  final String name;
}

class HistoryService {
  static const fileName = 'import_history.json';
  static Future<void> _pendingWrite = Future.value();

  /// Serialize imports and whitelist edits so rapid taps cannot lose a write.
  static Future<void> write(Future<void> Function() action) {
    final result = _pendingWrite.then((_) => action());
    _pendingWrite = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  static Future<List<ImportSnapshot>> load({String? path}) async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    final file = File('$path/$fileName');
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return compute(_decode, content);
  }

  static List<ImportSnapshot> _decode(String content) =>
      (jsonDecode(content)['snapshots'] as List)
          .map((item) => ImportSnapshot.fromJson(item as Map<String, dynamic>))
          .toList();

  static Future<List<ImportFileEntry>> listImportedFiles({String? path}) async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    final state = File('$path/$fileName');
    if (!await state.exists()) return const [];
    return compute(_fileEntries, await state.readAsString());
  }

  static List<ImportFileEntry> _fileEntries(String content) {
    final snapshots = jsonDecode(content)['snapshots'] as List;
    return [
      for (var i = snapshots.length - 1; i >= 0; i--)
        if (snapshots[i]['files'] case final List files)
          for (var j = 0; j < files.length; j++) _fileEntry(snapshots[i], i, j)
        else
          _fileEntry(snapshots[i], i, null),
    ];
  }

  static ImportFileEntry _fileEntry(Map snapshot, int index, int? fileIndex) {
    final file = fileIndex == null
        ? null
        : (snapshot['files'] as List)[fileIndex] as Map;
    return (
      snapshotIndex: index,
      fileIndex: fileIndex,
      date: DateTime.parse(snapshot['date'] as String),
      name: file?['name'] as String?,
      fingerprint: file?['fingerprint'] as String?,
    );
  }

  static Future<void> removeImportedFile(
    ImportFileEntry entry, {
    String? path,
  }) => write(() async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    final state = File('$path/$fileName');
    final content = await state.readAsString();
    final rebuilt = await compute(_removeFromHistory, (content, entry));
    await _save(state, rebuilt);
  });

  static (List<ImportSnapshot>, Set<String>, Set<String>) _removeFromHistory(
    (String, ImportFileEntry) request,
  ) {
    final (content, entry) = request;
    final state = jsonDecode(content) as Map<String, dynamic>;
    final raw = state['snapshots'] as List;
    final target = raw[entry.snapshotIndex] as Map<String, dynamic>;
    if (_fileEntry(target, entry.snapshotIndex, entry.fileIndex) != entry) {
      throw StateError('Import history changed');
    }
    final rebuilt = <ImportSnapshot>[];
    ImportSnapshot? originalPrevious;
    for (var index = 0; index < raw.length; index++) {
      final json = raw[index] as Map<String, dynamic>;
      final original = ImportSnapshot.fromJson(json);
      final files = original.files?.toList();
      final isTarget = index == entry.snapshotIndex;
      if (isTarget && entry.fileIndex != null) {
        files!.removeAt(entry.fileIndex!);
      }
      if (!(isTarget && entry.fileIndex == null) &&
          (files == null || files.isNotEmpty)) {
        final previous = rebuilt.lastOrNull;
        final followers = <String, InstagramUser>{};
        final following = <String, InstagramUser>{};
        var hasFollowers = false;
        var hasFollowing = false;
        if (files != null) {
          for (final file in files) {
            (file.isFollowers ? followers : following).addAll(file.users);
            hasFollowers |= file.isFollowers;
            hasFollowing |= !file.isFollowers;
          }
        } else {
          hasFollowers = original.followersImported;
          hasFollowing =
              original.followingImported ||
              (original.hasFollowing &&
                  !(originalPrevious?.hasFollowing ?? false)) ||
              (!json.containsKey('followingImported') &&
                  original.hasFollowing &&
                  !_sameUsers(
                    original.following,
                    originalPrevious?.following ?? const {},
                  ));
          if (hasFollowers) followers.addAll(original.followers);
          if (hasFollowing) following.addAll(original.following);
        }

        if (hasFollowers || hasFollowing) {
          final changes = <String, String>{
            if (hasFollowers && previous != null)
              for (final change in original.usernameChanges.entries)
                if (!followers.containsKey(change.key) &&
                    !previous.followers.containsKey(change.value) &&
                    _sameFollowTime(
                      previous.followers[change.key],
                      followers[change.value],
                    ))
                  change.key: change.value,
          };
          final nextFollowing = hasFollowing
              ? following
              : {...?previous?.following};
          _applyUsernameChanges(nextFollowing, changes);
          rebuilt.add(
            ImportSnapshot(
              date: original.date,
              estimatedDate: original.estimatedDate,
              followersImported: hasFollowers,
              followingImported: hasFollowing,
              hasFollowers: hasFollowers || (previous?.hasFollowers ?? false),
              hasFollowing: hasFollowing || (previous?.hasFollowing ?? false),
              followers: hasFollowers
                  ? followers
                  : previous?.followers ?? const {},
              following: nextFollowing,
              usernameChanges: changes,
              files: files,
            ),
          );
        }
      }
      originalPrevious = original;
    }
    return (
      rebuilt,
      Set<String>.from(state['whitelist'] as List),
      Set<String>.from(state['automaticWhitelist'] as List? ?? []),
    );
  }

  static bool _sameFollowTime(
    InstagramUser? previous,
    InstagramUser? current,
  ) =>
      previous != null &&
      previous.timestamp > 0 &&
      previous.timestamp == current?.timestamp;

  static void _applyUsernameChanges(
    Map<String, InstagramUser> following,
    Map<String, String> changes,
  ) {
    for (final entry in changes.entries) {
      final old = following.remove(entry.key);
      if (old != null) {
        following.putIfAbsent(
          entry.value,
          () => InstagramUser(username: entry.value, timestamp: old.timestamp),
        );
      }
    }
  }

  static Future<List<UnfollowInterval>> loadTimeline({String? path}) async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    return compute(_readTimeline, path);
  }

  static List<UnfollowInterval> _readTimeline(String path) {
    final file = File('$path/$fileName');
    if (!file.existsSync()) return const [];

    final intervals = <UnfollowInterval>[];
    ImportSnapshot? previous;
    final snapshots = jsonDecode(file.readAsStringSync())['snapshots'] as List;
    for (final entry in snapshots) {
      final data = entry as Map<String, dynamic>;
      if (!(data['followersImported'] as bool)) continue;
      final current = ImportSnapshot.fromJson(data, includeFiles: false);
      if (previous != null) intervals.add(UnfollowInterval(previous, current));
      previous = current;
    }
    return intervals.reversed.toList(growable: false);
  }

  /// Validation finishes before touching saved data. The atomic state includes
  /// the old profiles, the new profiles and the updated whitelist together.
  static Future<void> importFiles(
    Map<String, List<int>> files, {
    required DateTime date,
    bool autoWhitelistOnImport = true,
    String? path,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) => write(
    () => _importFiles(
      files,
      date: date,
      autoWhitelistOnImport: autoWhitelistOnImport,
      path: path,
      resolveUsernameChanges: resolveUsernameChanges,
    ),
  );

  static Future<void> _importFiles(
    Map<String, List<int>> files, {
    required DateTime date,
    required bool autoWhitelistOnImport,
    String? path,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    final state = File('$path/$fileName');
    final followers = <String, InstagramUser>{};
    final following = <String, InstagramUser>{};
    final imported = <ImportedExportFile>[];
    var hasFollowers = false;
    var hasFollowing = false;
    for (final entry in files.entries) {
      final filename = entry.key.split(RegExp(r'[/\\]')).last;
      final name = filename.toLowerCase();
      if (!name.endsWith('.json')) continue;
      final isFollowers = name.startsWith('followers');
      final isFollowing = name.startsWith('following');
      if (!isFollowers && !isFollowing) continue;
      final file = await compute(_parseFile, (
        filename,
        entry.value,
        AppStrings.current.localeName,
        isFollowers,
      ));
      imported.add(file);
      (isFollowers ? followers : following).addAll(file.users);
      hasFollowers |= isFollowers;
      hasFollowing |= isFollowing;
    }
    if (!hasFollowers && !hasFollowing) {
      throw FormatException(AppStrings.current.selectValidFiles);
    }

    final history = await load(path: path);
    if (history.isEmpty && !await state.exists()) {
      final legacy = await compute(DataService.loadAppDataFromDirectory, (
        path,
        SortOption.dateDesc,
        null,
      ));
      if (legacy.hasFollowersFile || legacy.hasFollowingFile) {
        DateTime? modified;
        for (final file in Directory(path).listSync().whereType<File>()) {
          final name = file.uri.pathSegments.last.toLowerCase();
          if (name.startsWith(
                legacy.hasFollowersFile ? 'followers' : 'following',
              ) &&
              name.endsWith('.json')) {
            final value = file.lastModifiedSync();
            if (modified == null || value.isAfter(modified)) modified = value;
          }
        }
        history.add(
          ImportSnapshot(
            date: modified ?? DateTime.now(),
            estimatedDate: true,
            followersImported: legacy.hasFollowersFile,
            followingImported: legacy.hasFollowingFile,
            hasFollowers: legacy.hasFollowersFile,
            hasFollowing: legacy.hasFollowingFile,
            followers: legacy.followers,
            following: legacy.following,
          ),
        );
      }
    }
    _checkDuplicateFollowers(imported, history);
    final previous = history.lastOrNull;
    // Dates must move forward; reimporting the same day is permitted.
    if (previous != null && _day(date).isBefore(_day(previous.date))) {
      throw FormatException(AppStrings.current.chronologicalImportError);
    }
    final changes = <String, String>{};
    if (hasFollowers && previous != null && previous.hasFollowers) {
      final candidates = UsernameChangeCandidate.find(
        previous.followers,
        followers,
      );
      if (candidates.isNotEmpty && resolveUsernameChanges != null) {
        final selected = await resolveUsernameChanges(
          List.unmodifiable(candidates),
        );
        if (selected == null) return; // Cancel without changing saved data.
        final allowed = {
          for (final candidate in candidates)
            candidate.previous.username: candidate.possibleMatches
                .map((u) => u.username)
                .toSet(),
        };
        for (final entry in selected.entries) {
          if (!(allowed[entry.key]?.contains(entry.value) ?? false) ||
              changes.containsValue(entry.value)) {
            throw FormatException(AppStrings.current.invalidProfileMatch);
          }
          changes[entry.key] = entry.value;
        }
      }
    }
    final nextFollowing = Map<String, InstagramUser>.of(
      hasFollowing ? following : previous?.following ?? {},
    );
    _applyUsernameChanges(nextFollowing, changes);
    final next = ImportSnapshot(
      date: date,
      followersImported: hasFollowers,
      followingImported: hasFollowing,
      hasFollowers: hasFollowers || (previous?.hasFollowers ?? false),
      hasFollowing: hasFollowing || (previous?.hasFollowing ?? false),
      followers: hasFollowers ? followers : previous?.followers ?? {},
      following: nextFollowing,
      usernameChanges: changes,
      files: imported,
    );
    final whitelistFile = File('$path/whitelist.txt');
    final saved = await state.exists()
        ? jsonDecode(await state.readAsString()) as Map<String, dynamic>
        : null;
    final whitelist = saved != null
        ? Set<String>.from(saved['whitelist'] as List)
        : await whitelistFile.exists()
        ? (await whitelistFile.readAsLines())
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toSet()
        : <String>{};
    final automatic = Set<String>.from(
      saved?['automaticWhitelist'] as List? ?? [],
    ).intersection(whitelist);
    if (hasFollowers && previous != null && previous.hasFollowers) {
      for (final entry in changes.entries) {
        if (!whitelist.remove(entry.key)) continue;
        if (!automatic.remove(entry.key)) {
          automatic.remove(entry.value);
        } else if (!whitelist.contains(entry.value)) {
          automatic.add(entry.value);
        }
        whitelist.add(entry.value);
      }
      // Following back ends an automatic exclusion. Explicit and legacy
      // whitelist entries stay in place.
      final followingBack = automatic.where(followers.containsKey).toSet();
      automatic.removeAll(followingBack);
      whitelist.removeAll(followingBack);
      if (autoWhitelistOnImport) {
        final candidates = next.following.keys
            .where(
              (name) =>
                  previous.following.containsKey(name) &&
                  !followers.containsKey(name) &&
                  !whitelist.contains(name),
            )
            .toSet();
        // A detected unfollow stays in the report on later imports too.
        for (final snapshot in history.reversed) {
          if (candidates.isEmpty) break;
          candidates.removeWhere(snapshot.followers.containsKey);
        }
        automatic.addAll(candidates);
        whitelist.addAll(candidates);
      }
    }
    history.add(next);
    await _save(state, (history, whitelist, automatic));
  }

  static Future<void> _save(
    File state,
    (List<ImportSnapshot>, Set<String>, Set<String>) data,
  ) async {
    final pending = File('${state.path}.tmp');
    await pending.writeAsString(await compute(_encode, data), flush: true);
    // The state is authoritative; legacy raw JSONs remain untouched.
    await pending.rename(state.path);
  }

  static ImportedExportFile _parseFile(
    (String, List<int>, String, bool) input,
  ) {
    final (name, bytes, language, isFollowers) = input;
    return ImportedExportFile(
      name,
      sha256.convert(bytes).toString(),
      isFollowers,
      _validateProfiles((name, bytes, language)),
    );
  }

  static void _checkDuplicateFollowers(
    List<ImportedExportFile> files,
    List<ImportSnapshot> history,
  ) {
    final known = {
      for (final snapshot in history)
        for (final file in snapshot.files ?? const <ImportedExportFile>[])
          if (file.isFollowers) file.fingerprint,
    };
    final followersFiles = files.where((file) => file.isFollowers).toList();
    for (final file in followersFiles) {
      if (!known.add(file.fingerprint)) {
        throw DuplicateFollowerFileException(file.name);
      }
    }
    // Older versions only kept merged profiles, so compare their full list
    // when the new selection contains a single followers file.
    if (followersFiles.length == 1) {
      final file = followersFiles.single;
      if (history.any(
        (snapshot) =>
            snapshot.files == null &&
            snapshot.followersImported &&
            _sameUsers(snapshot.followers, file.users),
      )) {
        throw DuplicateFollowerFileException(file.name);
      }
    }
  }

  static bool _sameUsers(
    Map<String, InstagramUser> a,
    Map<String, InstagramUser> b,
  ) =>
      a.length == b.length &&
      a.entries.every(
        (entry) => b[entry.key]?.timestamp == entry.value.timestamp,
      );

  static String _encode(
    (List<ImportSnapshot>, Set<String>, Set<String>) data,
  ) => jsonEncode({
    'snapshots': data.$1.map((s) => s.toJson()).toList(),
    'whitelist': data.$2.toList(),
    'automaticWhitelist': data.$3.toList(),
  });

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static Map<String, InstagramUser> _validateProfiles(
    (String, List<int>, String) input,
  ) {
    final (name, bytes, language) = input;
    AppStrings.useLanguage(language);
    final content = utf8.decode(bytes);
    final root = jsonDecode(content);
    if (root is! List && root is! Map<String, dynamic>) {
      throw FormatException(
        AppStrings.current.invalidInstagramFormat((name).toString()),
      );
    }
    final users = DataService.parseUsersJson(content);
    // Empty Instagram lists are valid; populated unrecognizable data is not.
    final entries = root is List
        ? root
        : (root as Map).values.expand((v) => v is List ? v : [v]).toList();
    if (entries.isNotEmpty && users.isEmpty) {
      throw FormatException(
        AppStrings.current.unrecognizedProfiles((name).toString()),
      );
    }
    return users;
  }
}
