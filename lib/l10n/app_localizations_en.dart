// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sortDateDescendingLong => 'Date descending (Newest first)';

  @override
  String get sortDateAscendingLong => 'Date ascending (Oldest first)';

  @override
  String get sortAlphabeticalAscending => 'Alphabetical (A–Z)';

  @override
  String get sortAlphabeticalDescending => 'Alphabetical (Z–A)';

  @override
  String get cannotSavePreference => 'Unable to save the preference';

  @override
  String initializationError(String arg0) {
    return 'Initialization error: $arg0';
  }

  @override
  String deleteDataError(String arg0) {
    return 'Unable to delete data: $arg0';
  }

  @override
  String loadFilesError(String arg0) {
    return 'Unable to load files: $arg0';
  }

  @override
  String loadArchiveError(String arg0) {
    return 'Unable to load ZIP archive: $arg0';
  }

  @override
  String saveWhitelistError(String arg0) {
    return 'Unable to save whitelist: $arg0';
  }

  @override
  String get originalIcon => 'Original';

  @override
  String get darkIcon => 'Dark';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get cannotOpenProfile => 'Unable to open the profile.';

  @override
  String get report => 'Report';

  @override
  String get timeline => 'Timeline';

  @override
  String get whitelist => 'Whitelist';

  @override
  String get settings => 'Settings';

  @override
  String get reportTitlePrefix => 'Your ';

  @override
  String get reportTitleEmphasis => 'unfollower';

  @override
  String get reportTitleSuffix => ' report';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get followersFileLabel => 'followers';

  @override
  String get followingFileLabel => 'following';

  @override
  String get missingFile => 'A file is missing';

  @override
  String loadMissingFile(String arg0) {
    return 'Load file\n$arg0';
  }

  @override
  String get orLoadZip => 'Or load a ZIP archive';

  @override
  String get allDone => 'All done!';

  @override
  String get sortDateDescending => 'Date descending';

  @override
  String get sortDateAscending => 'Date ascending';

  @override
  String get newestFirst => '(Newest first)';

  @override
  String get oldestFirst => '(Oldest first)';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get nameAscending => 'Name A–Z';

  @override
  String get nameDescending => 'Name Z–A';

  @override
  String selectFilesError(String arg0) {
    return 'Unable to select files: $arg0';
  }

  @override
  String selectArchiveError(String arg0) {
    return 'Unable to select ZIP archive: $arg0';
  }

  @override
  String get exportDateHelp =>
      'Instagram export date (not individual follow dates)';

  @override
  String get cancel => 'Cancel';

  @override
  String get importAction => 'Import';

  @override
  String get everyoneFollowsBack => 'Everyone follows you back! 🎉';

  @override
  String get noProfilesToReview => 'There are no profiles to review.';

  @override
  String get onboardingStep1of5 => 'STEP 1 OF 5';

  @override
  String get privateReportTitle => 'Your report, kept private.';

  @override
  String get privateReportDescription =>
      'InstaLander compares your followers with the accounts you follow to show who doesn\'t follow you back. Everything is processed on your device: you don\'t need to log into Instagram or share your password.';

  @override
  String get onboardingStep2of5 => 'STEP 2 OF 5';

  @override
  String get loadReportTitle => 'Load and explore your report';

  @override
  String get loadReportDescription =>
      'Load your followers and following JSON files, or the ZIP containing them, and select the export date if needed. The Report shows accounts that don\'t follow you back: you can sort them and open their Instagram profiles. For help getting the files, tap “How to export your Instagram information”.';

  @override
  String get onboardingStep3of5 => 'STEP 3 OF 5';

  @override
  String get chooseWhitelistTitle => 'Choose who to keep in your whitelist';

  @override
  String get chooseWhitelistDescription =>
      'Want to keep following someone who doesn\'t follow you back? Add them to your whitelist to exclude them from the Report. In the Whitelist tab, you can search saved profiles and remove them whenever you want.';

  @override
  String get onboardingStep4of5 => 'STEP 4 OF 5';

  @override
  String get timelineIntroTitle => 'Track changes in the timeline';

  @override
  String get timelineIntroDescription =>
      'When you load a new follower list, the app keeps the previous one and compares them. The Timeline shows who is no longer in your followers between two exports, without claiming an exact unfollow date.';

  @override
  String get onboardingStep5of5 => 'STEP 5 OF 5';

  @override
  String get reminderIntroTitle => 'Remember to update your data';

  @override
  String get reminderIntroDescription =>
      'Your report updates when you import new files. In Settings, you can enable a reminder every month, every 3 months or every 6 months to request a new export. The notification is local and works without keeping the app open.';

  @override
  String get exportStep1of4 => 'STEP 1 OF 4';

  @override
  String get accountsCenterTitle => 'Open Accounts Center';

  @override
  String get accountsCenterDescription =>
      'Open Instagram, go to your profile and tap the ≡ menu at the top. Open Accounts Center.';

  @override
  String get exportStep2of4 => 'STEP 2 OF 4';

  @override
  String get requestDataTitle => 'Request a copy of your data';

  @override
  String get requestDataDescription =>
      'Open “Your information and permissions” and choose “Export your information”, then “Create export”. Select your Instagram account.';

  @override
  String get exportStep3of4 => 'STEP 3 OF 4';

  @override
  String get chooseJsonTitle => 'Choose JSON format';

  @override
  String get chooseJsonDescription =>
      'Select “Export to device”. In the export options, choose JSON format and submit the request. Menu names may vary slightly depending on your Instagram version.';

  @override
  String get exportStep4of4 => 'STEP 4 OF 4';

  @override
  String get downloadArchiveTitle => 'Download and extract the archive';

  @override
  String get downloadArchiveDescription =>
      'When Instagram tells you the export is ready, download the ZIP. Load the archive directly into the app, or extract it and select all followers_*.json and following_*.json files, usually in the followers_and_following folder.';

  @override
  String saveOnboardingError(String arg0) {
    return 'Unable to save completion: $arg0';
  }

  @override
  String get back => 'Back';

  @override
  String get backToReport => 'Back to report';

  @override
  String get startApp => 'Continue to the app';

  @override
  String get next => 'Next';

  @override
  String get oneTapToDeveloper => 'One more tap to enable developer mode';

  @override
  String tapsToDeveloper(String arg0) {
    return '$arg0 more taps to enable developer mode';
  }

  @override
  String get enablingDeveloper => 'Enabling developer mode…';

  @override
  String get developerEnabled => 'Developer mode enabled';

  @override
  String get developerEnableError =>
      'Unable to enable developer mode. Try again.';

  @override
  String get appearance => 'Appearance';

  @override
  String get materialThemeDescription => 'Material 3 layout and components';

  @override
  String get oneUiThemeDescription => 'One UI interface with pill navigation';

  @override
  String get brightness => 'Brightness';

  @override
  String get brightnessDescription =>
      'Choose a fixed brightness or follow your device.';

  @override
  String get system => 'System';

  @override
  String get appIcon => 'App icon';

  @override
  String get lightIcon => 'Light icon';

  @override
  String get lightIconDescription => 'Original icon with a light background';

  @override
  String get darkIconTitle => 'Dark icon';

  @override
  String get darkIconDescription => 'Variant with a dark background';

  @override
  String get behavior => 'Behavior';

  @override
  String get openProfilesInBrowser => 'Open profiles in the browser';

  @override
  String get openBrowserDescription => 'Use your device\'s default browser.';

  @override
  String get openInstagramDescription =>
      'Use the Instagram app, or the browser if it isn\'t installed.';

  @override
  String get savePreferenceError => 'Unable to save the preference.';

  @override
  String get autoWhitelist => 'Automatic whitelist on import';

  @override
  String get autoWhitelistDescription =>
      'From the second follower export, treat accounts that don\'t follow you back as already reviewed and add them to the whitelist.';

  @override
  String get reminders => 'Reminders';

  @override
  String get instagramReminder => 'Instagram reminder';

  @override
  String get reminderDescription =>
      'Remember to request a download of your information. Local notification; no need to keep the app open.';

  @override
  String get androidOnly => 'Available in the Android app.';

  @override
  String get allowReminderNotifications =>
      'Allow notifications in system settings to enable reminders.';

  @override
  String setReminderError(String arg0) {
    return 'Unable to set the reminder: $arg0';
  }

  @override
  String saveReminderFrequencyError(String arg0) {
    return 'Unable to save the frequency: $arg0';
  }

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get project => 'Project';

  @override
  String get advertisingPrivacy => 'Advertising privacy';

  @override
  String get manageConsent => 'Manage consent preferences';

  @override
  String get noConsentOptions =>
      'Advertising consent options are not available at the moment.';

  @override
  String get cannotOpenRepository => 'Unable to open the repository';

  @override
  String get testNotificationScheduled => 'Test notification scheduled.';

  @override
  String get testNotificationSent => 'Test notification sent.';

  @override
  String get allowTestNotifications =>
      'Allow InstaLander notifications in system settings.';

  @override
  String get testNotificationError =>
      'Unable to send or schedule the test notification.';

  @override
  String testDataAdded(String arg0) {
    return 'Test data added: $arg0';
  }

  @override
  String get buildMode => 'Build mode';

  @override
  String get debugDataDescription =>
      'Generate random profiles with the debug_ prefix. Test data is temporary: it disappears when you restart or import new JSON files. Imported data is preserved.';

  @override
  String get advertising => 'Advertising';

  @override
  String get advertisingDescription => 'Show ads after the required consent.';

  @override
  String get populateTimeline => 'Populate timeline';

  @override
  String get populateTimelineDescription =>
      'Add sample intervals and unfollows';

  @override
  String get populateWhitelist => 'Populate whitelist';

  @override
  String get populateWhitelistDescription =>
      'Add sample profiles to the whitelist';

  @override
  String get populateReport => 'Populate report';

  @override
  String get populateReportDescription =>
      'Generate random followers and following';

  @override
  String get sendTestNotification => 'Send test notification';

  @override
  String get sendTestNotificationDescription =>
      'Show a notification on your device now';

  @override
  String get scheduleTestNotification => 'Schedule test notification';

  @override
  String get scheduleTestNotificationDescription => 'Choose any delay';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataDescription =>
      'Remove imported files, timeline, whitelist, reminders and preferences';

  @override
  String changeIconError(String arg0) {
    return 'Unable to change the icon: $arg0';
  }

  @override
  String get clearAllDataTitle => 'Clear all data?';

  @override
  String get clearAllDataConfirmation =>
      'Imported files, timeline, reminder, whitelist, reviewed profiles and preferences will be deleted. This cannot be undone.';

  @override
  String get clearEverything => 'Clear everything';

  @override
  String clearAllDataError(String arg0) {
    return 'Unable to clear data: $arg0';
  }

  @override
  String get timelineDescription =>
      'Accounts no longer in your followers between export dates. The interval does not indicate the exact day of an unfollow. Includes whitelisted profiles.';

  @override
  String get timelineEmpty =>
      'Load two follower exports to start your timeline.';

  @override
  String get noUnfollows => 'No unfollows';

  @override
  String get oneLostFollower => '1 profile no longer following you';

  @override
  String lostFollowers(String arg0) {
    return '$arg0 profiles no longer following you';
  }

  @override
  String get exportComparison => 'Export comparison';

  @override
  String get estimatedDate => 'Start date estimated from the old JSON file.';

  @override
  String dateInterval(String arg0, String arg1) {
    return 'From $arg0 to $arg1';
  }

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get whitelistCountLabel => 'Whitelisted profiles:';

  @override
  String get whitelistCountSemantics => 'Whitelisted profiles';

  @override
  String get listView => 'List';

  @override
  String get gridView => 'Grid';

  @override
  String get clearWhitelist => 'Clear whitelist';

  @override
  String get searchProfile => 'Search profiles';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noProfilesFound => 'No profiles found';

  @override
  String get emptyWhitelist => 'Your whitelist is empty';

  @override
  String get emptyWhitelistDescription =>
      'Add profiles to your whitelist to exclude them\nfrom the non-follower list.\n\nYou can add profiles from the Report\nby tapping the heart icon\non a profile\'s card.';

  @override
  String get openProfile => 'Open profile';

  @override
  String get removeFromWhitelist => 'Remove from whitelist';

  @override
  String get remove => 'Remove';

  @override
  String get excludedFromReport => 'Excluded from the report';

  @override
  String get openInstagramProfile => 'Open Instagram profile';

  @override
  String get clearWhitelistConfirmation =>
      'Are you sure you want to remove every profile from your whitelist? This cannot be undone.';

  @override
  String get clearWhitelistAction => 'Clear all';

  @override
  String duplicateArchiveFile(String arg0) {
    return 'Duplicate file name in archive: $arg0';
  }

  @override
  String unreadableArchiveFile(String arg0) {
    return 'Unable to read $arg0 in the archive';
  }

  @override
  String get noArchiveFiles =>
      'No followers*.json or following*.json files were found in the archive';

  @override
  String get pickJsonTitle =>
      'Select Instagram JSON files (followers_*.json, following_*.json)';

  @override
  String get pickArchiveTitle => 'Select your Instagram ZIP archive';

  @override
  String get selectValidFiles => 'Select followers*.json or following*.json';

  @override
  String get chronologicalImportError =>
      'The date must be the same as or later than the last import.';

  @override
  String get invalidProfileMatch => 'Invalid or duplicate profile match.';

  @override
  String invalidInstagramFormat(String arg0) {
    return 'Invalid Instagram format: $arg0';
  }

  @override
  String unrecognizedProfiles(String arg0) {
    return 'No recognizable profiles in $arg0';
  }

  @override
  String get notificationDelay => 'Delay';

  @override
  String get invalidNotificationDelay => 'Enter a valid positive delay.';

  @override
  String get timeUnit => 'Time unit';

  @override
  String get milliseconds => 'Milliseconds';

  @override
  String get seconds => 'Seconds';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Hours';

  @override
  String get days => 'Days';

  @override
  String get notificationDelayDescription =>
      'Decimal values are accepted. A new schedule replaces the previous test notification. Android may delay delivery to save battery.';

  @override
  String get schedule => 'Schedule';

  @override
  String get ghostProfilesTitle => 'Possible “ghost” profiles';

  @override
  String get ghostProfilesDescription =>
      'Instagram JSON exports may contain “ghost” profiles: accounts you no longer follow or that have been deleted.\n\nThese inconsistencies come from Instagram\'s data, not an app error. InstaLander processes the information in the files you upload.';

  @override
  String get gotIt => 'Got it';

  @override
  String get ad => 'Ad';

  @override
  String get adUnavailable => 'Ad unavailable';

  @override
  String get everyMonth => 'Every month';

  @override
  String get everyThreeMonths => 'Every 3 months';

  @override
  String get everySixMonths => 'Every 6 months';

  @override
  String get required => 'Required';

  @override
  String get setUpReport => 'Set up your report';

  @override
  String get setUpReportDescription =>
      'To get started, add your Instagram JSON files containing your followers and the accounts you follow.';

  @override
  String get requiredFiles => 'REQUIRED FILES';

  @override
  String get standardJson => 'Standard JSON format';

  @override
  String get exportGuide => 'How to export your Instagram information';

  @override
  String get loadJson => 'Load JSON';

  @override
  String get loadZip => 'Load ZIP archive';

  @override
  String get reviewCountLabel => 'To review:';

  @override
  String get reviewCountSemantics => 'Profiles to review';

  @override
  String get possibleUsernameChanges => 'Possible username changes';

  @override
  String get usernameChangesDescription =>
      'These profiles share the same follow timestamp. They might be the same person, but this isn\'t certain. Only select matches you recognize; the rest will remain separate.';

  @override
  String followDate(String arg0) {
    return 'Followed: $arg0';
  }

  @override
  String get newUsername => 'New username';

  @override
  String get noMatch => 'Don\'t match';

  @override
  String get cancelImport => 'Cancel import';

  @override
  String get ignoreAll => 'Ignore all';

  @override
  String get confirmImport => 'Confirm and import';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get profileDetails => 'Profile details';

  @override
  String get followedOn => 'Followed on';

  @override
  String get doesNotFollowBack => 'Doesn\'t follow you back';

  @override
  String get dragToSelect => 'Drag your finger over an action to select it';

  @override
  String get manageWhitelist => '📋 Manage whitelist';

  @override
  String get yourWhitelist => 'Your whitelist';

  @override
  String get whitelistIsEmpty => 'Your whitelist is empty.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System (automatic)';

  @override
  String get languageDescription =>
      'Choose the app language or follow your phone.';

  @override
  String missingFileDescription(String arg0, String arg1, String arg2) {
    return 'We found your $arg0 file. To create your report, also load the $arg1 file ($arg2).';
  }

  @override
  String removeWhitelistConfirmation(String arg0) {
    return 'Remove \"$arg0\" from your whitelist?\nIt will appear in the non-follower list again.';
  }

  @override
  String get hideDebug => 'Hide debug options';

  @override
  String get hideDebugDescription =>
      'You can show them again by tapping the version 10 times.';

  @override
  String get debugHidden => 'Debug options hidden.';
}
