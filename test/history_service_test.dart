import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/import_snapshot.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/models/username_change.dart';
import 'package:instalander/services/data_service.dart';
import 'package:instalander/services/history_service.dart';

List<int> profiles(List<String> names) => utf8.encode(
  jsonEncode([
    for (final name in names)
      {
        'string_list_data': [
          {'value': name, 'timestamp': 123},
        ],
      },
  ]),
);

void main() {
  late Directory directory;
  setUp(
    () async => directory = await Directory.systemTemp.createTemp(
      'instalander_history_',
    ),
  );
  tearDown(() async => directory.delete(recursive: true));

  AppDataSnapshot load() => DataService.loadAppDataFromDirectory((
    directory.path,
    SortOption.dateDesc,
    null,
  ));
  Future<void> import(
    Map<String, List<int>> files,
    int month, {
    ResolveUsernameChanges? resolve,
  }) => HistoryService.importFiles(
    files,
    date: DateTime(2026, month, 1),
    path: directory.path,
    resolveUsernameChanges: resolve,
  );

  test(
    'confirmed rename preserves continuity and does not whitelist a mutual follower',
    () async {
      await import({
        'followers.json': profiles(['old', 'kept']),
        'following.json': profiles(['old', 'never']),
      }, 1);
      var prompted = false;
      await import(
        {
          'followers.json': profiles(['new', 'kept']),
        },
        2,
        resolve: (candidates) async {
          prompted = true;
          expect(candidates.single.previous.username, 'old');
          expect(candidates.single.possibleMatches.single.username, 'new');
          return {'old': 'new'};
        },
      );
      expect(prompted, isTrue);
      final data = load();
      expect(data.history.first.followers.containsKey('old'), isTrue);
      expect(data.history.last.usernameChanges, {'old': 'new'});
      expect(data.following.keys, ['never', 'new']);
      expect(data.whitelist, {'never'});
      expect(
        UnfollowInterval(data.history.first, data.history.last).users,
        isEmpty,
      );
      final restored = await HistoryService.load(path: directory.path);
      expect(restored.last.usernameChanges, {'old': 'new'});
      await import({
        'followers.json': profiles(['kept']),
      }, 3);
      expect(
        UnfollowInterval(
          load().history[1],
          load().history[2],
        ).users.single.username,
        'new',
      );
    },
  );

  for (final enabled in [false, true]) {
    test('automatic whitelist follows import preference: $enabled', () async {
      await File('${directory.path}/whitelist.txt').writeAsString('manual\n');
      await import({
        'followers.json': profiles(['kept', 'lost']),
        'following.json': profiles(['kept', 'lost', 'never']),
      }, 1);
      await HistoryService.importFiles(
        {
          'followers.json': profiles(['kept']),
        },
        date: DateTime(2026, 2, 1),
        path: directory.path,
        autoWhitelistOnImport: enabled,
      );
      final data = load();
      expect(
        data.whitelist,
        enabled ? {'manual', 'lost', 'never'} : {'manual'},
      );
      expect(data.history.length, 2);
      expect(data.followers.keys, ['kept']);
      expect(
        DataService.computeNonFollowers(
          data.followers,
          data.following,
          data.whitelist,
        ).map((user) => user.username).toSet(),
        enabled ? isEmpty : {'lost', 'never'},
      );
    });
  }

  test('confirmed rename moves a manual whitelist entry', () async {
    await File('${directory.path}/whitelist.txt').writeAsString('old\n');
    await import({
      'followers.json': profiles(['old']),
      'following.json': profiles(['old']),
    }, 1);
    await import(
      {
        'followers.json': profiles(['new']),
        'following.json': profiles(['new']),
      },
      2,
      resolve: (_) async => {'old': 'new'},
    );
    expect(load().whitelist, {'new'});
    expect(load().following.keys, ['new']);
  });

  test(
    'cancel leaves saved data unchanged; ignored candidates remain unfollows',
    () async {
      await import({
        'followers.json': profiles(['old']),
      }, 1);
      final file = File('${directory.path}/${HistoryService.fileName}');
      final before = await file.readAsString();
      await import(
        {
          'followers.json': profiles(['new']),
        },
        2,
        resolve: (_) async => null,
      );
      expect(await file.readAsString(), before);
      await import(
        {
          'followers.json': profiles(['new']),
        },
        2,
        resolve: (_) async => {},
      );
      expect(load().history.last.usernameChanges, isEmpty);
      expect(
        UnfollowInterval(
          load().history.first,
          load().history.last,
        ).users.single.username,
        'old',
      );
    },
  );

  test(
    'ambiguous matches need one-to-one confirmation and invalid choices cannot commit',
    () async {
      await import({
        'followers.json': profiles(['old1', 'old2']),
      }, 1);
      final file = File('${directory.path}/${HistoryService.fileName}');
      final before = await file.readAsString();
      await expectLater(
        import(
          {
            'followers.json': profiles(['new1', 'new2']),
          },
          2,
          resolve: (candidates) async {
            expect(candidates, hasLength(2));
            expect(candidates.first.possibleMatches, hasLength(2));
            return {'old1': 'new1', 'old2': 'new1'};
          },
        ),
        throwsFormatException,
      );
      expect(await file.readAsString(), before);
      await expectLater(
        import(
          {
            'followers.json': profiles(['new1', 'new2']),
          },
          2,
          resolve: (_) async => {'old1': 'unrelated'},
        ),
        throwsFormatException,
      );
      expect(await file.readAsString(), before);
      await import(
        {
          'followers.json': profiles(['new1', 'new2']),
        },
        2,
        resolve: (_) async => {'old1': 'new1', 'old2': 'new2'},
      );
      expect(
        UnfollowInterval(load().history.first, load().history.last).users,
        isEmpty,
      );
    },
  );

  test(
    'only missing and new names with identical positive timestamps are proposed',
    () {
      Map<String, InstagramUser> users(Map<String, int> times) => {
        for (final e in times.entries)
          e.key: InstagramUser(username: e.key, timestamp: e.value),
      };
      final candidates = UsernameChangeCandidate.find(
        users({'zero_old': 0, 'old': 123, 'different': 124, 'kept': 125}),
        users({
          'zero_new': 0,
          'new': 123,
          'nearby': 126,
          'kept': 125,
          'another': 125,
        }),
      );
      expect(candidates.single.previous.username, 'old');
      expect(candidates.single.possibleMatches.single.username, 'new');
    },
  );

  test(
    'persists old profiles, compares the intersection and restores everything',
    () async {
      await import({
        'followers_1.json': profiles(['kept', 'lost', 'not_followed']),
        'following.json': profiles([
          'kept',
          'lost',
          'never_followed',
          'new_follower',
        ]),
      }, 1);
      expect(load().whitelist, isEmpty);
      await File('${directory.path}/ignored.json').writeAsString('invalid');
      await import({
        'followers_1.json': profiles(['kept', 'new_follower']),
        'following.json': profiles([
          'kept',
          'lost',
          'never_followed',
          'new_follower',
        ]),
      }, 2);
      final data = load();
      expect(data.followers.keys, ['kept', 'new_follower']);
      expect(data.whitelist, {'lost', 'never_followed', 'new_follower'});
      expect(data.history.first.followers.keys, [
        'kept',
        'lost',
        'not_followed',
      ]);
      final interval = UnfollowInterval(data.history.first, data.history.last);
      expect(interval.users.map((u) => u.username), ['lost', 'not_followed']);
      expect(interval.previous.date, DateTime(2026, 1, 1));
      expect(interval.current.date, DateTime(2026, 2, 1));
      final reloaded = await HistoryService.load(path: directory.path);
      expect(reloaded, hasLength(2));
      expect(reloaded.first.followers['lost']!.timestamp, 123);
    },
  );

  test(
    'treats multiple follower files as one snapshot and replaces old chunks',
    () async {
      await import({
        'followers_1.json': profiles(['first']),
        'followers_2.json': profiles(['second']),
      }, 1);
      expect(load().history, hasLength(1));
      await import({
        'followers.json': profiles(['first']),
      }, 2);
      expect(load().followers.keys, ['first']);
      expect(
        UnfollowInterval(
          load().history.first,
          load().history.last,
        ).users.single.username,
        'second',
      );
    },
  );

  test('following-only import never creates a follower comparison', () async {
    await import({
      'followers_1.json': profiles(['lost']),
      'following.json': profiles(['lost']),
    }, 1);
    await import({
      'following.json': profiles(['lost', 'other']),
    }, 2);
    expect(load().followers.keys, ['lost']);
    expect(load().whitelist, isEmpty);
    expect(load().history.where((s) => s.followersImported), hasLength(1));
    await import({'followers_1.json': profiles([])}, 3);
    expect(load().followers, isEmpty);
    expect(load().following.keys, ['lost', 'other']);
    expect(load().whitelist, {'lost', 'other'});
  });

  test('invalid import and backwards date preserve saved state', () async {
    await import({
      'followers_1.json': profiles(['safe']),
    }, 2);
    final file = File('${directory.path}/${HistoryService.fileName}');
    final before = await file.readAsString();
    for (final invalid in [
      utf8.encode('{bad'),
      utf8.encode('[{"invalid":true}]'),
    ]) {
      await expectLater(
        import({
          'followers_1.json': profiles(['changed']),
          'following.json': invalid,
        }, 3),
        throwsFormatException,
      );
      expect(await file.readAsString(), before);
    }
    await expectLater(
      import({
        'followers_1.json': profiles(['old']),
      }, 1),
      throwsFormatException,
    );
    expect(await file.readAsString(), before);
    await import({
      'followers_1.json': profiles(['safe']),
    }, 3);
    expect(load().history, hasLength(2));
  });

  test('migrates existing raw JSONs and keeps the manual whitelist', () async {
    final legacy = File('${directory.path}/followers_2.json');
    await legacy.writeAsBytes(profiles(['legacy']));
    await legacy.setLastModified(DateTime(2026, 1, 1));
    await File(
      '${directory.path}/following.json',
    ).writeAsBytes(profiles(['legacy', 'manual']));
    await File('${directory.path}/whitelist.txt').writeAsString('manual\n');
    await import({
      'followers_1.json': profiles(['current']),
    }, 2);
    final data = load();
    expect(data.history, hasLength(2));
    expect(data.history.first.estimatedDate, isTrue);
    expect(data.history.first.followers.keys, ['legacy']);
    expect(data.followers.keys, ['current']);
    expect(data.whitelist, {'legacy', 'manual'});
  });
}
