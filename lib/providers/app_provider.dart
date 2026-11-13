import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/import_snapshot.dart';
import '../models/user.dart';
import '../models/username_change.dart';
import '../services/data_service.dart';
import '../services/debug_data_service.dart';
import '../services/reminder_service.dart';

class AppProvider extends ChangeNotifier {
  static const String _viewedProfilesKey = 'viewed_profiles';
  static const String _onboardingCompletedKey = 'onboarding_completed_v2';

  // Data
  Map<String, InstagramUser> _followers = {};
  Map<String, InstagramUser> _following = {};
  Set<String> _whitelist = {};
  Set<String> _viewedProfiles = {};
  List<InstagramUser> _nonFollowers = [];
  List<InstagramUser> _sortedNonFollowers = [];
  Map<String, int> _stats = {};
  List<ImportSnapshot> _history = [];
  Map<String, InstagramUser> _debugFollowers = {};
  Map<String, InstagramUser> _debugFollowing = {};
  Set<String> _debugWhitelist = {};
  final Set<String> _debugViewedProfiles = {};
  List<UnfollowInterval> _debugTimeline = [];

  void populateDebugTimeline() {
    _debugTimeline = DebugDataService().timeline();
    notifyListeners();
  }

  void populateDebugWhitelist() {
    _debugWhitelist.addAll(DebugDataService().profiles('whitelist', 15).keys);
    _recomputeData();
  }

  void populateDebugReport() {
    final (followers, following) = DebugDataService().report();
    _debugWhitelist.removeAll(_debugFollowing.keys);
    _debugFollowers = followers;
    _debugFollowing = following;
    _errorMessage = null;
    _recomputeData();
  }

  void _clearDebugData() {
    _debugFollowers = {};
    _debugFollowing = {};
    _debugWhitelist = {};
    _debugTimeline = [];
    _debugViewedProfiles.clear();
  }

  bool _monthlyReminder = false;
  int _reminderIntervalMonths = 1;
  int get reminderIntervalMonths => _reminderIntervalMonths;
  Future<void> setReminderIntervalMonths(int months) async {
    await ReminderService.setIntervalMonths(months);
    _reminderIntervalMonths = months;
    notifyListeners();
  }

  bool get monthlyReminder => _monthlyReminder;
  List<UnfollowInterval> get timeline {
    final snapshots = _history.where((s) => s.followersImported).toList();
    return [
      ..._debugTimeline,
      for (var i = snapshots.length - 1; i > 0; i--)
        UnfollowInterval(snapshots[i - 1], snapshots[i]),
    ];
  }

  int get followerSnapshotCount =>
      _history.where((s) => s.followersImported).length;

  Future<bool> setMonthlyReminder(bool enabled) async {
    final result = await ReminderService.setEnabled(enabled);
    _monthlyReminder = result;
    notifyListeners();
    return result == enabled;
  }

  // UI State
  SortOption _currentSort = SortOption.dateDesc;
  bool _isLoading = true;
  bool _hasData = false;
  bool _hasFollowersFile = false;
  bool _hasFollowingFile = false;
  bool _hasCompletedOnboarding = false;
  String? _errorMessage;

  // Getters
  Map<String, InstagramUser> get followers => _debugFollowers.isEmpty
      ? _followers
      : {..._followers, ..._debugFollowers};
  Map<String, InstagramUser> get following => _debugFollowing.isEmpty
      ? _following
      : {..._following, ..._debugFollowing};
  Set<String> get whitelist => _debugWhitelist.isEmpty
      ? _whitelist
      : {..._whitelist, ..._debugWhitelist};
  List<InstagramUser> get nonFollowers => _nonFollowers;
  Map<String, int> get stats => _stats;
  SortOption get currentSort => _currentSort;
  bool get isLoading => _isLoading;
  bool get hasData => _hasData || _debugFollowing.isNotEmpty;
  bool get hasFollowersFile => _hasFollowersFile || _debugFollowing.isNotEmpty;
  bool get hasFollowingFile => _hasFollowingFile || _debugFollowing.isNotEmpty;
  bool get hasPartialData => hasFollowersFile != hasFollowingFile;
  bool get shouldShowOnboarding =>
      !_isLoading && !hasData && !_hasCompletedOnboarding;
  String? get errorMessage => _errorMessage;

  List<InstagramUser> get sortedNonFollowers => _sortedNonFollowers;

  void _updateSortedNonFollowers() {
    final list = List<InstagramUser>.of(_nonFollowers);
    switch (_currentSort) {
      case SortOption.dateDesc:
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case SortOption.dateAsc:
        list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case SortOption.alphaAsc:
        list.sort(
          (a, b) =>
              a.username.toLowerCase().compareTo(b.username.toLowerCase()),
        );
        break;
      case SortOption.alphaDesc:
        list.sort(
          (a, b) =>
              b.username.toLowerCase().compareTo(a.username.toLowerCase()),
        );
        break;
    }
    _sortedNonFollowers = list;
  }

  // Initialize app data
  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _loadSavedFiles();
      try {
        _monthlyReminder = await ReminderService.isEnabled();
        _reminderIntervalMonths = await ReminderService.getIntervalMonths();
      } on Exception {
        _monthlyReminder = false;
      }
      final preferences = await SharedPreferences.getInstance();
      _viewedProfiles =
          preferences.getStringList(_viewedProfilesKey)?.toSet() ?? {};
      _hasCompletedOnboarding =
          preferences.getBool(_onboardingCompletedKey) ?? false;

      // Note: Non impostiamo _errorMessage se non ci sono file al primo avvio.
      // Lo stato _hasData = false farà vedere la schermata di setup con il pulsante "Carica JSON".
    } catch (e) {
      _errorMessage = 'Errore durante l\'inizializzazione: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingCompletedKey, true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _setLoading(true);

    try {
      if (ReminderService.supported) {
        await ReminderService.setEnabled(false);
        await ReminderService.setIntervalMonths(1);
      }
      await DataService.clearAppData();
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      _followers = {};
      _following = {};
      _whitelist = {};
      _viewedProfiles = {};
      _nonFollowers = [];
      _sortedNonFollowers = [];
      _stats = DataService.getStats(_followers, _following, _whitelist);
      _history = [];
      _clearDebugData();
      _monthlyReminder = false;
      _reminderIntervalMonths = 1;
      _currentSort = SortOption.dateDesc;
      _hasData = false;
      _hasFollowersFile = false;
      _hasFollowingFile = false;
      _hasCompletedOnboarding = false;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Errore durante l’eliminazione dei dati: $error';
      _setLoading(false);
      rethrow;
    }
  }

  // Load and process new JSON files
  Future<void> loadJsonFiles(
    List<dynamic> files, {
    DateTime? exportDate,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await DataService.saveJsonFiles(
        files.cast<PlatformFile>(),
        exportDate: exportDate,
        resolveUsernameChanges: resolveUsernameChanges,
      );

      await _loadSavedFiles();
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dei file: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInstagramArchive(
    PlatformFile archiveFile, {
    DateTime? exportDate,
    ResolveUsernameChanges? resolveUsernameChanges,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await DataService.saveInstagramArchive(
        archiveFile,
        exportDate: exportDate,
        resolveUsernameChanges: resolveUsernameChanges,
      );
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dell’archivio ZIP: $e';
      _setLoading(false);
      return;
    }

    await loadJsonFiles(const []);
  }

  Future<void> _loadSavedFiles() async {
    final snapshot = await DataService.loadAppData(sort: _currentSort);
    _clearDebugData();
    _hasFollowersFile = snapshot.hasFollowersFile;
    _hasFollowingFile = snapshot.hasFollowingFile;
    _followers = snapshot.followers;
    _following = snapshot.following;
    _whitelist = Set.of(snapshot.whitelist);
    _history = snapshot.history;
    _nonFollowers = snapshot.nonFollowers;
    _sortedNonFollowers = snapshot.sortedNonFollowers;
    _stats = snapshot.stats;
    _hasData = _hasFollowersFile && _hasFollowingFile;
  }

  // Recompute derived data
  void _recomputeData() {
    _nonFollowers = DataService.computeNonFollowers(
      followers,
      following,
      whitelist,
    );
    _updateSortedNonFollowers();
    _stats = DataService.getStats(followers, following, whitelist);
    notifyListeners();
  }

  // Change sort option
  void setSortOption(SortOption option) {
    if (_currentSort == option) return;
    _currentSort = option;
    _updateSortedNonFollowers();
    notifyListeners();
  }

  // Add user to whitelist
  void addToWhitelist(String username) {
    if (_debugFollowing.containsKey(username)) {
      _debugWhitelist.add(username);
      _recomputeData();
      return;
    }
    _whitelist.add(username);
    _saveWhitelist();
    _recomputeData();
  }

  // Remove user from whitelist
  void removeFromWhitelist(String username) {
    if (_debugWhitelist.remove(username)) {
      _recomputeData();
      return;
    }
    _whitelist.remove(username);
    _saveWhitelist();
    _recomputeData();
  }

  // Clear entire whitelist
  void clearWhitelist() {
    _debugWhitelist.clear();
    _whitelist.clear();
    _saveWhitelist();
    _recomputeData();
  }

  Future<void> _saveWhitelist() async {
    try {
      await DataService.saveWhitelist(_whitelist);
    } catch (error) {
      setError('Impossibile salvare la whitelist: $error');
    }
  }

  // Check if user is in whitelist
  bool isInWhitelist(String username) => whitelist.contains(username);

  bool isProfileViewed(String username) =>
      _viewedProfiles.contains(username) ||
      _debugViewedProfiles.contains(username);

  Future<void> markProfileViewed(String username) async {
    if (_debugFollowing.containsKey(username) ||
        _debugWhitelist.contains(username)) {
      _debugViewedProfiles.add(username);
      notifyListeners();
      return;
    }
    if (!_viewedProfiles.add(username)) return;

    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _viewedProfilesKey,
      _viewedProfiles.toList(),
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
