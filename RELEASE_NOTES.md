# InstaLander 0.8.2 — Gyllenhaal

Novità rispetto a 0.8.1 · build 2014.

- Corretto il confronto tra followers e following quando i JSON rappresentano lo stesso profilo con uno username o con un URL Instagram (anche con percorso `/_u/`). Gli identificativi vengono uniformati anche per maiuscole, spazi esterni e prefisso `@`, evitando falsi profili da controllare.
- Per ricalcolare il report con la correzione, reimportare tutti i file followers e following della stessa esportazione dopo l'aggiornamento.
- Abilitati R8 e la rimozione delle risorse inutilizzate nelle build Android release, per ridurre il codice DEX e ottimizzarlo.
- Preservato il costruttore del database WorkManager usato tramite reflection, per evitare un arresto all'avvio con R8 in modalità completa.
- Nel bundle verificato, il DEX non compresso passa da **21,35 MB a 5,21 MB** (circa **76% in meno**). La riduzione delle dimensioni non equivale alle tre percentuali di ottimizzazione misurate da Play Console, da verificare sul bundle caricato.
- Il cambiamento prepara l'app al requisito Google Play previsto da **febbraio 2027**: almeno **25% di ottimizzazione, shrinking e offuscamento** per le app che superano la soglia di **10 MB di DEX non compresso**. Il bundle 0.8.1 conteneva circa 21,35 MB di DEX non compresso.
- L'offuscamento riguarda il codice compilato distribuito: i sorgenti Dart e Kotlin su GitHub restano leggibili.
- La build genera `mapping.txt`, da conservare per ogni versione per interpretare i report di crash; il bundle include i metadati di offuscamento generati da Android Gradle Plugin.

## Riferimenti

- [Requisiti tecnici di Google Play](https://support.google.com/googleplay/android-developer/answer/17492799)
- [Misurazione e ottimizzazione del codice DEX](https://developer.android.com/google/play/vitals/code-optimization)

Android minimo: 8.0 (API 26).
