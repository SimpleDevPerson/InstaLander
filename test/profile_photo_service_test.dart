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
}
