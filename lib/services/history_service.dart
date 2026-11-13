import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/import_snapshot.dart';
import '../models/user.dart';
import '../models/username_change.dart';
import 'data_service.dart';

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

  /// Validation finishes before touching saved data. The atomic state includes
  /// the old profiles, the new profiles and the updated whitelist together.
  static Future<void> importFiles(
    Map<String, List<int>> files, {
    required DateTime date,
    String? path,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) => write(
    () => _importFiles(
      files,
      date: date,
      path: path,
      resolveUsernameChanges: resolveUsernameChanges,
    ),
  );

  static Future<void> _importFiles(
    Map<String, List<int>> files, {
    required DateTime date,
    String? path,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) async {
    path ??= (await getApplicationDocumentsDirectory()).path;
    final followers = <String, InstagramUser>{};
    final following = <String, InstagramUser>{};
    var hasFollowers = false;
    var hasFollowing = false;
    for (final entry in files.entries) {
      final name = entry.key.split(RegExp(r'[/\\]')).last.toLowerCase();
      if (!name.endsWith('.json')) continue;
      final isFollowers = name.startsWith('followers');
      final isFollowing = name.startsWith('following');
      if (!isFollowers && !isFollowing) continue;
      final users = await compute(_validateProfiles, (name, entry.value));
      (isFollowers ? followers : following).addAll(users);
      hasFollowers |= isFollowers;
      hasFollowing |= isFollowing;
    }
    if (!hasFollowers && !hasFollowing) {
      throw const FormatException(
        'Seleziona followers*.json o following*.json',
      );
    }

    final history = await load(path: path);
    if (history.isEmpty) {
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
            hasFollowers: legacy.hasFollowersFile,
            hasFollowing: legacy.hasFollowingFile,
            followers: legacy.followers,
            following: legacy.following,
          ),
        );
      }
    }
    final previous = history.lastOrNull;
    // Dates must move forward; reimporting the same day is permitted.
    if (previous != null && _day(date).isBefore(_day(previous.date))) {
      throw const FormatException(
        'La data deve essere uguale o successiva all’ultima importazione.',
      );
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
            throw const FormatException(
              'Associazione dei profili non valida o duplicata.',
            );
          }
          changes[entry.key] = entry.value;
        }
      }
    }
    final nextFollowing = Map<String, InstagramUser>.of(
      hasFollowing ? following : previous?.following ?? {},
    );
    for (final entry in changes.entries) {
      final old = nextFollowing.remove(entry.key);
      if (old != null) {
        nextFollowing.putIfAbsent(
          entry.value,
          () => InstagramUser(username: entry.value, timestamp: old.timestamp),
        );
      }
    }
    final next = ImportSnapshot(
      date: date,
      followersImported: hasFollowers,
      hasFollowers: hasFollowers || (previous?.hasFollowers ?? false),
      hasFollowing: hasFollowing || (previous?.hasFollowing ?? false),
      followers: hasFollowers ? followers : previous?.followers ?? {},
      following: nextFollowing,
      usernameChanges: changes,
    );
    final whitelistFile = File('$path/whitelist.txt');
    final state = File('$path/$fileName');
    final whitelist = await state.exists()
        ? Set<String>.from(
            jsonDecode(await state.readAsString())['whitelist'] as List,
          )
        : await whitelistFile.exists()
        ? (await whitelistFile.readAsLines())
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toSet()
        : <String>{};
    if (hasFollowers && previous != null && previous.hasFollowers) {
      for (final entry in changes.entries) {
        if (whitelist.remove(entry.key)) whitelist.add(entry.value);
      }
      final intersection = previous.followers.keys
          .map((name) => changes[name] ?? name)
          .toSet()
          .intersection(followers.keys.toSet());
      whitelist.addAll(
        next.following.keys.where((name) => !intersection.contains(name)),
      );
    }
    history.add(next);
    final pending = File('$path/$fileName.tmp');
    await pending.writeAsString(
      await compute(_encode, (history, whitelist)),
      flush: true,
    );
    // The state is authoritative; legacy raw JSONs remain untouched.
    await pending.rename(state.path);
  }

  static String _encode((List<ImportSnapshot>, Set<String>) data) =>
      jsonEncode({
        'snapshots': data.$1.map((s) => s.toJson()).toList(),
        'whitelist': data.$2.toList(),
      });

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static Map<String, InstagramUser> _validateProfiles(
    (String, List<int>) input,
  ) {
    final (name, bytes) = input;
    final content = utf8.decode(bytes);
    final root = jsonDecode(content);
    if (root is! List && root is! Map<String, dynamic>) {
      throw FormatException('Formato Instagram non valido: $name');
    }
    final users = DataService.parseUsersJson(content);
    // Empty Instagram lists are valid; populated unrecognizable data is not.
    final entries = root is List
        ? root
        : (root as Map).values.expand((v) => v is List ? v : [v]).toList();
    if (entries.isNotEmpty && users.isEmpty) {
      throw FormatException('Nessun profilo riconoscibile in $name');
    }
    return users;
  }
}
