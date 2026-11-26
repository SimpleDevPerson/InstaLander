import 'user.dart';

enum ArchiveImportMode { all, followersOnly, restart }

class ImportedExportFile {
  const ImportedExportFile(
    this.name,
    this.fingerprint,
    this.isFollowers,
    this.users,
  );

  final String name;
  final String fingerprint;
  final bool isFollowers;
  final Map<String, InstagramUser> users;

  Map<String, dynamic> toJson({required bool includeUsers}) => {
    'name': name,
    'fingerprint': fingerprint,
    'isFollowers': isFollowers,
    if (includeUsers)
      'users': users.values.map((user) => user.toJson()).toList(),
  };

  factory ImportedExportFile.fromJson(
    Map<String, dynamic> json,
    Map<String, InstagramUser> fallbackUsers,
  ) => ImportedExportFile(
    json['name'] as String,
    json['fingerprint'] as String,
    json['isFollowers'] as bool,
    switch (json['users']) {
      final List users => _decodeUsers(users),
      _ => fallbackUsers,
    },
  );
}

typedef ImportFileEntry = ({
  int snapshotIndex,
  int? fileIndex,
  DateTime date,
  String? name,
  String? fingerprint,
});

Map<String, InstagramUser> _decodeUsers(List users) => {
  for (final item in users)
    item['username'] as String: InstagramUser(
      username: item['username'] as String,
      timestamp: item['timestamp'] as int,
    ),
};

/// A complete, immutable copy of the profiles at an import boundary.
class ImportSnapshot {
  ImportSnapshot({
    required this.date,
    required this.followersImported,
    required this.hasFollowers,
    required this.hasFollowing,
    required Map<String, InstagramUser> followers,
    required Map<String, InstagramUser> following,
    this.estimatedDate = false,
    this.followingImported = false,
    List<ImportedExportFile>? files,
    Map<String, String> usernameChanges = const {},
  }) : followers = Map.unmodifiable(followers),
       usernameChanges = Map.unmodifiable(usernameChanges),
       following = Map.unmodifiable(following),
       files = files == null ? null : List.unmodifiable(files);

  final DateTime date;
  final bool followersImported;
  final bool followingImported;
  final bool hasFollowers;
  final bool hasFollowing;
  final bool estimatedDate;

  /// Null for snapshots made before individual files were recorded.
  final List<ImportedExportFile>? files;
  final Map<String, InstagramUser> followers;
  final Map<String, InstagramUser> following;

  /// User-confirmed old -> new usernames for this follower comparison only.
  final Map<String, String> usernameChanges;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'followersImported': followersImported,
    'followingImported': followingImported,
    'hasFollowers': hasFollowers,
    'hasFollowing': hasFollowing,
    'estimatedDate': estimatedDate,
    'usernameChanges': usernameChanges,
    if (files != null) 'files': _encodeFiles(files!),
    'followers': followers.values.map((u) => u.toJson()).toList(),
    'following': following.values.map((u) => u.toJson()).toList(),
  };

  List<Map<String, dynamic>> _encodeFiles(List<ImportedExportFile> sources) {
    final followersCount = sources.where((file) => file.isFollowers).length;
    final followingCount = sources.length - followersCount;
    // A single file already has its profile data in the snapshot, unless
    // the following list was rewritten by confirmed username changes.
    return [
      for (final file in sources)
        file.toJson(
          includeUsers: file.isFollowers
              ? followersCount > 1
              : followingCount > 1 || usernameChanges.isNotEmpty,
        ),
    ];
  }

  factory ImportSnapshot.fromJson(
    Map<String, dynamic> json, {
    bool includeFiles = true,
  }) {
    final followers = _decodeUsers(json['followers'] as List);
    final following = _decodeUsers(json['following'] as List);
    final rawFiles = includeFiles ? json['files'] as List? : null;
    return ImportSnapshot(
      date: DateTime.parse(json['date'] as String),
      followersImported: json['followersImported'] as bool,
      followingImported: json['followingImported'] as bool? ?? false,
      hasFollowers: json['hasFollowers'] as bool,
      hasFollowing: json['hasFollowing'] as bool,
      estimatedDate: json['estimatedDate'] as bool? ?? false,
      files: rawFiles == null
          ? null
          : [
              for (final file in rawFiles.cast<Map<String, dynamic>>())
                ImportedExportFile.fromJson(
                  file,
                  file['isFollowers'] as bool ? followers : following,
                ),
            ],
      usernameChanges: Map<String, String>.from(
        json['usernameChanges'] as Map? ?? {},
      ),
      followers: followers,
      following: following,
    );
  }
}

enum TimelineProfileKind { missing, renamed, possiblyDeleted }

class TimelineProfile {
  const TimelineProfile({
    required this.user,
    required this.kind,
    this.previousUsername,
  });

  final InstagramUser user;
  final TimelineProfileKind kind;
  final String? previousUsername;
}

class UnfollowInterval {
  UnfollowInterval(ImportSnapshot previous, ImportSnapshot current)
    : previousDate = previous.date,
      currentDate = current.date,
      previousFollowerCount = previous.followers.length,
      currentFollowerCount = current.followers.length,
      estimatedDate = previous.estimatedDate {
    final changes = <TimelineProfile>[];
    final missing = <InstagramUser>[];
    for (final user in previous.followers.values) {
      if (current.followers.containsKey(user.username)) continue;
      final renamed = current.followers[current.usernameChanges[user.username]];
      if (renamed != null) {
        changes.add(
          TimelineProfile(
            user: renamed,
            kind: TimelineProfileKind.renamed,
            previousUsername: user.username,
          ),
        );
        continue;
      }
      // A stale copy of following cannot corroborate a disappearance.
      final absentFromBoth =
          current.followingImported &&
          previous.following.containsKey(user.username) &&
          !current.following.containsKey(user.username);
      missing.add(user);
      changes.add(
        TimelineProfile(
          user: user,
          kind: absentFromBoth
              ? TimelineProfileKind.possiblyDeleted
              : TimelineProfileKind.missing,
        ),
      );
    }
    users = List.unmodifiable(missing);
    profiles = List.unmodifiable(changes);
  }

  final DateTime previousDate;
  final DateTime currentDate;
  final int previousFollowerCount;
  final int currentFollowerCount;
  int get newFollowerCount =>
      currentFollowerCount - previousFollowerCount + users.length;
  int get intermediateFollowerCount => previousFollowerCount + newFollowerCount;
  final bool estimatedDate;
  late final List<InstagramUser> users;
  late final List<TimelineProfile> profiles;
}
