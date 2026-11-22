import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/services/profile_photo_service.dart';

void main() {
  test(
    'reuses downloaded photos across cards after loading many profiles',
    () async {
      final first = Uint8List.fromList([1]);
      var firstDownloads = 0;
      final photos = ProfilePhotoService(
        download: (name, _) async {
          if (name != 'first') return Uint8List.fromList([2]);
          firstDownloads++;
          return first;
        },
      );
      final results = await Future.wait([
        photos.load('first', isNeeded: () => true),
        photos.load('First', isNeeded: () => true),
      ]);
      expect(results, [same(first), same(first)]);

      for (var i = 0; i < 100; i++) {
        await photos.load('profile_$i', isNeeded: () => true);
      }

      expect(photos.cachedPhoto('FIRST'), same(first));
      expect(await photos.load('First', isNeeded: () => true), same(first));
      expect(firstDownloads, 1);
    },
  );

  test('extracts and decodes a photo URL from the matching public profile', () {
    const markup = '''
      <meta content="https://www.instagram.com/example/" property="og:url">
      <meta content="https://scontent.cdninstagram.com/photo.jpg?a=1&amp;b=2"
        property="og:image">
    ''';
    expect(
      ProfilePhotoService.extractPhotoUrl(markup, 'Example')?.queryParameters,
      {'a': '1', 'b': '2'},
    );
    expect(ProfilePhotoService.extractPhotoUrl(markup, 'another'), isNull);
  });

  test('rejects login pages and images from unrelated hosts', () {
    for (final (page, image) in [
      ('accounts/login/', 'https://scontent.cdninstagram.com/photo.jpg'),
      ('example/', 'https://example.net/photo.jpg'),
    ]) {
      expect(
        ProfilePhotoService.extractPhotoUrl('''
          <link rel="canonical" href="https://www.instagram.com/$page">
          <meta property="og:image" content="$image">
        ''', 'example'),
        isNull,
      );
    }
  });

  test('reads exact and abbreviated counts from the matching profile', () {
    int? followers(String description, {String profile = 'example'}) =>
        ProfilePhotoService.extractFollowerCount('''
          <link rel="canonical" href="https://www.instagram.com/$profile/">
          <meta property="og:description" content="$description">
        ''', 'Example');

    expect(followers('12,345 Followers, 2 Following, 3 Posts'), 12345);
    expect(followers('12&#8239;345 followers, 2 following'), 12345);
    expect(followers('0 Followers, 2 Following, 3 Posts'), 0);
    expect(followers('1 Follower, 2 Following, 3 Posts'), 1);
    expect(followers('12.3K Followers, 2 Following, 3 Posts'), 12300);
    expect(followers('12,3k Followers, 2 Following, 3 Posts'), 12300);
    expect(followers('1.25 M Followers, 2 Following, 3 Posts'), 1250000);
    expect(followers('2B Followers, 2 Following, 3 Posts'), 2000000000);
    expect(followers('1.234K Followers'), 1234);
    expect(followers('12.3 Followers'), isNull);
    expect(followers('12 Following, 3 Posts'), isNull);
    expect(followers('500 Followers', profile: 'other'), isNull);
    expect(followers('500K Followers', profile: 'other'), isNull);
    expect(followers('500 Followers', profile: 'accounts/login'), isNull);
  });
}
