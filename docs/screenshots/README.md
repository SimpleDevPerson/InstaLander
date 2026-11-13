# Screenshot dell'app

Le anteprime mostrano i widget reali di InstaLander nel tema Samsung One UI scuro. Sono renderizzate automaticamente a 1236 × 2736 pixel, senza leggere dati del telefono o file personali. La fascia scura superiore di 20 px logici aggiunge spazio al mockup del telefono senza comprimere l'interfaccia. Tutti i profili hanno il prefisso `demo_` e le date sono fittizie; il promemoria mostrato attivo non pianifica notifiche reali.

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

Durante la cattura viene riabilitato anche il rendering delle ombre, normalmente disattivato nei widget test, per mantenere il glow originale di contatori e avatar. La fascia superiore usa lo stesso sfondo scuro dell'interfaccia (`#111111`).

Il banner è una composizione decorativa generata con lo strumento imagegen integrato a partire dai quattro screenshot. Per consultare i dettagli esatti dell'interfaccia usa i PNG originali elencati sopra. Sono conservati sia il [prompt originale](../images/banner-prompt.md) sia il [prompt di aggiornamento](../images/banner-edit-prompt.md) con la fascia scura superiore, il testo «Il tuo report, privato.» e le impostazioni senza la sezione Pubblicità.

L'[ultima rifinitura](../images/banner-spacing-prompt.md) dimezza la fascia superiore a 20 px logici e completa la frase con «Nessun rischio.».

La [correzione di fedeltà](../images/banner-glow-repair-prompt.md) ripristina il glow, uniforma lo sfondo superiore e corregge la griglia del Report.

La [correzione mirata del Report](../images/banner-report-repair-prompt.md) elimina i riquadri vuoti introdotti nella parte inferiore durante la composizione.

La [correzione della continuità della griglia](../images/banner-grid-continuity-prompt.md) fa proseguire la quarta fila dietro la navbar, eliminando lo spazio vuoto tra le schede.
