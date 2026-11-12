import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/user.dart';
import 'package:instalander/services/data_service.dart';

void main() {
  test('parses a large Instagram export in a helper isolate', () async {
    final entries = List.generate(20000, (index) => {
      'string_list_data': [{'value': 'profile_$index', 'timestamp': index}],
    });
    final users = await compute(DataService.parseUsersJson, jsonEncode(entries));
    expect(users.length, 20000);
    expect(users['profile_19999']!.timestamp, 19999);
  });

  test('supports following wrappers, duplicates and malformed entries', () {
    final users = DataService.parseUsersJson(jsonEncode({
      'relationships_following': [
        {'title': 'first'},
        null,
        {'title': 'second'},
        {'title': 'first', 'string_list_data': [{'timestamp': 123}]},
      ],
    }));
    expect(users.keys, ['first', 'second']);
    expect(users['first']!.timestamp, 123);
    expect(() => DataService.parseUsersJson('{invalid'), throwsFormatException);
  });

  test('report and stats match the set-based result for large lists', () {
    final following = {
      for (var i = 0; i < 20000; i++)
        'profile_$i': InstagramUser(username: 'profile_$i', timestamp: i),
    };
    final followers = Map<String, InstagramUser>.fromEntries(
      following.entries.take(12000));
    final whitelist = {'profile_15000', 'profile_18000', 'unrelated'};
    final expected = following.keys.toSet()
        .difference(followers.keys.toSet()).difference(whitelist);
    expect(DataService.computeNonFollowers(followers, following, whitelist)
        .map((user) => user.username), expected);
    expect(DataService.getStats(followers, following, whitelist), {
      'following': 20000, 'followers': 12000, 'whitelist': 3,
      'notFollowingBackTotal': 8000, 'visibleCount': 7998,
    });
  });

  test('extracts only Instagram follower JSON files from the ZIP', () {
    final archive = Archive()
      ..add(ArchiveFile.string(
        'your_instagram_activity/followers_and_following/followers_1.json',
        '[{"username":"follower"}]',
      ))
      ..add(ArchiveFile.string(
        'your_instagram_activity/followers_and_following/following.json',
        '[{"username":"following"}]',
      ))
      ..add(ArchiveFile.string(
        'your_instagram_activity/posts_1.json',
        '[]',
      ));

    final files = DataService.decodeInstagramArchive(
      ZipEncoder().encode(archive),
    );

    expect(files.keys.toSet(), {'followers_1.json', 'following.json'});
    expect(
      utf8.decode(files['followers_1.json']!),
      '[{"username":"follower"}]',
    );
    expect(utf8.decode(files['following.json']!), '[{"username":"following"}]');
  });

  test('rejects ZIP files without follower data', () {
    final archive = Archive()
      ..add(ArchiveFile.string('your_instagram_activity/posts_1.json', '[]'));

    expect(
      () => DataService.decodeInstagramArchive(ZipEncoder().encode(archive)),
      throwsFormatException,
    );
  });
}
