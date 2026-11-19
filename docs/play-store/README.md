# Asset Play Store

Quattro screenshot verticali delle schermate reali dell'app, in italiano e con soli dati dimostrativi. Sono renderizzati direttamente dai widget Flutter, senza generazione delle interfacce tramite IA.

Ogni PNG misura 1080 × 1920 pixel (9:16) e pesa meno di 8 MB. Ordine di caricamento suggerito:

1. [Report](screenshots/report.png)
2. [Timeline](screenshots/timeline.png)
3. [Whitelist](screenshots/whitelist.png)
4. [Impostazioni, dalla sezione Comportamento](screenshots/settings.png)

Puoi estrarre tutti i file da [screenshot-cellulari-1080x1920.zip](screenshot-cellulari-1080x1920.zip); nella Play Console vanno caricati i quattro PNG, non lo ZIP.

Rigenerazione dalla cartella del progetto:

```shell
flutter test --dart-define=PLAY_STORE_SCREENSHOTS=true tool/capture_screenshots_test.dart
```

Le immagini per GitHub in `docs/screenshots/` restano separate. La [grafica in evidenza 1024 × 500](../images/instalander-play-store-1024x500.png) è un asset distinto dagli screenshot per cellulari.
