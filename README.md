# InstaLander

Applicazione Flutter per Android che confronta i file JSON dell'esportazione Instagram e individua i profili seguiti che non ricambiano il follow. Non richiede l'accesso a Instagram e non usa API o servizi backend.

## Funzionalità

- Confronto tra follower e profili seguiti, con conteggi e report.
- Ordinamento per data o alfabetico.
- Ricerca ed esclusione dei profili tramite whitelist.
- Apertura dei profili nell'app Instagram o nel browser.
- Indicatore persistente dei profili già aperti.
- Caricamento dei file JSON direttamente dal dispositivo.
- Temi chiaro, scuro, automatico e Samsung One UI.

## Esportazione Instagram

Richiedi e scarica una copia delle informazioni del tuo account Instagram in formato JSON, quindi estrai l'archivio. Nell'app seleziona i file `followers_*.json` e `following_*.json` dell'esportazione.

L'elaborazione avviene sul dispositivo. I file selezionati e la whitelist sono salvati nell'area documenti privata dell'app; le preferenze del tema e i profili aperti sono salvati localmente. L'app non invia questi dati a un server.

## Requisiti

- Flutter 3.32 o successivo e Dart SDK compatibile con `pubspec.yaml`.
- Android SDK e un dispositivo o emulatore Android (minimo API 26).

## Sviluppo

Dalla cartella del progetto:

```shell
flutter pub get
flutter run
```

Controlli:

```shell
flutter analyze
flutter test
```

Build APK release ARM64:

```shell
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

L'APK viene generato in `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

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
