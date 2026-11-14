import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @sortDateDescendingLong.
  ///
  /// In it, this message translates to:
  /// **'Data decrescente (Più recenti prima)'**
  String get sortDateDescendingLong;

  /// No description provided for @sortDateAscendingLong.
  ///
  /// In it, this message translates to:
  /// **'Data crescente (Più vecchi prima)'**
  String get sortDateAscendingLong;

  /// No description provided for @sortAlphabeticalAscending.
  ///
  /// In it, this message translates to:
  /// **'Alfabetico (A-Z)'**
  String get sortAlphabeticalAscending;

  /// No description provided for @sortAlphabeticalDescending.
  ///
  /// In it, this message translates to:
  /// **'Alfabetico (Z-A)'**
  String get sortAlphabeticalDescending;

  /// No description provided for @cannotSavePreference.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare la preferenza'**
  String get cannotSavePreference;

  /// No description provided for @initializationError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'inizializzazione: {arg0}'**
  String initializationError(String arg0);

  /// No description provided for @deleteDataError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l’eliminazione dei dati: {arg0}'**
  String deleteDataError(String arg0);

  /// No description provided for @loadFilesError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il caricamento dei file: {arg0}'**
  String loadFilesError(String arg0);

  /// No description provided for @loadArchiveError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il caricamento dell’archivio ZIP: {arg0}'**
  String loadArchiveError(String arg0);

  /// No description provided for @saveWhitelistError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare la whitelist: {arg0}'**
  String saveWhitelistError(String arg0);

  /// No description provided for @originalIcon.
  ///
  /// In it, this message translates to:
  /// **'Originale'**
  String get originalIcon;

  /// No description provided for @darkIcon.
  ///
  /// In it, this message translates to:
  /// **'Scura'**
  String get darkIcon;

  /// No description provided for @systemDefault.
  ///
  /// In it, this message translates to:
  /// **'Predefinito di sistema'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get dark;

  /// No description provided for @cannotOpenProfile.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il profilo.'**
  String get cannotOpenProfile;

  /// No description provided for @report.
  ///
  /// In it, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @timeline.
  ///
  /// In it, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @whitelist.
  ///
  /// In it, this message translates to:
  /// **'Whitelist'**
  String get whitelist;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @reportTitlePrefix.
  ///
  /// In it, this message translates to:
  /// **'Il tuo '**
  String get reportTitlePrefix;

  /// No description provided for @reportTitleEmphasis.
  ///
  /// In it, this message translates to:
  /// **'unfollower'**
  String get reportTitleEmphasis;

  /// No description provided for @reportTitleSuffix.
  ///
  /// In it, this message translates to:
  /// **' report'**
  String get reportTitleSuffix;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @followersFileLabel.
  ///
  /// In it, this message translates to:
  /// **'dei follower'**
  String get followersFileLabel;

  /// No description provided for @followingFileLabel.
  ///
  /// In it, this message translates to:
  /// **'dei seguiti'**
  String get followingFileLabel;

  /// No description provided for @missingFile.
  ///
  /// In it, this message translates to:
  /// **'Manca un file'**
  String get missingFile;

  /// No description provided for @loadMissingFile.
  ///
  /// In it, this message translates to:
  /// **'Carica file\n{arg0}'**
  String loadMissingFile(String arg0);

  /// No description provided for @orLoadZip.
  ///
  /// In it, this message translates to:
  /// **'Oppure carica un archivio ZIP'**
  String get orLoadZip;

  /// No description provided for @allDone.
  ///
  /// In it, this message translates to:
  /// **'Tutto a posto!'**
  String get allDone;

  /// No description provided for @sortDateDescending.
  ///
  /// In it, this message translates to:
  /// **'Data decrescente'**
  String get sortDateDescending;

  /// No description provided for @sortDateAscending.
  ///
  /// In it, this message translates to:
  /// **'Data crescente'**
  String get sortDateAscending;

  /// No description provided for @newestFirst.
  ///
  /// In it, this message translates to:
  /// **'(Più recenti prima)'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In it, this message translates to:
  /// **'(Più vecchi prima)'**
  String get oldestFirst;

  /// No description provided for @newest.
  ///
  /// In it, this message translates to:
  /// **'Più recenti'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In it, this message translates to:
  /// **'Più vecchi'**
  String get oldest;

  /// No description provided for @nameAscending.
  ///
  /// In it, this message translates to:
  /// **'Nome A-Z'**
  String get nameAscending;

  /// No description provided for @nameDescending.
  ///
  /// In it, this message translates to:
  /// **'Nome Z-A'**
  String get nameDescending;

  /// No description provided for @selectFilesError.
  ///
  /// In it, this message translates to:
  /// **'Errore selezione file: {arg0}'**
  String selectFilesError(String arg0);

  /// No description provided for @selectArchiveError.
  ///
  /// In it, this message translates to:
  /// **'Errore selezione archivio ZIP: {arg0}'**
  String selectArchiveError(String arg0);

  /// No description provided for @exportDateHelp.
  ///
  /// In it, this message translates to:
  /// **'Data dell’esportazione Instagram (non la data dei singoli follow)'**
  String get exportDateHelp;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @importAction.
  ///
  /// In it, this message translates to:
  /// **'Importa'**
  String get importAction;

  /// No description provided for @everyoneFollowsBack.
  ///
  /// In it, this message translates to:
  /// **'Tutti ricambiano il follow! 🎉'**
  String get everyoneFollowsBack;

  /// No description provided for @noProfilesToReview.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono profili da controllare.'**
  String get noProfilesToReview;

  /// No description provided for @onboardingStep1of5.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 1 DI 5'**
  String get onboardingStep1of5;

  /// No description provided for @privateReportTitle.
  ///
  /// In it, this message translates to:
  /// **'Il tuo report, privato.'**
  String get privateReportTitle;

  /// No description provided for @privateReportDescription.
  ///
  /// In it, this message translates to:
  /// **'InstaLander confronta i tuoi follower con i profili che segui per mostrarti chi non ricambia il follow. Il confronto avviene sul dispositivo: non serve accedere al tuo account Instagram né fornire la password.'**
  String get privateReportDescription;

  /// No description provided for @onboardingStep2of5.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 2 DI 5'**
  String get onboardingStep2of5;

  /// No description provided for @loadReportTitle.
  ///
  /// In it, this message translates to:
  /// **'Carica e consulta il report'**
  String get loadReportTitle;

  /// No description provided for @loadReportDescription.
  ///
  /// In it, this message translates to:
  /// **'Carica i JSON di followers e following, oppure lo ZIP che li contiene, e indica la data dell’esportazione. Nel Report trovi i profili che non ti seguono: puoi ordinarli e aprirli su Instagram. Se ti servono i file, trovi una guida nel pulsante “Come esportare le informazioni da Instagram”.'**
  String get loadReportDescription;

  /// No description provided for @onboardingStep3of5.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 3 DI 5'**
  String get onboardingStep3of5;

  /// No description provided for @chooseWhitelistTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli chi tenere nella whitelist'**
  String get chooseWhitelistTitle;

  /// No description provided for @chooseWhitelistDescription.
  ///
  /// In it, this message translates to:
  /// **'Vuoi continuare a seguire un profilo anche se non ti segue? Aggiungilo alla whitelist per escluderlo dal Report. Nella scheda Whitelist puoi cercare i profili salvati e rimuoverli quando vuoi.'**
  String get chooseWhitelistDescription;

  /// No description provided for @onboardingStep4of5.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 4 DI 5'**
  String get onboardingStep4of5;

  /// No description provided for @timelineIntroTitle.
  ///
  /// In it, this message translates to:
  /// **'Segui i cambiamenti nella timeline'**
  String get timelineIntroTitle;

  /// No description provided for @timelineIntroDescription.
  ///
  /// In it, this message translates to:
  /// **'Quando carichi una nuova lista dei follower, l’app conserva quella precedente e le confronta. La Timeline mostra chi non compare più tra i follower nell’intervallo tra le due esportazioni, senza indicare il giorno esatto dell’unfollow.'**
  String get timelineIntroDescription;

  /// No description provided for @onboardingStep5of5.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 5 DI 5'**
  String get onboardingStep5of5;

  /// No description provided for @reminderIntroTitle.
  ///
  /// In it, this message translates to:
  /// **'Ricordati di aggiornare i dati'**
  String get reminderIntroTitle;

  /// No description provided for @reminderIntroDescription.
  ///
  /// In it, this message translates to:
  /// **'Il report si aggiorna quando importi nuovi file. Nelle Impostazioni puoi attivare un promemoria ogni mese, ogni 3 mesi o ogni 6 mesi per richiedere una nuova esportazione. La notifica è locale e non richiede di mantenere l’app attiva.'**
  String get reminderIntroDescription;

  /// No description provided for @exportStep1of4.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 1 DI 4'**
  String get exportStep1of4;

  /// No description provided for @accountsCenterTitle.
  ///
  /// In it, this message translates to:
  /// **'Apri il Centro gestione account'**
  String get accountsCenterTitle;

  /// No description provided for @accountsCenterDescription.
  ///
  /// In it, this message translates to:
  /// **'Apri Instagram, vai sul tuo profilo e tocca il menu ≡ in alto. Entra nel Centro gestione account.'**
  String get accountsCenterDescription;

  /// No description provided for @exportStep2of4.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 2 DI 4'**
  String get exportStep2of4;

  /// No description provided for @requestDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Richiedi una copia dei dati'**
  String get requestDataTitle;

  /// No description provided for @requestDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Apri “Le tue informazioni e autorizzazioni” e scegli “Esporta le tue informazioni”, poi “Crea esportazione”. Seleziona il tuo account Instagram.'**
  String get requestDataDescription;

  /// No description provided for @exportStep3of4.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 3 DI 4'**
  String get exportStep3of4;

  /// No description provided for @chooseJsonTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli il formato JSON'**
  String get chooseJsonTitle;

  /// No description provided for @chooseJsonDescription.
  ///
  /// In it, this message translates to:
  /// **'Seleziona “Esporta sul dispositivo”. Nelle opzioni dell’esportazione scegli il formato JSON e invia la richiesta. I nomi delle voci possono variare leggermente in base alla versione di Instagram.'**
  String get chooseJsonDescription;

  /// No description provided for @exportStep4of4.
  ///
  /// In it, this message translates to:
  /// **'PASSAGGIO 4 DI 4'**
  String get exportStep4of4;

  /// No description provided for @downloadArchiveTitle.
  ///
  /// In it, this message translates to:
  /// **'Scarica ed estrai l’archivio'**
  String get downloadArchiveTitle;

  /// No description provided for @downloadArchiveDescription.
  ///
  /// In it, this message translates to:
  /// **'Quando Instagram ti avvisa che l’esportazione è pronta, scarica lo ZIP. Puoi caricare direttamente l’archivio nell’app oppure estrarlo e selezionare tutti i file followers_*.json e following_*.json, di solito nella cartella followers_and_following.'**
  String get downloadArchiveDescription;

  /// No description provided for @saveOnboardingError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare il completamento: {arg0}'**
  String saveOnboardingError(String arg0);

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @backToReport.
  ///
  /// In it, this message translates to:
  /// **'Torna al report'**
  String get backToReport;

  /// No description provided for @startApp.
  ///
  /// In it, this message translates to:
  /// **'Procedi nell\'app'**
  String get startApp;

  /// No description provided for @next.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get next;

  /// No description provided for @oneTapToDeveloper.
  ///
  /// In it, this message translates to:
  /// **'Ancora un tocco per attivare la modalità sviluppatore'**
  String get oneTapToDeveloper;

  /// No description provided for @tapsToDeveloper.
  ///
  /// In it, this message translates to:
  /// **'Ancora {arg0} tocchi per attivare la modalità sviluppatore'**
  String tapsToDeveloper(String arg0);

  /// No description provided for @enablingDeveloper.
  ///
  /// In it, this message translates to:
  /// **'Attivazione della modalità sviluppatore…'**
  String get enablingDeveloper;

  /// No description provided for @developerEnabled.
  ///
  /// In it, this message translates to:
  /// **'Modalità sviluppatore attivata'**
  String get developerEnabled;

  /// No description provided for @developerEnableError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile attivare la modalità sviluppatore. Riprova.'**
  String get developerEnableError;

  /// No description provided for @appearance.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get appearance;

  /// No description provided for @materialThemeDescription.
  ///
  /// In it, this message translates to:
  /// **'Layout e componenti Material 3'**
  String get materialThemeDescription;

  /// No description provided for @oneUiThemeDescription.
  ///
  /// In it, this message translates to:
  /// **'Interfaccia One UI con navigazione a pillola'**
  String get oneUiThemeDescription;

  /// No description provided for @brightness.
  ///
  /// In it, this message translates to:
  /// **'Luminosità'**
  String get brightness;

  /// No description provided for @brightnessDescription.
  ///
  /// In it, this message translates to:
  /// **'Scegli una luminosità fissa oppure segui il dispositivo.'**
  String get brightnessDescription;

  /// No description provided for @system.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @appIcon.
  ///
  /// In it, this message translates to:
  /// **'Icona dell’app'**
  String get appIcon;

  /// No description provided for @lightIcon.
  ///
  /// In it, this message translates to:
  /// **'Icona chiara'**
  String get lightIcon;

  /// No description provided for @lightIconDescription.
  ///
  /// In it, this message translates to:
  /// **'Icona originale con sfondo chiaro'**
  String get lightIconDescription;

  /// No description provided for @darkIconTitle.
  ///
  /// In it, this message translates to:
  /// **'Icona scura'**
  String get darkIconTitle;

  /// No description provided for @darkIconDescription.
  ///
  /// In it, this message translates to:
  /// **'Variante con sfondo scuro'**
  String get darkIconDescription;

  /// No description provided for @behavior.
  ///
  /// In it, this message translates to:
  /// **'Comportamento'**
  String get behavior;

  /// No description provided for @openProfilesInBrowser.
  ///
  /// In it, this message translates to:
  /// **'Apri i profili nel browser'**
  String get openProfilesInBrowser;

  /// No description provided for @openBrowserDescription.
  ///
  /// In it, this message translates to:
  /// **'Usa il browser predefinito del dispositivo.'**
  String get openBrowserDescription;

  /// No description provided for @openInstagramDescription.
  ///
  /// In it, this message translates to:
  /// **'Usa l’app Instagram; se non è installata, usa il browser.'**
  String get openInstagramDescription;

  /// No description provided for @savePreferenceError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare la preferenza.'**
  String get savePreferenceError;

  /// No description provided for @autoWhitelist.
  ///
  /// In it, this message translates to:
  /// **'Whitelist automatica all’importazione'**
  String get autoWhitelist;

  /// No description provided for @autoWhitelistDescription.
  ///
  /// In it, this message translates to:
  /// **'Dalla seconda esportazione dei follower, considera già controllati i profili che non ricambiano il follow e aggiungili alla whitelist.'**
  String get autoWhitelistDescription;

  /// No description provided for @reminders.
  ///
  /// In it, this message translates to:
  /// **'Promemoria'**
  String get reminders;

  /// No description provided for @instagramReminder.
  ///
  /// In it, this message translates to:
  /// **'Promemoria Instagram'**
  String get instagramReminder;

  /// No description provided for @reminderDescription.
  ///
  /// In it, this message translates to:
  /// **'Ricorda di richiedere il download delle tue informazioni. Notifica locale, senza mantenere l’app attiva.'**
  String get reminderDescription;

  /// No description provided for @androidOnly.
  ///
  /// In it, this message translates to:
  /// **'Disponibile nell’app Android.'**
  String get androidOnly;

  /// No description provided for @allowReminderNotifications.
  ///
  /// In it, this message translates to:
  /// **'Consenti le notifiche nelle impostazioni di sistema per attivare il promemoria.'**
  String get allowReminderNotifications;

  /// No description provided for @setReminderError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile impostare il promemoria: {arg0}'**
  String setReminderError(String arg0);

  /// No description provided for @saveReminderFrequencyError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare la frequenza: {arg0}'**
  String saveReminderFrequencyError(String arg0);

  /// No description provided for @about.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get about;

  /// No description provided for @version.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get version;

  /// No description provided for @project.
  ///
  /// In it, this message translates to:
  /// **'Progetto'**
  String get project;

  /// No description provided for @advertisingPrivacy.
  ///
  /// In it, this message translates to:
  /// **'Privacy pubblicitaria'**
  String get advertisingPrivacy;

  /// No description provided for @manageConsent.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le preferenze di consenso'**
  String get manageConsent;

  /// No description provided for @noConsentOptions.
  ///
  /// In it, this message translates to:
  /// **'Al momento non sono disponibili opzioni di consenso pubblicitario.'**
  String get noConsentOptions;

  /// No description provided for @cannotOpenRepository.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire la repository'**
  String get cannotOpenRepository;

  /// No description provided for @testNotificationScheduled.
  ///
  /// In it, this message translates to:
  /// **'Notifica di prova programmata.'**
  String get testNotificationScheduled;

  /// No description provided for @testNotificationSent.
  ///
  /// In it, this message translates to:
  /// **'Notifica di prova inviata.'**
  String get testNotificationSent;

  /// No description provided for @allowTestNotifications.
  ///
  /// In it, this message translates to:
  /// **'Consenti le notifiche di InstaLander nelle impostazioni di sistema.'**
  String get allowTestNotifications;

  /// No description provided for @testNotificationError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile inviare o programmare la notifica di prova.'**
  String get testNotificationError;

  /// No description provided for @testDataAdded.
  ///
  /// In it, this message translates to:
  /// **'Dati di prova aggiunti: {arg0}'**
  String testDataAdded(String arg0);

  /// No description provided for @buildMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità di compilazione'**
  String get buildMode;

  /// No description provided for @debugDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Genera profili casuali con prefisso debug_. I dati di prova sono temporanei: scompaiono al riavvio o quando importi nuovi JSON. I dati importati restano conservati.'**
  String get debugDataDescription;

  /// No description provided for @advertising.
  ///
  /// In it, this message translates to:
  /// **'Pubblicità'**
  String get advertising;

  /// No description provided for @advertisingDescription.
  ///
  /// In it, this message translates to:
  /// **'Mostra gli annunci nel report, dopo il consenso richiesto.'**
  String get advertisingDescription;

  /// No description provided for @populateTimeline.
  ///
  /// In it, this message translates to:
  /// **'Popola timeline'**
  String get populateTimeline;

  /// No description provided for @populateTimelineDescription.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi intervalli e unfollow di prova'**
  String get populateTimelineDescription;

  /// No description provided for @populateWhitelist.
  ///
  /// In it, this message translates to:
  /// **'Popola whitelist'**
  String get populateWhitelist;

  /// No description provided for @populateWhitelistDescription.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi profili di prova alla whitelist'**
  String get populateWhitelistDescription;

  /// No description provided for @populateReport.
  ///
  /// In it, this message translates to:
  /// **'Popola report'**
  String get populateReport;

  /// No description provided for @populateReportDescription.
  ///
  /// In it, this message translates to:
  /// **'Genera follower e seguiti di prova'**
  String get populateReportDescription;

  /// No description provided for @sendTestNotification.
  ///
  /// In it, this message translates to:
  /// **'Invia notifica di prova'**
  String get sendTestNotification;

  /// No description provided for @sendTestNotificationDescription.
  ///
  /// In it, this message translates to:
  /// **'Mostra subito una notifica sul dispositivo'**
  String get sendTestNotificationDescription;

  /// No description provided for @scheduleTestNotification.
  ///
  /// In it, this message translates to:
  /// **'Programma notifica di prova'**
  String get scheduleTestNotification;

  /// No description provided for @scheduleTestNotificationDescription.
  ///
  /// In it, this message translates to:
  /// **'Scegli liberamente il tempo di attesa'**
  String get scheduleTestNotificationDescription;

  /// No description provided for @clearAllData.
  ///
  /// In it, this message translates to:
  /// **'Cancella tutti i dati'**
  String get clearAllData;

  /// No description provided for @clearAllDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Rimuove file importati, timeline, whitelist, promemoria e preferenze'**
  String get clearAllDataDescription;

  /// No description provided for @changeIconError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile cambiare icona: {arg0}'**
  String changeIconError(String arg0);

  /// No description provided for @clearAllDataTitle.
  ///
  /// In it, this message translates to:
  /// **'Cancellare tutti i dati?'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataConfirmation.
  ///
  /// In it, this message translates to:
  /// **'Verranno eliminati i file importati, la timeline, il promemoria, la whitelist, i profili controllati e le preferenze. L’operazione non può essere annullata.'**
  String get clearAllDataConfirmation;

  /// No description provided for @clearEverything.
  ///
  /// In it, this message translates to:
  /// **'Cancella tutto'**
  String get clearEverything;

  /// No description provided for @clearAllDataError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile cancellare i dati: {arg0}'**
  String clearAllDataError(String arg0);

  /// No description provided for @timelineDescription.
  ///
  /// In it, this message translates to:
  /// **'Chi non compare più nei follower, tra le date delle esportazioni. L’intervallo non indica il giorno esatto dell’unfollow. Include i profili in whitelist.'**
  String get timelineDescription;

  /// No description provided for @timelineEmpty.
  ///
  /// In it, this message translates to:
  /// **'Carica due esportazioni dei follower per iniziare la timeline.'**
  String get timelineEmpty;

  /// No description provided for @noUnfollows.
  ///
  /// In it, this message translates to:
  /// **'Nessun unfollow'**
  String get noUnfollows;

  /// No description provided for @oneLostFollower.
  ///
  /// In it, this message translates to:
  /// **'1 profilo non più tra i follower'**
  String get oneLostFollower;

  /// No description provided for @lostFollowers.
  ///
  /// In it, this message translates to:
  /// **'{arg0} profili non più tra i follower'**
  String lostFollowers(String arg0);

  /// No description provided for @exportComparison.
  ///
  /// In it, this message translates to:
  /// **'Confronto tra esportazioni'**
  String get exportComparison;

  /// No description provided for @estimatedDate.
  ///
  /// In it, this message translates to:
  /// **'Data iniziale stimata dal vecchio JSON.'**
  String get estimatedDate;

  /// No description provided for @dateInterval.
  ///
  /// In it, this message translates to:
  /// **'Dal {arg0} al {arg1}'**
  String dateInterval(String arg0, String arg1);

  /// No description provided for @from.
  ///
  /// In it, this message translates to:
  /// **'dal'**
  String get from;

  /// No description provided for @to.
  ///
  /// In it, this message translates to:
  /// **'al'**
  String get to;

  /// No description provided for @whitelistCountLabel.
  ///
  /// In it, this message translates to:
  /// **'Profili in whitelist:'**
  String get whitelistCountLabel;

  /// No description provided for @whitelistCountSemantics.
  ///
  /// In it, this message translates to:
  /// **'Profili in whitelist'**
  String get whitelistCountSemantics;

  /// No description provided for @listView.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In it, this message translates to:
  /// **'Griglia'**
  String get gridView;

  /// No description provided for @clearWhitelist.
  ///
  /// In it, this message translates to:
  /// **'Svuota whitelist'**
  String get clearWhitelist;

  /// No description provided for @searchProfile.
  ///
  /// In it, this message translates to:
  /// **'Cerca un profilo'**
  String get searchProfile;

  /// No description provided for @clearSearch.
  ///
  /// In it, this message translates to:
  /// **'Cancella ricerca'**
  String get clearSearch;

  /// No description provided for @noProfilesFound.
  ///
  /// In it, this message translates to:
  /// **'Nessun profilo trovato'**
  String get noProfilesFound;

  /// No description provided for @emptyWhitelist.
  ///
  /// In it, this message translates to:
  /// **'Whitelist vuota'**
  String get emptyWhitelist;

  /// No description provided for @emptyWhitelistDescription.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi profili alla whitelist per escluderli\ndall\'elenco dei non-follower.\n\nPuoi aggiungere profili dalla schermata\nprincipale toccando l\'icona del cuore\nsulla card di un profilo.'**
  String get emptyWhitelistDescription;

  /// No description provided for @openProfile.
  ///
  /// In it, this message translates to:
  /// **'Apri profilo'**
  String get openProfile;

  /// No description provided for @removeFromWhitelist.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dalla whitelist'**
  String get removeFromWhitelist;

  /// No description provided for @remove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi'**
  String get remove;

  /// No description provided for @excludedFromReport.
  ///
  /// In it, this message translates to:
  /// **'Escluso dal report'**
  String get excludedFromReport;

  /// No description provided for @openInstagramProfile.
  ///
  /// In it, this message translates to:
  /// **'Apri profilo Instagram'**
  String get openInstagramProfile;

  /// No description provided for @clearWhitelistConfirmation.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler rimuovere tutti i profili dalla whitelist? Questa azione non può essere annullata.'**
  String get clearWhitelistConfirmation;

  /// No description provided for @clearWhitelistAction.
  ///
  /// In it, this message translates to:
  /// **'Svuota tutto'**
  String get clearWhitelistAction;

  /// No description provided for @duplicateArchiveFile.
  ///
  /// In it, this message translates to:
  /// **'Nome file duplicato nell’archivio: {arg0}'**
  String duplicateArchiveFile(String arg0);

  /// No description provided for @unreadableArchiveFile.
  ///
  /// In it, this message translates to:
  /// **'Impossibile leggere il file {arg0} nell’archivio'**
  String unreadableArchiveFile(String arg0);

  /// No description provided for @noArchiveFiles.
  ///
  /// In it, this message translates to:
  /// **'Nell’archivio non sono stati trovati file followers*.json o following*.json'**
  String get noArchiveFiles;

  /// No description provided for @pickJsonTitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona file JSON di Instagram (followers_*.json, following_*.json)'**
  String get pickJsonTitle;

  /// No description provided for @pickArchiveTitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona l’archivio ZIP di Instagram'**
  String get pickArchiveTitle;

  /// No description provided for @selectValidFiles.
  ///
  /// In it, this message translates to:
  /// **'Seleziona followers*.json o following*.json'**
  String get selectValidFiles;

  /// No description provided for @chronologicalImportError.
  ///
  /// In it, this message translates to:
  /// **'La data deve essere uguale o successiva all’ultima importazione.'**
  String get chronologicalImportError;

  /// No description provided for @invalidProfileMatch.
  ///
  /// In it, this message translates to:
  /// **'Associazione dei profili non valida o duplicata.'**
  String get invalidProfileMatch;

  /// No description provided for @invalidInstagramFormat.
  ///
  /// In it, this message translates to:
  /// **'Formato Instagram non valido: {arg0}'**
  String invalidInstagramFormat(String arg0);

  /// No description provided for @unrecognizedProfiles.
  ///
  /// In it, this message translates to:
  /// **'Nessun profilo riconoscibile in {arg0}'**
  String unrecognizedProfiles(String arg0);

  /// No description provided for @notificationDelay.
  ///
  /// In it, this message translates to:
  /// **'Tempo di attesa'**
  String get notificationDelay;

  /// No description provided for @invalidNotificationDelay.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un tempo positivo valido.'**
  String get invalidNotificationDelay;

  /// No description provided for @timeUnit.
  ///
  /// In it, this message translates to:
  /// **'Unità di tempo'**
  String get timeUnit;

  /// No description provided for @milliseconds.
  ///
  /// In it, this message translates to:
  /// **'Millisecondi'**
  String get milliseconds;

  /// No description provided for @seconds.
  ///
  /// In it, this message translates to:
  /// **'Secondi'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In it, this message translates to:
  /// **'Minuti'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In it, this message translates to:
  /// **'Ore'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In it, this message translates to:
  /// **'Giorni'**
  String get days;

  /// No description provided for @notificationDelayDescription.
  ///
  /// In it, this message translates to:
  /// **'Puoi inserire anche valori decimali. La nuova programmazione sostituisce la precedente notifica di prova. Android può ritardare la consegna per risparmiare batteria.'**
  String get notificationDelayDescription;

  /// No description provided for @schedule.
  ///
  /// In it, this message translates to:
  /// **'Programma'**
  String get schedule;

  /// No description provided for @ghostProfilesTitle.
  ///
  /// In it, this message translates to:
  /// **'Possibili profili “fantasma”'**
  String get ghostProfilesTitle;

  /// No description provided for @ghostProfilesDescription.
  ///
  /// In it, this message translates to:
  /// **'Nei JSON esportati da Instagram possono comparire profili “fantasma”: account che non segui più oppure che sono stati eliminati.\n\nQueste incongruenze dipendono dai dati forniti da Instagram, non da un errore dell’app. InstaLander elabora le informazioni presenti nei file che hai caricato.'**
  String get ghostProfilesDescription;

  /// No description provided for @gotIt.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get gotIt;

  /// No description provided for @ad.
  ///
  /// In it, this message translates to:
  /// **'Annuncio'**
  String get ad;

  /// No description provided for @adUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Annuncio non disponibile'**
  String get adUnavailable;

  /// No description provided for @everyMonth.
  ///
  /// In it, this message translates to:
  /// **'Ogni mese'**
  String get everyMonth;

  /// No description provided for @everyThreeMonths.
  ///
  /// In it, this message translates to:
  /// **'Ogni 3 mesi'**
  String get everyThreeMonths;

  /// No description provided for @everySixMonths.
  ///
  /// In it, this message translates to:
  /// **'Ogni 6 mesi'**
  String get everySixMonths;

  /// No description provided for @required.
  ///
  /// In it, this message translates to:
  /// **'Richiesto'**
  String get required;

  /// No description provided for @setUpReport.
  ///
  /// In it, this message translates to:
  /// **'Configura il report'**
  String get setUpReport;

  /// No description provided for @setUpReportDescription.
  ///
  /// In it, this message translates to:
  /// **'Per iniziare, aggiungi i file JSON di Instagram con i tuoi follower e i profili che segui.'**
  String get setUpReportDescription;

  /// No description provided for @requiredFiles.
  ///
  /// In it, this message translates to:
  /// **'FILE NECESSARI'**
  String get requiredFiles;

  /// No description provided for @standardJson.
  ///
  /// In it, this message translates to:
  /// **'Formato JSON standard'**
  String get standardJson;

  /// No description provided for @exportGuide.
  ///
  /// In it, this message translates to:
  /// **'Come esportare le informazioni da Instagram'**
  String get exportGuide;

  /// No description provided for @loadJson.
  ///
  /// In it, this message translates to:
  /// **'Carica JSON'**
  String get loadJson;

  /// No description provided for @loadZip.
  ///
  /// In it, this message translates to:
  /// **'Carica archivio ZIP'**
  String get loadZip;

  /// No description provided for @reviewCountLabel.
  ///
  /// In it, this message translates to:
  /// **'Da controllare:'**
  String get reviewCountLabel;

  /// No description provided for @reviewCountSemantics.
  ///
  /// In it, this message translates to:
  /// **'Profili da controllare'**
  String get reviewCountSemantics;

  /// No description provided for @possibleUsernameChanges.
  ///
  /// In it, this message translates to:
  /// **'Possibili cambi di username'**
  String get possibleUsernameChanges;

  /// No description provided for @usernameChangesDescription.
  ///
  /// In it, this message translates to:
  /// **'Questi profili hanno lo stesso timestamp di follow. Potrebbero essere la stessa persona, ma non è una certezza. Scegli solo le associazioni che riconosci; le altre resteranno separate.'**
  String get usernameChangesDescription;

  /// No description provided for @followDate.
  ///
  /// In it, this message translates to:
  /// **'Follow: {arg0}'**
  String followDate(String arg0);

  /// No description provided for @newUsername.
  ///
  /// In it, this message translates to:
  /// **'Nuovo username'**
  String get newUsername;

  /// No description provided for @noMatch.
  ///
  /// In it, this message translates to:
  /// **'Non associare'**
  String get noMatch;

  /// No description provided for @cancelImport.
  ///
  /// In it, this message translates to:
  /// **'Annulla importazione'**
  String get cancelImport;

  /// No description provided for @ignoreAll.
  ///
  /// In it, this message translates to:
  /// **'Ignora tutte'**
  String get ignoreAll;

  /// No description provided for @confirmImport.
  ///
  /// In it, this message translates to:
  /// **'Conferma e importa'**
  String get confirmImport;

  /// No description provided for @unknownDate.
  ///
  /// In it, this message translates to:
  /// **'Data sconosciuta'**
  String get unknownDate;

  /// No description provided for @profileDetails.
  ///
  /// In it, this message translates to:
  /// **'Dettagli del profilo'**
  String get profileDetails;

  /// No description provided for @followedOn.
  ///
  /// In it, this message translates to:
  /// **'Seguito il'**
  String get followedOn;

  /// No description provided for @doesNotFollowBack.
  ///
  /// In it, this message translates to:
  /// **'Non ti segue'**
  String get doesNotFollowBack;

  /// No description provided for @dragToSelect.
  ///
  /// In it, this message translates to:
  /// **'Trascina il dito su un’azione per selezionarla'**
  String get dragToSelect;

  /// No description provided for @manageWhitelist.
  ///
  /// In it, this message translates to:
  /// **'📋 Gestisci Whitelist'**
  String get manageWhitelist;

  /// No description provided for @yourWhitelist.
  ///
  /// In it, this message translates to:
  /// **'La tua Whitelist'**
  String get yourWhitelist;

  /// No description provided for @whitelistIsEmpty.
  ///
  /// In it, this message translates to:
  /// **'La whitelist è vuota.'**
  String get whitelistIsEmpty;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema (automatica)'**
  String get languageSystem;

  /// No description provided for @languageDescription.
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua dell’app oppure segui quella del telefono.'**
  String get languageDescription;

  /// No description provided for @missingFileDescription.
  ///
  /// In it, this message translates to:
  /// **'Abbiamo rilevato il file {arg0}. Per creare il report, carica anche il file {arg1} ({arg2}).'**
  String missingFileDescription(String arg0, String arg1, String arg2);

  /// No description provided for @removeWhitelistConfirmation.
  ///
  /// In it, this message translates to:
  /// **'Vuoi rimuovere \"{arg0}\" dalla whitelist?\nTornerà a comparire nell\'elenco dei non-follower.'**
  String removeWhitelistConfirmation(String arg0);

  /// No description provided for @hideDebug.
  ///
  /// In it, this message translates to:
  /// **'Nascondi opzioni di debug'**
  String get hideDebug;

  /// No description provided for @hideDebugDescription.
  ///
  /// In it, this message translates to:
  /// **'Puoi mostrarle di nuovo con 10 tocchi sulla versione.'**
  String get hideDebugDescription;

  /// No description provided for @debugHidden.
  ///
  /// In it, this message translates to:
  /// **'Opzioni di debug nascoste.'**
  String get debugHidden;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
