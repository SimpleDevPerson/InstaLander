# Verifica prima della pubblicazione

Controllo eseguito il 13 novembre 2026 prima del passaggio della repository da privata a pubblica. Questa verifica non costituisce una garanzia assoluta sull'assenza di informazioni sensibili.

## Ambito

- File sorgenti tracciati e nuovi file destinati al commit.
- Cronologia completa dei branch e dei tag pubblicabili: 5 commit preesistenti, 113 blob storici, un branch e due tag.
- Due release GitHub, con 8 APK e il file di checksum: controllo degli archivi e delle stringhe estratte dai binari.
- Metadati GitHub: nessuna issue, pull request, esecuzione Actions, artefatto Actions, discussione o sito Pages presente. Nessuna wiki Git accessibile.

## Risultati

- Gitleaks 8.30.1, scaricato dalla distribuzione ufficiale con SHA256 verificato: nessun segreto rilevato nel sorgente, nella cronologia pubblicabile o nei metadati GitHub.
- Una segnalazione generica nelle stringhe degli APK della release 0.4.0 è stata verificata come costante interna di `com.google.android.gms:play-services-ads:25.5.0`, presente anche nelle classi della dipendenza originale, e non come credenziale dell'app.
- Nessun keystore, materiale di chiave privata, password locali di firma, percorso personale, esportazione Instagram o metadato EXIF rilevato nei contenuti controllati.
- `android/key.properties`, keystore, configurazione Android locale e impostazioni dell'ambiente di lavoro rimangono esclusi da Git. `android/key.properties.example` contiene esclusivamente segnaposto.
- `.gitignore` esclude inoltre file `.env`, chiavi private, esportazioni, whitelist e storico locale, archivi ZIP e pacchetti Android prodotti localmente.
- Email di autore, committer e tagger sostituite con l'indirizzo GitHub noreply in tutta la cronologia pubblicabile. Le copie originali e il rapporto di riscrittura rimangono privati, fuori dalla repository.
- Analisi Flutter senza problemi e 58 test superati.

I rapporti tecnici della scansione e i file di lavoro dell'audit sono stati conservati fuori dalla repository. Gli APK delle release mantengono i certificati pubblici necessari alla verifica della firma; i certificati non contengono la chiave privata di firma.
