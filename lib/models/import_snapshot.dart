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
    Map<String, String> usernameChanges = const {},
  }) : followers = Map.unmodifiable(followers),
       usernameChanges = Map.unmodifiable(usernameChanges),
       following = Map.unmodifiable(following);

  final DateTime date;
  final bool followersImported;
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

class UnfollowInterval {
  UnfollowInterval(this.previous, this.current)
    : users = List.unmodifiable(
        previous.followers.entries
            .where(
              (entry) => !current.followers.containsKey(
                current.usernameChanges[entry.key] ?? entry.key,
              ),
            )
            .map((entry) => entry.value),
      );

  final ImportSnapshot previous;
  final ImportSnapshot current;
  final List<InstagramUser> users;
}
