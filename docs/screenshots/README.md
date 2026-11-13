# Screenshot dell'app

Le anteprime mostrano i widget reali di InstaLander 0.5.0 nel tema Samsung One UI scuro. Sono renderizzate automaticamente a 1236 × 2676 pixel, senza leggere dati del telefono o file personali. Tutti i profili hanno il prefisso `demo_` e le date sono fittizie; il promemoria mostrato attivo non pianifica notifiche reali.

## Immagini

- [Report](report.png)
- [Timeline](timeline.png)
- [Whitelist](whitelist.png)
- [Promemoria e impostazioni](reminders.png)
- [Banner decorato](../images/instalander-banner.png)

## Rigenerazione automatica

Dalla cartella del progetto, con Flutter e le dipendenze già disponibili:

```shell
flutter test tool/capture_screenshots_test.dart
```

Lo script percorre le quattro sezioni, usa fixture deterministiche e carica i font Roboto e Material Icons inclusi nell'SDK Flutter. Il motore di test usa normalmente un font a blocchi per gli stili senza famiglia: solo nell'albero di rendering della cattura viene ripristinato il fallback Roboto di Android. I widget di produzione non vengono modificati. Le icone dell'app vengono precaricate prima della cattura.

Il banner è una composizione decorativa generata con lo strumento imagegen integrato a partire dai quattro screenshot. Per consultare i dettagli esatti dell'interfaccia usa i PNG originali elencati sopra. Il [prompt della composizione](../images/banner-prompt.md) è conservato accanto all'immagine.
