import 'user.dart';

typedef ResolveUsernameChanges =
    Future<Map<String, String>?> Function(
      List<UsernameChangeCandidate> candidates,
    );

class UsernameChangeCandidate {
  const UsernameChangeCandidate(this.previous, this.possibleMatches);

  final InstagramUser previous;
  final List<InstagramUser> possibleMatches;

  /// Only compare disappeared and newly appeared usernames with the same
  /// positive follow timestamp. A timestamp is a hint, never an identity ID.
  static List<UsernameChangeCandidate> find(
    Map<String, InstagramUser> previous,
    Map<String, InstagramUser> current,
  ) {
    final addedByTimestamp = <int, List<InstagramUser>>{};
    for (final user in current.values) {
      if (user.timestamp <= 0 || previous.containsKey(user.username)) continue;
      addedByTimestamp.putIfAbsent(user.timestamp, () => []).add(user);
    }
    return [
      for (final user in previous.values)
        if (!current.containsKey(user.username) &&
            user.timestamp > 0 &&
            addedByTimestamp.containsKey(user.timestamp))
          UsernameChangeCandidate(
            user,
            List.unmodifiable(addedByTimestamp[user.timestamp]!),
          ),
    ];
  }
}
