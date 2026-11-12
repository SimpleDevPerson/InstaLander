import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/data_service.dart';

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

  // UI State
  SortOption _currentSort = SortOption.dateDesc;
  bool _isLoading = true;
  bool _hasData = false;
  bool _hasFollowersFile = false;
  bool _hasFollowingFile = false;
  bool _hasCompletedOnboarding = false;
  String? _errorMessage;

  // Getters
  Map<String, InstagramUser> get followers => _followers;
  Map<String, InstagramUser> get following => _following;
  Set<String> get whitelist => _whitelist;
  List<InstagramUser> get nonFollowers => _nonFollowers;
  Map<String, int> get stats => _stats;
  SortOption get currentSort => _currentSort;
  bool get isLoading => _isLoading;
  bool get hasData => _hasData;
  bool get hasFollowersFile => _hasFollowersFile;
  bool get hasFollowingFile => _hasFollowingFile;
  bool get hasPartialData => _hasFollowersFile != _hasFollowingFile;
  bool get shouldShowOnboarding =>
      !_isLoading && !_hasData && !_hasCompletedOnboarding;
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
        list.sort((a, b) =>
            a.username.toLowerCase().compareTo(b.username.toLowerCase()));
        break;
      case SortOption.alphaDesc:
        list.sort((a, b) =>
            b.username.toLowerCase().compareTo(a.username.toLowerCase()));
        break;
    }
    _sortedNonFollowers = list;
  }

  // Initialize app data
  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _followers = await DataService.loadUsersFromFiles(
        prefix: 'followers',
        label: 'FOLLOWER (Chi ti segue)',
      );
      _following = await DataService.loadUsersFromFiles(
        prefix: 'following',
        label: 'SEGUITI (Chi segui tu)',
      );
      _hasFollowersFile =
          await DataService.countFilesWithPrefix('followers') > 0;
      _hasFollowingFile =
          await DataService.countFilesWithPrefix('following') > 0;
      _whitelist = await DataService.loadWhitelist();
      final preferences = await SharedPreferences.getInstance();
      _viewedProfiles =
          preferences.getStringList(_viewedProfilesKey)?.toSet() ?? {};
      _hasCompletedOnboarding =
          preferences.getBool(_onboardingCompletedKey) ?? false;

      _recomputeData();
      _hasData = _hasFollowersFile && _hasFollowingFile;
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
  Future<void> loadJsonFiles(List<dynamic> files) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await DataService.saveJsonFiles(files.cast<PlatformFile>());

      await _loadSavedFiles();
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dei file: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInstagramArchive(PlatformFile archiveFile) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await DataService.saveInstagramArchive(archiveFile);
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dell’archivio ZIP: $e';
      _setLoading(false);
      return;
    }

    await loadJsonFiles(const []);
  }

  Future<void> _loadSavedFiles() async {
    final followersFileCount =
        await DataService.countFilesWithPrefix('followers');
    final followingFileCount =
        await DataService.countFilesWithPrefix('following');

    _hasFollowersFile = followersFileCount > 0;
    _hasFollowingFile = followingFileCount > 0;
    _followers = await DataService.loadUsersFromFiles(
      prefix: 'followers',
      label: 'FOLLOWER (Chi ti segue)',
    );
    _following = await DataService.loadUsersFromFiles(
      prefix: 'following',
      label: 'SEGUITI (Chi segui tu)',
    );

    if (!_hasFollowersFile && !_hasFollowingFile) {
      _errorMessage =
          'Nessun file JSON valido trovato. Seleziona file followers_*.json e following_*.json';
    }

    _recomputeData();
    _hasData = _hasFollowersFile && _hasFollowingFile;
  }

  // Recompute derived data
  void _recomputeData() {
    _nonFollowers =
        DataService.computeNonFollowers(_followers, _following, _whitelist);
    _updateSortedNonFollowers();
    _stats = DataService.getStats(_followers, _following, _whitelist);
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
    _whitelist.add(username);
    DataService.saveWhitelist(_whitelist);
    _recomputeData();
  }

  // Remove user from whitelist
  void removeFromWhitelist(String username) {
    _whitelist.remove(username);
    DataService.saveWhitelist(_whitelist);
    _recomputeData();
  }

  // Clear entire whitelist
  void clearWhitelist() {
    _whitelist.clear();
    DataService.saveWhitelist(_whitelist);
    _recomputeData();
  }

  // Check if user is in whitelist
  bool isInWhitelist(String username) => _whitelist.contains(username);

  bool isProfileViewed(String username) => _viewedProfiles.contains(username);

  Future<void> markProfileViewed(String username) async {
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
