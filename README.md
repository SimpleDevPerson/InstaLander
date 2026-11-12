# InstaLander

Applicazione Flutter per Android che confronta i file JSON dell'esportazione Instagram e individua i profili seguiti che non ricambiano il follow. Non richiede l'accesso a Instagram e non usa API o servizi backend.

## Funzionalità

- Confronto tra follower e profili seguiti, con conteggi e report.
- Ordinamento per data o alfabetico.
- Ricerca ed esclusione dei profili tramite whitelist.
- Apertura dei profili nell'app Instagram o nel browser.
- Indicatore persistente dei profili già aperti.
- Caricamento dei file JSON direttamente dal dispositivo.
- Temi Samsung One UI e Material Design Expressive, ciascuno con luminosità chiara, scura o predefinita di sistema (configurabile dalle impostazioni).
- Annunci nativi AdMob nella schermata del report, ogni 3 o 4 righe di schede; la richiesta è subordinata al consenso UMP. È possibile disattivarli nelle impostazioni.
- Contatori con glow e stato «Tutto a posto!» quando non rimangono profili da controllare.
- Selettore della luminosità e interruttore degli annunci in stile One UI, con collegamento alla repository nelle impostazioni.

## Esportazione Instagram

Al primo avvio, InstaLander mostra una guida a schede per l'esportazione. In Instagram, apri il Centro gestione account e vai in **Le tue informazioni e autorizzazioni** → **Esporta le tue informazioni**. Crea un'esportazione per il tuo account, scegli **Esporta sul dispositivo** e imposta il formato **JSON**. I nomi delle voci possono variare leggermente in base alla versione di Instagram.

Quando l'archivio ZIP è pronto, scaricalo e caricalo direttamente in InstaLander con **Carica archivio ZIP**: l'app legge dall'archivio solo i file `followers*.json` e `following*.json` necessari. In alternativa, estrai lo ZIP e seleziona manualmente i JSON (di solito nella cartella `followers_and_following`). Puoi riaprire la guida dalla schermata di setup se ti serve.

L'elaborazione avviene sul dispositivo. I file selezionati e la whitelist sono salvati nell'area documenti privata dell'app; le preferenze del tema e i profili aperti sono salvati localmente. L'app non invia questi dati a un server.

## Requisiti

- Flutter 3.38.1 o successivo e Dart SDK compatibile con `pubspec.yaml`.
- Android SDK e un dispositivo o emulatore Android (minimo API 26).

## Sviluppo

Dalla cartella del progetto:

```shell
flutter pub get
flutter run
```

Gli annunci usano gli ID di test Google in modalità debug. Per configurare gli annunci reali, imposta l'ID app AdMob nella proprietà Gradle `adMobAppId` (oppure nella variabile d'ambiente `ADMOB_APP_ID`) e passa l'ID unità annunci nativi con `--dart-define=ADMOB_NATIVE_AD_UNIT_ID=...`. Configura inoltre in AdMob i messaggi di consenso UMP e verifica le opzioni privacy prima della distribuzione. `webview_flutter_android` e `shared_preferences_android` sono bloccati alle ultime versioni compatibili con gli script Gradle del progetto: le release più recenti usano script Kotlin che non risolvono l'estensione Flutter iniettata dalla configurazione Android corrente. Le richieste pubblicitarie e i dati tecnici/di consenso necessari sono gestiti da Google solo dopo la verifica del consenso UMP.

Controlli:

```shell
flutter analyze
flutter test
```

Build APK release per ARMv7, ARM64 e x86_64:

```shell
flutter build apk --release --split-per-abi
```

Gli APK vengono generati in `build/app/outputs/flutter-apk/`, uno per architettura. Per un APK universale, usa `flutter build apk --release` senza `--split-per-abi`. La versione release non richiede annunci se non viene fornito `ADMOB_NATIVE_AD_UNIT_ID`.

Per creare un Android App Bundle:

```shell
flutter build appbundle --release
```

## Struttura

- `lib/models/`: modelli utente e opzioni di ordinamento.
- `lib/providers/`: stato dell'app e preferenze del tema.
- `lib/screens/`: report, impostazioni e whitelist.
- `lib/services/`: lettura dei file JSON, calcolo dei risultati e persistenza.
- `lib/widgets/`: componenti riutilizzabili dell'interfaccia.
- `android/`: progetto nativo Android.
- `test/`: test Flutter.
