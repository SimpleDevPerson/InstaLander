# InstaLander 0.7.0

Novità rispetto a 0.6.0 (build 2007).

- Interfaccia in italiano e inglese, incluse guide, finestre di conferma, messaggi e notifiche. La lingua segue automaticamente il telefono; nelle impostazioni puoi scegliere Sistema, Italiano o English. Per le lingue non supportate viene usato l’inglese.
- Nuova sezione Comportamento: scegli se aprire i profili nell’app Instagram o nel browser predefinito e se aggiungere automaticamente alla whitelist i profili già considerati controllati dalla seconda esportazione dei follower. Le preferenze sono salvate e valgono anche per le importazioni ZIP.
- Apertura dei profili compatibile con Piko, Instander e MyInsta, comprese le varianti con un nome di pacchetto diverso da Instagram. Se sono disponibili più client, l’app rispetta il gestore predefinito o permette di sceglierne uno.
- Data dell’importazione JSON rilevata dalla creazione del file originale su Android 11 o successivo, quando disponibile. Per più JSON viene usata la data più recente; se manca la data di un file, si apre il calendario.
- Debug: notifiche di prova immediate o programmate con un intervallo libero, indicatore della modalità di compilazione e pulsante per nascondere le opzioni. Puoi riattivarle con dieci tocchi sulla versione.
- Sezione Lingua prima di Comportamento, menu coordinato all’ordinamento dei profili, rimozione del segno di spunta ridondante in Aspetto e glow più visibile nei banner Report e Whitelist.
- Correzioni del conto alla rovescia per lo sblocco Debug, dei contrasti dei popup e della compilazione Windows quando il progetto e la cache Pub sono su unità diverse.

## Download

- `InstaLander-0.7.0-universal.apk`: tutte le architetture supportate.
- `InstaLander-0.7.0-arm64-v8a.apk`: telefoni Android ARM a 64 bit.
- `InstaLander-0.7.0-armeabi-v7a.apk`: dispositivi ARM a 32 bit.
- `InstaLander-0.7.0-x86_64.apk`: dispositivi o emulatori Android x86 a 64 bit.
- `InstaLander-0.7.0.aab`: Android App Bundle per la distribuzione tramite store; non installabile direttamente come APK.
- `SHA256SUMS.txt`: checksum SHA256 dei cinque pacchetti.

Android minimo: 8.0 (API 26). APK e App Bundle sono firmati con la chiave di distribuzione delle release precedenti.

Le notifiche richiedono il permesso su Android 13 e successivi. Android può ritardare la consegna delle notifiche programmate per il risparmio energetico.

Verifica: `flutter analyze`, `flutter test` (88 test), APK release per le tre architetture Android, APK universale e App Bundle.
