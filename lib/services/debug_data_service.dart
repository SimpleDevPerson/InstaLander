import 'dart:math';

import '../models/import_snapshot.dart';
import '../models/user.dart';

class DebugDataService {
  DebugDataService({Random? random, DateTime? now})
    : _random = random ?? Random(),
      _now = now ?? DateTime.now();
  final Random _random;
  final DateTime _now;

  Map<String, InstagramUser> profiles(String section, int count) {
    final batch = _random.nextInt(1000000);
    return {
      for (var i = 0; i < count; i++)
        'debug_${section}_${batch}_$i': InstagramUser(
          username: 'debug_${section}_${batch}_$i',
          timestamp:
              _now
                  .subtract(
                    Duration(
                      days: 1 + _random.nextInt(365),
                      seconds: _random.nextInt(86400),
                    ),
                  )
                  .millisecondsSinceEpoch ~/
              1000,
        ),
    };
  }

  (Map<String, InstagramUser>, Map<String, InstagramUser>) report() {
    final following = profiles('report', 30 + _random.nextInt(31));
    final followers = Map<String, InstagramUser>.fromEntries(
      following.entries.take(following.length ~/ 2),
    );
    return (followers, following);
  }

  List<UnfollowInterval> timeline() {
    final users = profiles('timeline', 30);
    final snapshots = <ImportSnapshot>[];
    var remaining = Map<String, InstagramUser>.of(users);
    for (var i = 0; i < 5; i++) {
      if (i > 0) {
        final names = remaining.keys.toList()..shuffle(_random);
        for (final name in names.take(2 + _random.nextInt(4))) {
          remaining.remove(name);
        }
      }
      snapshots.add(
        ImportSnapshot(
          date: _now.subtract(Duration(days: (4 - i) * 30)),
          followersImported: true,
          hasFollowers: true,
          hasFollowing: true,
          followers: remaining,
          following: users,
        ),
      );
    }
    return [
      for (var i = snapshots.length - 1; i > 0; i--)
        UnfollowInterval(snapshots[i - 1], snapshots[i]),
    ];
  }
}
