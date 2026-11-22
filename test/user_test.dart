import 'package:flutter_test/flutter_test.dart';
import 'package:instalander/models/user.dart';

void main() {
  for (final identifier in [
    'Mario.Rossi',
    ' @Mario.Rossi ',
    'https://www.instagram.com/Mario.Rossi/',
    'https://instagram.com/Mario.Rossi?igsh=example',
    'https://www.instagram.com/_u/Mario.Rossi/',
  ]) {
    test('normalizes profile identifier: $identifier', () {
      for (final field in ['title', 'value', 'href']) {
        final user = InstagramUser.fromJson({
          if (field == 'title') 'title': identifier,
          'string_list_data': [
            {if (field != 'title') field: identifier, 'timestamp': 123},
          ],
        });
        expect(user.username, 'mario.rossi', reason: field);
        expect(user.timestamp, 123);
      }
    });
  }

  test('falls back from empty or invalid title and value to profile URL', () {
    for (final title in ['', ' ', 'Mario Rossi', 42]) {
      final user = InstagramUser.fromJson({
        'title': title,
        'string_list_data': [
          {
            'value': ' ',
            'href': 'https://www.instagram.com/_u/Mario.Rossi/',
            'timestamp': 123,
          },
        ],
      });
      expect(user.username, 'mario.rossi');
      expect(user.timestamp, 123);
    }
  });

  test('rejects URLs that do not identify an Instagram profile', () {
    for (final url in [
      'https://example.com/mario/',
      'https://instagram.com.example.com/mario/',
      'https://www.instagram.com/',
      'https://www.instagram.com/_u/',
      'https://www.instagram.com/p/some_post/',
      'https://www.instagram.com/mario/extra/',
    ]) {
      expect(
        InstagramUser.fromJson({
          'string_list_data': [
            {'href': url},
          ],
        }).username,
        isEmpty,
        reason: url,
      );
    }
  });

  test(
    'preserves title priority and handles entries without relationship data',
    () {
      expect(
        InstagramUser.fromJson({
          'title': 'Mario',
          'string_list_data': [
            {'value': 'other', 'timestamp': 123},
          ],
        }).username,
        'mario',
      );
      final user = InstagramUser.fromJson({'title': 'Mario'});
      expect(user.username, 'mario');
      expect(user.timestamp, 0);
      expect(InstagramUser.fromJson({}).username, isEmpty);
    },
  );
}
