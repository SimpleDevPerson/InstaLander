import '../l10n/app_strings.dart';

class InstagramUser {
  final String username;
  final int timestamp;
  final DateTime? followedAt;

  InstagramUser({required this.username, required this.timestamp})
    : followedAt = timestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : null;

  factory InstagramUser.fromJson(Map<String, dynamic> json) {
    final list = json['string_list_data'];
    final data = list is List && list.isNotEmpty && list.first is Map
        ? list.first as Map
        : const {};
    var username = '';
    // Exports can identify the same profile by a title, a value or a URL.
    // Normalize each candidate before choosing it, so blank/invalid values
    // do not prevent falling back to a usable profile link.
    for (final candidate in [json['title'], data['value'], data['href']]) {
      username = _normalizeUsername(candidate);
      if (username.isNotEmpty) break;
    }
    return InstagramUser(
      username: username,
      timestamp: data['timestamp'] is int ? data['timestamp'] as int : 0,
    );
  }

  static final _usernamePattern = RegExp(r'^[a-z0-9_.]+$');

  static String _normalizeUsername(dynamic value) {
    if (value is! String) return '';
    var username = value.trim().toLowerCase();
    if (username.contains('://')) {
      final uri = Uri.tryParse(username);
      if (uri == null ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          (uri.host != 'instagram.com' && uri.host != 'www.instagram.com')) {
        return '';
      }
      final segments = uri.pathSegments.toList();
      if (segments.isNotEmpty && segments.last.isEmpty) segments.removeLast();
      if (segments.length == 2 && segments.first == '_u') {
        username = segments.last;
      } else if (segments.length == 1 && segments.first != '_u') {
        username = segments.single;
      } else {
        return '';
      }
    }
    if (username.startsWith('@')) username = username.substring(1);
    return _usernamePattern.hasMatch(username) ? username : '';
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'timestamp': timestamp,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstagramUser &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;

  @override
  String toString() =>
      'InstagramUser(username: $username, timestamp: $timestamp)';
}

enum SortOption {
  dateDesc,
  dateAsc,
  alphaAsc,
  alphaDesc;

  String get label => switch (this) {
    dateDesc => AppStrings.current.sortDateDescendingLong,
    dateAsc => AppStrings.current.sortDateAscendingLong,
    alphaAsc => AppStrings.current.sortAlphabeticalAscending,
    alphaDesc => AppStrings.current.sortAlphabeticalDescending,
  };
}
