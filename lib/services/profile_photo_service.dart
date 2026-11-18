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

  final Future<Uint8List?> Function(String, bool Function())? _downloadOverride;
  final _photos = <String, Uint8List>{};
  final _misses = <String, DateTime>{};
  Future<void> _queue = Future.value();
  DateTime? _retryAfter;

  Uint8List? cachedPhoto(String username) => _photos[username.toLowerCase()];

  Future<Uint8List?> load(
    String username, {
    required bool Function() isNeeded,
  }) {
    final name = username.toLowerCase();
    if (!_username.hasMatch(name) ||
        name == '.' ||
        name == '..' ||
        name.startsWith('debug_')) {
      return Future.value();
    }

    final savedPhoto = cachedPhoto(name);
    if (savedPhoto != null) return Future.value(savedPhoto);

    // Queue requests one at a time. Cards already scrolled away skip their turn.
    final request = _queue.then((_) async {
      if (!isNeeded()) return null;
      // Another card may have downloaded the photo while we were queued.
      final savedPhoto = cachedPhoto(name);
      if (savedPhoto != null) return savedPhoto;
      final now = DateTime.now();
      final missedUntil = _misses[name];
      if (missedUntil != null && now.isBefore(missedUntil)) return null;
      _misses.remove(name);
      final retryAfter = _retryAfter;
      if (retryAfter != null && now.isBefore(retryAfter)) return null;

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
    _queue = request.then<void>((_) {});
    return request;
  }

  Future<Uint8List?> _downloadPhoto(
    String username,
    bool Function() isNeeded,
  ) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      return await _fetchPhoto(client, username, isNeeded).timeout(_timeout);
    } finally {
      client.close(force: true);
    }
  }

  Future<HttpClientResponse?> _get(HttpClient client, Uri uri) async {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    final response = await request.close();
    if (response.statusCode == HttpStatus.tooManyRequests) {
      _retryAfter = DateTime.now().add(const Duration(minutes: 5));
    }
    return response.statusCode == HttpStatus.ok ? response : null;
  }

  Future<Uint8List?> _fetchPhoto(
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
    final photoUrl = await _parseInBackground(head, username);
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

  static Future<Uri?> _parseInBackground(String markup, String username) =>
      Isolate.run(() => extractPhotoUrl(markup, username));

  static Uri? extractPhotoUrl(String markup, String username) {
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
    if (image == null ||
        image.scheme != 'https' ||
        image.port != 443 ||
        image.userInfo.isNotEmpty ||
        !(image.host.endsWith('.cdninstagram.com') ||
            image.host.endsWith('.fbcdn.net'))) {
      return null;
    }
    return image;
  }
}
