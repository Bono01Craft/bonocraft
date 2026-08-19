# CLAUDE.md — BonoCraft

@AGENTS.md

Il contesto del progetto (layout, comandi, regole sulle cartelle mod, problemi noti) sta in
[AGENTS.md](AGENTS.md), importato qui sopra così da avere una sola fonte di verità condivisa con gli
altri tool. Qui sotto solo ciò che è specifico di Claude Code.

---

## Attenzione: questo repo è pesante e binario

1.6 GB di working tree, 582 file `.jar`/`.zip`/`.disabled`, zero righe di codice sorgente. I comandi che
useresti di riflesso qui sono lenti o inutili:

- **Non leggere né grep-are i `.jar`/`.zip`.** Sono archivi binari. `Read` fallisce, `grep -r` sputa
  megabyte di rumore. Per l'inventario usa `ls <cartella>`; per i metadati di un singolo mod
  `unzip -p <jar> fabric.mod.json` o `META-INF/neoforge.mods.toml`.
- **Non lanciare `find .` o `grep -r` dalla root.** Attraversa 582 binari e ~1 GB di `.git`.
  Restringi sempre alla cartella o al pattern che ti serve.
- **Non usare `Glob`/`Grep` per capire "cosa fa" il pack.** La risposta è nei nomi dei file:
  `ls mods_neoforge | sort`.
- I file di testo su cui si lavora davvero sono cinque: `Dockerfile`, `Dockerfile.neoforge`,
  `README.md`, `.gitignore`, e i due workflow in `.github/workflows/`.

## Cosa verificare prima di dire "fatto"

Non c'è test suite. Sequenza minima per una modifica alla lista mod:

```bash
ls mods_neoforge | grep -i <nome-mod>          # nessun duplicato / versione vecchia rimasta
docker build -f Dockerfile.neoforge -t bonocraft-neoforge:dev .
```

Il build che passa dimostra solo che i file si copiano. Dimostra il caricamento dei mod **solo** un
avvio reale fino a `Done (…)! For help, type "help"`. Se non hai avviato un server, scrivi
esplicitamente che la verifica si è fermata al build — non dire che funziona.

## Permessi

Comandi sicuri e frequenti da allowlist-are in `.claude/settings.json` se arrivano prompt ripetuti:
`ls`, `unzip -p`, `du -sh`, `git status`, `git log`, `docker build`.

`docker run` che pubblica la porta 25565 espone un server: chiedi conferma prima di lanciarlo se non
è stato richiesto.

## Confini

- **Non aggiungere jar di tua iniziativa.** Servono decisioni di game design (bilanciamento,
  compatibilità con Cobblemon, impatto sul TPS) che non puoi prendere. Proponi, non committare.
- **Non scaricare mod dalla rete** per "completare" un pack senza richiesta esplicita.
- **Non riscrivere la storia git** per recuperare spazio: rompe ogni clone esistente.
- I "problemi noti" nella sezione 6 di [AGENTS.md](AGENTS.md) sono documentazione, non una todo
  list. Toccali solo se ti vengono chiesti.

## Lingua

Il manutentore scrive in italiano. Rispondi in italiano; codice, commit message, nomi di branch e
documentazione tecnica in inglese quando è la convenzione del progetto (i workflow e il README sono
già in inglese).
