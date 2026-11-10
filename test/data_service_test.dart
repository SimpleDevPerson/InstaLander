import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/data_service.dart';

void main() {
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
