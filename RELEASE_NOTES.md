# InstaLander 0.4.0

Novità rispetto a 0.3.0 (build 2004).

- Annunci nativi AdMob nel report ogni 3 o 4 righe complete, con spaziatura simmetrica, gestione del consenso UMP e accesso alle opzioni privacy. Corretto il caricamento del tema durante l'inizializzazione degli annunci.
- Interruttore persistente per disattivare annunci e relativi slot, con stile One UI e allineamento delle schede nelle impostazioni.
- Selettore Sistema/Chiaro/Scuro in stile One UI con indicatore animato, bordo e angoli meno arrotondati. Titoli delle sezioni uniformi e collegamento alla repository dalla scheda Progetto.
- Onboarding con icona dell'app e titolo grande in grassetto; icone dei passaggi senza sfondo blu. Icona e titolo centrati nella schermata precedente al caricamento dei file.
- Contatori del report e della whitelist con glow coordinato al colore. A zero il report mostra «Tutto a posto!»; il tick compare solo a zero, con punto esclamativo per tutti i valori positivi.
- Ricerca nella whitelist, azioni incorniciate per aprire e rimuovere profili, sfondo dello swipe coordinato al contatore e correzione dell'overflow dello stato vuoto.
- Navigazione e intestazioni rifinite, con miglioramenti alla gestione degli stati di errore e dei file mancanti.
- Migliorate le prestazioni: disposizione del feed riutilizzata durante lo scorrimento, parsing JSON in un isolate separato, lettura asincrona delle directory, meno copie temporanee nel calcolo del report e nessun riordinamento quando l'opzione è già attiva.
- Dipendenze Flutter aggiornate e test estesi per consenso, annunci, interfaccia, spaziatura, parsing e liste da 10.000–20.000 profili.

## Download

- `InstaLander-0.4.0-universal.apk`: tutte le architetture supportate, scelta più semplice.
- `InstaLander-0.4.0-arm64-v8a.apk`: telefoni Android ARM a 64 bit.
- `InstaLander-0.4.0-armeabi-v7a.apk`: dispositivi ARM a 32 bit.
- `InstaLander-0.4.0-x86_64.apk`: dispositivi o emulatori Android x86 a 64 bit.

Android minimo: 8.0 (API 26). Gli APK sono firmati per la distribuzione. Non sono inclusi ID pubblicitari di produzione: gli annunci reali richiedono la configurazione dell'account AdMob e degli ID descritta nel README.
