import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/data_service.dart';

class AppProvider extends ChangeNotifier {
  static const String _viewedProfilesKey = 'viewed_profiles';

  // Data
  Map<String, InstagramUser> _followers = {};
  Map<String, InstagramUser> _following = {};
  Set<String> _whitelist = {};
  Set<String> _viewedProfiles = {};
  List<InstagramUser> _nonFollowers = [];
  Map<String, int> _stats = {};

  // UI State
  SortOption _currentSort = SortOption.dateDesc;
  bool _isLoading = false;
  bool _hasData = false;
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
  String? get errorMessage => _errorMessage;

  // Sorted non-followers based on current sort option
  List<InstagramUser> get sortedNonFollowers {
    final list = List<InstagramUser>.from(_nonFollowers);
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
    return list;
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
      _whitelist = await DataService.loadWhitelist();
      final preferences = await SharedPreferences.getInstance();
      _viewedProfiles =
          preferences.getStringList(_viewedProfilesKey)?.toSet() ?? {};

      _recomputeData();
      _hasData = _followers.isNotEmpty && _following.isNotEmpty;
      // Note: Non impostiamo _errorMessage se non ci sono file al primo avvio.
      // Lo stato _hasData = false farà vedere la schermata di setup con il pulsante "Carica JSON".
    } catch (e) {
      _errorMessage = 'Errore durante l\'inizializzazione: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load and process new JSON files
  Future<void> loadJsonFiles(List<dynamic> files) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await DataService.saveJsonFiles(files.cast<PlatformFile>());

      // Check how many files exist for each prefix before loading
      final followersFileCount =
          await DataService.countFilesWithPrefix('followers');
      final followingFileCount =
          await DataService.countFilesWithPrefix('following');

      _followers = await DataService.loadUsersFromFiles(
        prefix: 'followers',
        label: 'FOLLOWER (Chi ti segue)',
      );
      _following = await DataService.loadUsersFromFiles(
        prefix: 'following',
        label: 'SEGUITI (Chi segui tu)',
      );

      // Check if files were actually loaded with better error messages
      if (_followers.isEmpty && _following.isEmpty) {
        _errorMessage =
            'Nessun file JSON valido trovato. Assicurati di selezionare file followers_*.json e following_*.json';
      } else if (_followers.isEmpty) {
        if (followersFileCount == 0) {
          _errorMessage =
              'File "followers" non trovato. Seleziona un file followers_*.json';
        } else {
          _errorMessage =
              'File "followers" trovato ma vuoto o formato non riconosciuto. Controlla il file JSON.';
        }
      } else if (_following.isEmpty) {
        if (followingFileCount == 0) {
          _errorMessage =
              'File "following" non trovato. Seleziona un file following_*.json';
        } else {
          _errorMessage =
              'File "following" trovato ma vuoto o formato non riconosciuto. Controlla il file JSON.';
        }
      }

      _recomputeData();
      _hasData = _followers.isNotEmpty && _following.isNotEmpty;
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dei file: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Recompute derived data
  void _recomputeData() {
    _nonFollowers =
        DataService.computeNonFollowers(_followers, _following, _whitelist);
    _stats = DataService.getStats(_followers, _following, _whitelist);
    notifyListeners();
  }

  // Change sort option
  void setSortOption(SortOption option) {
    _currentSort = option;
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
