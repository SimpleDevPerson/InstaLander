# InstaLander 0.5.0

Novità rispetto a 0.4.0 (build 2005).

- Storico locale dei profili conservato prima di ogni nuova importazione JSON o ZIP. I file multipli della stessa esportazione vengono elaborati insieme e gli import non validi non sostituiscono i dati salvati.
- Whitelist automatica dal secondo export dei follower secondo la regola `seguiti − (vecchi follower ∩ nuovi follower)`, mantenendo le esclusioni manuali.
- Nuova Timeline accanto al Report: date delle esportazioni a sinistra, linea verticale continua con nodi e profili a destra. Sono inclusi anche i profili in whitelist. L'intervallo non indica il momento esatto dell'unfollow.
- Riconoscimento dei possibili cambi di username tramite timestamp di follow identici e validi. L'utente può confermare le associazioni, ignorarle oppure annullare l'importazione; nessun profilo viene associato automaticamente.
- Promemoria Instagram facoltativo ogni mese, ogni 3 mesi o ogni 6 mesi, con selettore coordinato a quello della luminosità. La notifica è pianificata da Android senza mantenere Flutter attivo in background.
- Annunci disattivati per impostazione predefinita e toggle One UI uniforme per pubblicità e promemoria.
- Sezione Debug con dati casuali temporanei per timeline, whitelist e report. I dati importati non vengono alterati; il comando di cancellazione completa è in fondo alla sezione e richiede conferma.
- Correzioni di allineamento delle impostazioni e layout della Timeline verificato anche su schermi stretti e con testo ingrandito.

## Download

- `InstaLander-0.5.0-universal.apk`: tutte le architetture supportate, scelta più semplice.
- `InstaLander-0.5.0-arm64-v8a.apk`: telefoni Android ARM a 64 bit.
- `InstaLander-0.5.0-armeabi-v7a.apk`: dispositivi ARM a 32 bit.
- `InstaLander-0.5.0-x86_64.apk`: dispositivi o emulatori Android x86 a 64 bit.
- `InstaLander-0.5.0.aab`: Android App Bundle per la distribuzione tramite uno store; non installabile direttamente come APK.
- `SHA256SUMS.txt`: checksum SHA256 dei cinque pacchetti.

Per aggiornare un'installazione esistente, usa la stessa variante APK della release precedente.

Android minimo: 8.0 (API 26). APK e App Bundle sono firmati con la chiave di distribuzione già usata per le release precedenti. Non sono inclusi ID pubblicitari di produzione. Il promemoria richiede il permesso per le notifiche su Android 13 e successivi e la consegna può slittare per il risparmio energetico del dispositivo.

Verifica: `flutter analyze` e `flutter test`.
