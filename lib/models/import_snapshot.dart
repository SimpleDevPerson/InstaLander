import 'user.dart';

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
    Map<String, String> usernameChanges = const {},
  }) : followers = Map.unmodifiable(followers),
       usernameChanges = Map.unmodifiable(usernameChanges),
       following = Map.unmodifiable(following);

  final DateTime date;
  final bool followersImported;
  final bool followingImported;
  final bool hasFollowers;
  final bool hasFollowing;
  final bool estimatedDate;
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
    'followers': followers.values.map((u) => u.toJson()).toList(),
    'following': following.values.map((u) => u.toJson()).toList(),
  };

  factory ImportSnapshot.fromJson(Map<String, dynamic> json) {
    Map<String, InstagramUser> users(String key) => {
      for (final item in json[key] as List)
        item['username'] as String: InstagramUser(
          username: item['username'] as String,
          timestamp: item['timestamp'] as int,
        ),
    };
    return ImportSnapshot(
      date: DateTime.parse(json['date'] as String),
      followersImported: json['followersImported'] as bool,
      followingImported: json['followingImported'] as bool? ?? false,
      hasFollowers: json['hasFollowers'] as bool,
      hasFollowing: json['hasFollowing'] as bool,
      estimatedDate: json['estimatedDate'] as bool? ?? false,
      usernameChanges: Map<String, String>.from(
        json['usernameChanges'] as Map? ?? {},
      ),
      followers: users('followers'),
      following: users('following'),
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
  final bool estimatedDate;
  late final List<InstagramUser> users;
  late final List<TimelineProfile> profiles;
}
