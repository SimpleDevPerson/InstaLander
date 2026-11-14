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
    String? username;
    int timestamp = 0;

    // Handle different JSON structures from Instagram export
    // Priority 1: 'title' field (often contains username directly)
    if (json['title'] != null) {
      username = json['title'] as String?;
    }

    // Priority 2: 'string_list_data' array (may have 'value' or 'href')
    if (username == null || username.isEmpty) {
      if (json['string_list_data'] != null &&
          json['string_list_data'].isNotEmpty) {
        final data = json['string_list_data'][0];
        // Try 'value' first (old format), then 'href' (new format)
        username = (data['value'] ?? data['href']) as String?;
        timestamp = data['timestamp'] as int? ?? 0;
      }
    }

    // If still no username but we have timestamp from string_list_data
    if (timestamp == 0 &&
        json['string_list_data'] != null &&
        json['string_list_data'].isNotEmpty) {
      final data = json['string_list_data'][0];
      timestamp = data['timestamp'] as int? ?? 0;
    }

    return InstagramUser(username: username ?? '', timestamp: timestamp);
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
