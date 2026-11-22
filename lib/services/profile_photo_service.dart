import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:html/parser.dart' as html;

class ProfilePhotoService {
  ProfilePhotoService({
    Future<Uint8List?> Function(String, bool Function())? download,
  }) : _downloadOverride = download;

  static final instance = ProfilePhotoService();
  static final _username = RegExp(r'^[a-zA-Z0-9_.]{1,30}$');
  static const _downloadLimit = 256 * 1024;
  static const _timeout = Duration(seconds: 6);
  static final _followerDescription = RegExp(
    r'^\s*(?:(\d+)(?:[.,](\d+))?\s*([KMB])|'
    r'(\d{1,3}(?:[,\u00A0\u202F ]\d{3})+|\d+))\s+Followers?\b',
    caseSensitive: false,
  );

  final Future<Uint8List?> Function(String, bool Function())? _downloadOverride;
  final _photos = <String, Uint8List>{};
  final _followerCounts = <String, int>{};
  final _misses = <String, DateTime>{};
  Future<void> _queue = Future.value();
  DateTime? _retryAfter;

  Uint8List? cachedPhoto(String username) => _photos[username.toLowerCase()];

  bool get isRateLimited => _retryAfter?.isAfter(DateTime.now()) ?? false;

  static bool _isPublicUsername(String name) =>
      _username.hasMatch(name) &&
      name != '.' &&
      name != '..' &&
      !name.startsWith('debug_');

  Future<int?> loadFollowerCount(
    String username, {
    required bool Function() isNeeded,
  }) {
    final name = username.toLowerCase();
    if (!_isPublicUsername(name)) return Future.value();
    return _enqueue(() async {
      if (!isNeeded()) return null;
      final cached = _followerCounts[name];
      if (cached != null || isRateLimited) return cached;
      try {
        final profile = await _withClient(
          (client) => _fetchProfile(client, name, isNeeded),
        );
        return profile?.followerCount;
      } on Exception {
        return null;
      }
    });
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final request = _queue.then((_) => operation());
    _queue = request.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return request;
  }

  Future<Uint8List?> load(
    String username, {
    required bool Function() isNeeded,
  }) {
    final name = username.toLowerCase();
    if (!_isPublicUsername(name)) return Future.value();

    final savedPhoto = cachedPhoto(name);
    if (savedPhoto != null) return Future.value(savedPhoto);

    // Queue requests one at a time. Cards already scrolled away skip their turn.
    return _enqueue(() async {
      if (!isNeeded()) return null;
      // Another card may have downloaded the photo while we were queued.
      final savedPhoto = cachedPhoto(name);
      if (savedPhoto != null) return savedPhoto;
      final now = DateTime.now();
      final missedUntil = _misses[name];
      if (missedUntil != null && now.isBefore(missedUntil)) return null;
      _misses.remove(name);
      if (isRateLimited) return null;

      Uint8List? photo;
      try {
        photo = await (_downloadOverride ?? _downloadPhoto)(name, isNeeded);
      } on Exception {
        // No network, HTML changes and invalid image responses are optional.
      }
      if (photo != null) {
        _photos[name] = photo;
      } else if (isNeeded()) {
        _misses[name] = DateTime.now().add(const Duration(minutes: 2));
        if (_misses.length > 96) _misses.remove(_misses.keys.first);
      }
      return photo;
    });
  }

  Future<Uint8List?> _downloadPhoto(
    String username,
    bool Function() isNeeded,
  ) => _withClient((client) => _fetchPhoto(client, username, isNeeded));

  Future<T> _withClient<T>(Future<T> Function(HttpClient) fetch) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      return await fetch(client).timeout(_timeout);
    } finally {
      client.close(force: true);
    }
  }

  Future<HttpClientResponse?> _get(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptLanguageHeader, 'en-US,en;q=0.9');
    final response = await request.close();
    if (response.statusCode == HttpStatus.tooManyRequests) {
      _retryAfter = DateTime.now().add(const Duration(minutes: 5));
    }
    return response.statusCode == HttpStatus.ok ? response : null;
  }

  Future<({Uri? photoUrl, int? followerCount})?> _fetchProfile(
    HttpClient client,
    String username,
    bool Function() isNeeded,
  ) async {
    final page = await _get(
      client,
      Uri.https('www.instagram.com', '/$username/'),
    );
    if (page == null || !isNeeded()) return null;

    var head = '';
    await for (final chunk in utf8.decoder.bind(page)) {
      if (!isNeeded()) return null;
      head += chunk;
      final end = head.indexOf('</head>');
      if (end >= 0 && end + 7 <= _downloadLimit) {
        head = head.substring(0, end + 7);
        break;
      }
      if (head.length > _downloadLimit) return null;
    }
    final profile = await _parseInBackground(head, username);
    final count = profile?.followerCount;
    if (count != null) _followerCounts[username] = count;
    return profile;
  }

  Future<Uint8List?> _fetchPhoto(
    HttpClient client,
    String username,
    bool Function() isNeeded,
  ) async {
    final profile = await _fetchProfile(client, username, isNeeded);
    final photoUrl = profile?.photoUrl;
    if (photoUrl == null || !isNeeded()) return null;

    final response = await _get(client, photoUrl);
    if (response == null ||
        response.contentLength > _downloadLimit ||
        response.headers.contentType?.primaryType != 'image') {
      return null;
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      if (!isNeeded() || bytes.length + chunk.length > _downloadLimit) {
        return null;
      }
      bytes.add(chunk);
    }
    return bytes.isEmpty ? null : bytes.takeBytes();
  }

  static Uri? extractPhotoUrl(String markup, String username) =>
      _parseProfile(markup, username)?.photoUrl;

  static int? extractFollowerCount(String markup, String username) =>
      _parseProfile(markup, username)?.followerCount;

  static Future<({Uri? photoUrl, int? followerCount})?> _parseInBackground(
    String markup,
    String username,
  ) => Isolate.run(() => _parseProfile(markup, username));

  static ({Uri? photoUrl, int? followerCount})? _parseProfile(
    String markup,
    String username,
  ) {
    final head = html.parse(markup).head;
    if (head == null) return null;
    final pageUrl = Uri.tryParse(
      head.querySelector('meta[property="og:url"]')?.attributes['content'] ??
          head.querySelector('link[rel="canonical"]')?.attributes['href'] ??
          '',
    );
    if (pageUrl == null ||
        pageUrl.scheme != 'https' ||
        !['instagram.com', 'www.instagram.com'].contains(pageUrl.host) ||
        (pageUrl.path.toLowerCase() != '/${username.toLowerCase()}/' &&
            pageUrl.path.toLowerCase() != '/${username.toLowerCase()}')) {
      return null;
    }
    final metadata = head.querySelector('meta[property="og:image"]');
    final image = Uri.tryParse(metadata?.attributes['content'] ?? '');
    final validImage =
        image != null &&
        image.scheme == 'https' &&
        image.port == 443 &&
        image.userInfo.isEmpty &&
        (image.host.endsWith('.cdninstagram.com') ||
            image.host.endsWith('.fbcdn.net'));
    final description = head
        .querySelector('meta[property="og:description"]')
        ?.attributes['content'];
    return (
      photoUrl: validImage ? image : null,
      followerCount: _parseFollowerCount(description ?? ''),
    );
  }

  static int? _parseFollowerCount(String description) {
    final match = _followerDescription.firstMatch(description);
    if (match == null) return null;
    final exact = match.group(4);
    if (exact != null) {
      return int.tryParse(exact.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    final scale = switch (match.group(3)?.toUpperCase()) {
      'K' => 3,
      'M' => 6,
      'B' => 9,
      _ => 0,
    };
    // Shift the decimal point without floating-point rounding.
    final fraction = (match.group(2) ?? '').padRight(scale, '0');
    return int.tryParse('${match.group(1)}${fraction.substring(0, scale)}');
  }
}
