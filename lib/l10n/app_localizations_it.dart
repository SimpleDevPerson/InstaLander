// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get sortDateDescendingLong => 'Data decrescente (Più recenti prima)';

  @override
  String get sortDateAscendingLong => 'Data crescente (Più vecchi prima)';

  @override
  String get sortAlphabeticalAscending => 'Alfabetico (A-Z)';

  @override
  String get sortAlphabeticalDescending => 'Alfabetico (Z-A)';

  @override
  String get cannotSavePreference => 'Impossibile salvare la preferenza';

  @override
  String initializationError(String arg0) {
    return 'Errore durante l\'inizializzazione: $arg0';
  }

  @override
  String deleteDataError(String arg0) {
    return 'Errore durante l’eliminazione dei dati: $arg0';
  }

  @override
  String loadFilesError(String arg0) {
    return 'Errore durante il caricamento dei file: $arg0';
  }

  @override
  String loadArchiveError(String arg0) {
    return 'Errore durante il caricamento dell’archivio ZIP: $arg0';
  }

  @override
  String saveWhitelistError(String arg0) {
    return 'Impossibile salvare la whitelist: $arg0';
  }

  @override
  String get originalIcon => 'Originale';

  @override
  String get darkIcon => 'Scura';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get cannotOpenProfile => 'Impossibile aprire il profilo.';

  @override
  String get report => 'Report';

  @override
  String get timeline => 'Timeline';

  @override
  String get whitelist => 'Whitelist';

  @override
  String get settings => 'Impostazioni';

  @override
  String get reportTitlePrefix => 'Il tuo ';

  @override
  String get reportTitleEmphasis => 'unfollower';

  @override
  String get reportTitleSuffix => ' report';

  @override
  String get error => 'Errore';

  @override
  String get retry => 'Riprova';

  @override
  String get followersFileLabel => 'dei follower';

  @override
  String get followingFileLabel => 'dei seguiti';

  @override
  String get missingFile => 'Manca un file';

  @override
  String loadMissingFile(String arg0) {
    return 'Carica file\n$arg0';
  }

  @override
  String get orLoadZip => 'Oppure carica un archivio ZIP';

  @override
  String get allDone => 'Tutto a posto!';

  @override
  String get sortDateDescending => 'Data decrescente';

  @override
  String get sortDateAscending => 'Data crescente';

  @override
  String get newestFirst => '(Più recenti prima)';

  @override
  String get oldestFirst => '(Più vecchi prima)';

  @override
  String get newest => 'Più recenti';

  @override
  String get oldest => 'Più vecchi';

  @override
  String get nameAscending => 'Nome A-Z';

  @override
  String get nameDescending => 'Nome Z-A';

  @override
  String selectFilesError(String arg0) {
    return 'Errore selezione file: $arg0';
  }

  @override
  String selectArchiveError(String arg0) {
    return 'Errore selezione archivio ZIP: $arg0';
  }

  @override
  String get exportDateHelp =>
      'Data dell’esportazione Instagram (non la data dei singoli follow)';

  @override
  String get cancel => 'Annulla';

  @override
  String get importAction => 'Importa';

  @override
  String get everyoneFollowsBack => 'Tutti ricambiano il follow! 🎉';

  @override
  String get noProfilesToReview => 'Non ci sono profili da controllare.';

  @override
  String get onboardingStep1of5 => 'PASSAGGIO 1 DI 5';

  @override
  String get privateReportTitle => 'Il tuo report, privato.';

  @override
  String get privateReportDescription =>
      'InstaLander confronta i tuoi follower con i profili che segui per mostrarti chi non ricambia il follow. Il confronto avviene sul dispositivo: non serve accedere al tuo account Instagram né fornire la password.';

  @override
  String get onboardingStep2of5 => 'PASSAGGIO 2 DI 5';

  @override
  String get loadReportTitle => 'Carica e consulta il report';

  @override
  String get loadReportDescription =>
      'Carica i JSON di followers e following, oppure lo ZIP che li contiene, e indica la data dell’esportazione. Nel Report trovi i profili che non ti seguono: puoi ordinarli e aprirli su Instagram. Se ti servono i file, trovi una guida nel pulsante “Come esportare le informazioni da Instagram”.';

  @override
  String get onboardingStep3of5 => 'PASSAGGIO 3 DI 5';

  @override
  String get chooseWhitelistTitle => 'Scegli chi tenere nella whitelist';

  @override
  String get chooseWhitelistDescription =>
      'Vuoi continuare a seguire un profilo anche se non ti segue? Aggiungilo alla whitelist per escluderlo dal Report. Nella scheda Whitelist puoi cercare i profili salvati e rimuoverli quando vuoi.';

  @override
  String get onboardingStep4of5 => 'PASSAGGIO 4 DI 5';

  @override
  String get timelineIntroTitle => 'Segui i cambiamenti nella timeline';

  @override
  String get timelineIntroDescription =>
      'Quando carichi una nuova lista dei follower, l’app conserva quella precedente e le confronta. La Timeline mostra chi non compare più tra i follower nell’intervallo tra le due esportazioni, senza indicare il giorno esatto dell’unfollow.';

  @override
  String get onboardingStep5of5 => 'PASSAGGIO 5 DI 5';

  @override
  String get reminderIntroTitle => 'Ricordati di aggiornare i dati';

  @override
  String get reminderIntroDescription =>
      'Il report si aggiorna quando importi nuovi file. Nelle Impostazioni puoi attivare un promemoria ogni mese, ogni 3 mesi o ogni 6 mesi per richiedere una nuova esportazione. La notifica è locale e non richiede di mantenere l’app attiva.';

  @override
  String get exportStep1of4 => 'PASSAGGIO 1 DI 4';

  @override
  String get accountsCenterTitle => 'Apri il Centro gestione account';

  @override
  String get accountsCenterDescription =>
      'Apri Instagram, vai sul tuo profilo e tocca il menu ≡ in alto. Entra nel Centro gestione account.';

  @override
  String get exportStep2of4 => 'PASSAGGIO 2 DI 4';

  @override
  String get requestDataTitle => 'Richiedi una copia dei dati';

  @override
  String get requestDataDescription =>
      'Apri “Le tue informazioni e autorizzazioni” e scegli “Esporta le tue informazioni”, poi “Crea esportazione”. Seleziona il tuo account Instagram.';

  @override
  String get exportStep3of4 => 'PASSAGGIO 3 DI 4';

  @override
  String get chooseJsonTitle => 'Scegli il formato JSON';

  @override
  String get chooseJsonDescription =>
      'Seleziona “Esporta sul dispositivo”. Nelle opzioni dell’esportazione scegli il formato JSON e invia la richiesta. I nomi delle voci possono variare leggermente in base alla versione di Instagram.';

  @override
  String get exportStep4of4 => 'PASSAGGIO 4 DI 4';

  @override
  String get downloadArchiveTitle => 'Scarica ed estrai l’archivio';

  @override
  String get downloadArchiveDescription =>
      'Quando Instagram ti avvisa che l’esportazione è pronta, scarica lo ZIP. Puoi caricare direttamente l’archivio nell’app oppure estrarlo e selezionare tutti i file followers_*.json e following_*.json, di solito nella cartella followers_and_following.';

  @override
  String saveOnboardingError(String arg0) {
    return 'Impossibile salvare il completamento: $arg0';
  }

  @override
  String get back => 'Indietro';

  @override
  String get backToReport => 'Torna al report';

  @override
  String get startApp => 'Procedi nell\'app';

  @override
  String get next => 'Avanti';

  @override
  String get oneTapToDeveloper =>
      'Ancora un tocco per attivare la modalità sviluppatore';

  @override
  String tapsToDeveloper(String arg0) {
    return 'Ancora $arg0 tocchi per attivare la modalità sviluppatore';
  }

  @override
  String get enablingDeveloper => 'Attivazione della modalità sviluppatore…';

  @override
  String get developerEnabled => 'Modalità sviluppatore attivata';

  @override
  String get developerEnableError =>
      'Impossibile attivare la modalità sviluppatore. Riprova.';

  @override
  String get appearance => 'Aspetto';

  @override
  String get materialThemeDescription => 'Layout e componenti Material 3';

  @override
  String get oneUiThemeDescription =>
      'Interfaccia One UI con navigazione a pillola';

  @override
  String get brightness => 'Luminosità';

  @override
  String get brightnessDescription =>
      'Scegli una luminosità fissa oppure segui il dispositivo.';

  @override
  String get system => 'Sistema';

  @override
  String get appIcon => 'Icona dell’app';

  @override
  String get lightIcon => 'Icona chiara';

  @override
  String get lightIconDescription => 'Icona originale con sfondo chiaro';

  @override
  String get darkIconTitle => 'Icona scura';

  @override
  String get darkIconDescription => 'Variante con sfondo scuro';

  @override
  String get behavior => 'Comportamento';

  @override
  String get openProfilesInBrowser => 'Apri i profili nel browser';

  @override
  String get openBrowserDescription =>
      'Usa il browser predefinito del dispositivo.';

  @override
  String get openInstagramDescription =>
      'Usa l’app Instagram; se non è installata, usa il browser.';

  @override
  String get savePreferenceError => 'Impossibile salvare la preferenza.';

  @override
  String get autoWhitelist => 'Whitelist automatica all’importazione';

  @override
  String get autoWhitelistDescription =>
      'Dalla seconda esportazione dei follower, considera già controllati i profili che non ricambiano il follow e aggiungili alla whitelist.';

  @override
  String get reminders => 'Promemoria';

  @override
  String get instagramReminder => 'Promemoria Instagram';

  @override
  String get reminderDescription =>
      'Ricorda di richiedere il download delle tue informazioni. Notifica locale, senza mantenere l’app attiva.';

  @override
  String get androidOnly => 'Disponibile nell’app Android.';

  @override
  String get allowReminderNotifications =>
      'Consenti le notifiche nelle impostazioni di sistema per attivare il promemoria.';

  @override
  String setReminderError(String arg0) {
    return 'Impossibile impostare il promemoria: $arg0';
  }

  @override
  String saveReminderFrequencyError(String arg0) {
    return 'Impossibile salvare la frequenza: $arg0';
  }

  @override
  String get about => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get project => 'Progetto';

  @override
  String get advertisingPrivacy => 'Privacy pubblicitaria';

  @override
  String get manageConsent => 'Gestisci le preferenze di consenso';

  @override
  String get noConsentOptions =>
      'Al momento non sono disponibili opzioni di consenso pubblicitario.';

  @override
  String get cannotOpenRepository => 'Impossibile aprire la repository';

  @override
  String get testNotificationScheduled => 'Notifica di prova programmata.';

  @override
  String get testNotificationSent => 'Notifica di prova inviata.';

  @override
  String get allowTestNotifications =>
      'Consenti le notifiche di InstaLander nelle impostazioni di sistema.';

  @override
  String get testNotificationError =>
      'Impossibile inviare o programmare la notifica di prova.';

  @override
  String testDataAdded(String arg0) {
    return 'Dati di prova aggiunti: $arg0';
  }

  @override
  String get buildMode => 'Modalità di compilazione';

  @override
  String get debugDataDescription =>
      'Genera profili casuali con prefisso debug_. I dati di prova sono temporanei: scompaiono al riavvio o quando importi nuovi JSON. I dati importati restano conservati.';

  @override
  String get advertising => 'Pubblicità';

  @override
  String get advertisingDescription =>
      'Mostra gli annunci nel report, dopo il consenso richiesto.';

  @override
  String get populateTimeline => 'Popola timeline';

  @override
  String get populateTimelineDescription =>
      'Aggiungi intervalli e unfollow di prova';

  @override
  String get populateWhitelist => 'Popola whitelist';

  @override
  String get populateWhitelistDescription =>
      'Aggiungi profili di prova alla whitelist';

  @override
  String get populateReport => 'Popola report';

  @override
  String get populateReportDescription => 'Genera follower e seguiti di prova';

  @override
  String get sendTestNotification => 'Invia notifica di prova';

  @override
  String get sendTestNotificationDescription =>
      'Mostra subito una notifica sul dispositivo';

  @override
  String get scheduleTestNotification => 'Programma notifica di prova';

  @override
  String get scheduleTestNotificationDescription =>
      'Scegli liberamente il tempo di attesa';

  @override
  String get clearAllData => 'Cancella tutti i dati';

  @override
  String get clearAllDataDescription =>
      'Rimuove file importati, timeline, whitelist, promemoria e preferenze';

  @override
  String changeIconError(String arg0) {
    return 'Impossibile cambiare icona: $arg0';
  }

  @override
  String get clearAllDataTitle => 'Cancellare tutti i dati?';

  @override
  String get clearAllDataConfirmation =>
      'Verranno eliminati i file importati, la timeline, il promemoria, la whitelist, i profili controllati e le preferenze. L’operazione non può essere annullata.';

  @override
  String get clearEverything => 'Cancella tutto';

  @override
  String clearAllDataError(String arg0) {
    return 'Impossibile cancellare i dati: $arg0';
  }

  @override
  String get timelineDescription =>
      'Chi non compare più nei follower, tra le date delle esportazioni. L’intervallo non indica il giorno esatto dell’unfollow. Include i profili in whitelist.';

  @override
  String get timelineEmpty =>
      'Carica due esportazioni dei follower per iniziare la timeline.';

  @override
  String get noUnfollows => 'Nessun unfollow';

  @override
  String get oneLostFollower => '1 profilo non più tra i follower';

  @override
  String lostFollowers(String arg0) {
    return '$arg0 profili non più tra i follower';
  }

  @override
  String get exportComparison => 'Confronto tra esportazioni';

  @override
  String get estimatedDate => 'Data iniziale stimata dal vecchio JSON.';

  @override
  String dateInterval(String arg0, String arg1) {
    return 'Dal $arg0 al $arg1';
  }

  @override
  String get from => 'dal';

  @override
  String get to => 'al';

  @override
  String get whitelistCountLabel => 'Profili in whitelist:';

  @override
  String get whitelistCountSemantics => 'Profili in whitelist';

  @override
  String get listView => 'Lista';

  @override
  String get gridView => 'Griglia';

  @override
  String get clearWhitelist => 'Svuota whitelist';

  @override
  String get searchProfile => 'Cerca un profilo';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get noProfilesFound => 'Nessun profilo trovato';

  @override
  String get emptyWhitelist => 'Whitelist vuota';

  @override
  String get emptyWhitelistDescription =>
      'Aggiungi profili alla whitelist per escluderli\ndall\'elenco dei non-follower.\n\nPuoi aggiungere profili dalla schermata\nprincipale toccando l\'icona del cuore\nsulla card di un profilo.';

  @override
  String get openProfile => 'Apri profilo';

  @override
  String get removeFromWhitelist => 'Rimuovi dalla whitelist';

  @override
  String get remove => 'Rimuovi';

  @override
  String get excludedFromReport => 'Escluso dal report';

  @override
  String get openInstagramProfile => 'Apri profilo Instagram';

  @override
  String get clearWhitelistConfirmation =>
      'Sei sicuro di voler rimuovere tutti i profili dalla whitelist? Questa azione non può essere annullata.';

  @override
  String get clearWhitelistAction => 'Svuota tutto';

  @override
  String duplicateArchiveFile(String arg0) {
    return 'Nome file duplicato nell’archivio: $arg0';
  }

  @override
  String unreadableArchiveFile(String arg0) {
    return 'Impossibile leggere il file $arg0 nell’archivio';
  }

  @override
  String get noArchiveFiles =>
      'Nell’archivio non sono stati trovati file followers*.json o following*.json';

  @override
  String get pickJsonTitle =>
      'Seleziona file JSON di Instagram (followers_*.json, following_*.json)';

  @override
  String get pickArchiveTitle => 'Seleziona l’archivio ZIP di Instagram';

  @override
  String get selectValidFiles => 'Seleziona followers*.json o following*.json';

  @override
  String get chronologicalImportError =>
      'La data deve essere uguale o successiva all’ultima importazione.';

  @override
  String get invalidProfileMatch =>
      'Associazione dei profili non valida o duplicata.';

  @override
  String invalidInstagramFormat(String arg0) {
    return 'Formato Instagram non valido: $arg0';
  }

  @override
  String unrecognizedProfiles(String arg0) {
    return 'Nessun profilo riconoscibile in $arg0';
  }

  @override
  String get notificationDelay => 'Tempo di attesa';

  @override
  String get invalidNotificationDelay => 'Inserisci un tempo positivo valido.';

  @override
  String get timeUnit => 'Unità di tempo';

  @override
  String get milliseconds => 'Millisecondi';

  @override
  String get seconds => 'Secondi';

  @override
  String get minutes => 'Minuti';

  @override
  String get hours => 'Ore';

  @override
  String get days => 'Giorni';

  @override
  String get notificationDelayDescription =>
      'Puoi inserire anche valori decimali. La nuova programmazione sostituisce la precedente notifica di prova. Android può ritardare la consegna per risparmiare batteria.';

  @override
  String get schedule => 'Programma';

  @override
  String get ghostProfilesTitle => 'Possibili profili “fantasma”';

  @override
  String get ghostProfilesDescription =>
      'Nei JSON esportati da Instagram possono comparire profili “fantasma”: account che non segui più oppure che sono stati eliminati.\n\nQueste incongruenze dipendono dai dati forniti da Instagram, non da un errore dell’app. InstaLander elabora le informazioni presenti nei file che hai caricato.';

  @override
  String get gotIt => 'Ho capito';

  @override
  String get ad => 'Annuncio';

  @override
  String get adUnavailable => 'Annuncio non disponibile';

  @override
  String get everyMonth => 'Ogni mese';

  @override
  String get everyThreeMonths => 'Ogni 3 mesi';

  @override
  String get everySixMonths => 'Ogni 6 mesi';

  @override
  String get required => 'Richiesto';

  @override
  String get setUpReport => 'Configura il report';

  @override
  String get setUpReportDescription =>
      'Per iniziare, aggiungi i file JSON di Instagram con i tuoi follower e i profili che segui.';

  @override
  String get requiredFiles => 'FILE NECESSARI';

  @override
  String get standardJson => 'Formato JSON standard';

  @override
  String get exportGuide => 'Come esportare le informazioni da Instagram';

  @override
  String get loadJson => 'Carica JSON';

  @override
  String get loadZip => 'Carica archivio ZIP';

  @override
  String get reviewCountLabel => 'Da controllare:';

  @override
  String get reviewCountSemantics => 'Profili da controllare';

  @override
  String get possibleUsernameChanges => 'Possibili cambi di username';

  @override
  String get usernameChangesDescription =>
      'Questi profili hanno lo stesso timestamp di follow. Potrebbero essere la stessa persona, ma non è una certezza. Scegli solo le associazioni che riconosci; le altre resteranno separate.';

  @override
  String followDate(String arg0) {
    return 'Follow: $arg0';
  }

  @override
  String get newUsername => 'Nuovo username';

  @override
  String get noMatch => 'Non associare';

  @override
  String get cancelImport => 'Annulla importazione';

  @override
  String get ignoreAll => 'Ignora tutte';

  @override
  String get confirmImport => 'Conferma e importa';

  @override
  String get unknownDate => 'Data sconosciuta';

  @override
  String get profileDetails => 'Dettagli del profilo';

  @override
  String get followedOn => 'Seguito il';

  @override
  String get doesNotFollowBack => 'Non ti segue';

  @override
  String get dragToSelect => 'Trascina il dito su un’azione per selezionarla';

  @override
  String get manageWhitelist => '📋 Gestisci Whitelist';

  @override
  String get yourWhitelist => 'La tua Whitelist';

  @override
  String get whitelistIsEmpty => 'La whitelist è vuota.';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Sistema (automatica)';

  @override
  String get languageDescription =>
      'Scegli la lingua dell’app oppure segui quella del telefono.';

  @override
  String missingFileDescription(String arg0, String arg1, String arg2) {
    return 'Abbiamo rilevato il file $arg0. Per creare il report, carica anche il file $arg1 ($arg2).';
  }

  @override
  String removeWhitelistConfirmation(String arg0) {
    return 'Vuoi rimuovere \"$arg0\" dalla whitelist?\nTornerà a comparire nell\'elenco dei non-follower.';
  }

  @override
  String get hideDebug => 'Nascondi opzioni di debug';

  @override
  String get hideDebugDescription =>
      'Puoi mostrarle di nuovo con 10 tocchi sulla versione.';

  @override
  String get debugHidden => 'Opzioni di debug nascoste.';
}
