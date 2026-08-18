# AGENTS.md — BonoCraft

Guida operativa per agenti AI (Claude Code, Cursor, Copilot Workspace, Codex…) che lavorano su questo repo.
File canonico: `CLAUDE.md` importa questo documento.

---

## 1. Cos'è questo repo

**Non è un mod Java.** Non c'è codice sorgente, non c'è Gradle, non si compila nulla.

BonoCraft è un **repo di distribuzione di server Minecraft moddati** (Cobblemon + Modern
Industrialization). Contiene cartelle di mod `.jar` versionate in git e dei Dockerfile che le
copiano dentro l'immagine `itzg/minecraft-server`. La CI pubblica le immagini su GHCR.

Il "prodotto" sono immagini Docker, non artefatti compilati.

## 2. Layout

| Percorso | Loader | MC | Usato da | Note |
|---|---|---|---|---|
| `mods/` | Fabric | 1.20.1 | `Dockerfile` | 125 jar |
| `mods_neoforge/` | NeoForge | 1.21.1 | `Dockerfile.neoforge` | 84 jar |
| `mods_homestead/` | Fabric | 1.20.1 | **nessuno** | 373 jar, 78 con estensione `.disabled` |
| `.github/workflows/` | — | — | — | due workflow build+push su GHCR |

- `Dockerfile` → `TYPE=FABRIC`, `VERSION=1.20.1`, copia `mods/`, poi `ADD` di
  Cobblemon-fabric-1.5.2+1.20.1 dal CDN Modrinth → immagine `ghcr.io/<owner>/bonocraft`
- `Dockerfile.neoforge` → `TYPE=NEOFORGE`, `VERSION=1.21.1`, copia `mods_neoforge/`, poi `ADD` di
  Cobblemon-neoforge-1.6.1+1.21.1 → immagine `ghcr.io/<owner>/bonocraft-neoforge`

`mods_homestead/` è materiale orfano: nessun Dockerfile lo referenzia, quindi **non finisce in
nessuna immagine**. Non toccarlo assumendo che sia in produzione, e non "aggiustarlo" senza che
qualcuno decida se serve un `Dockerfile.homestead` o se va rimosso.

## 3. Comandi

```bash
# build locale (Fabric 1.20.1)
docker build -f Dockerfile -t bonocraft:dev .

# build locale (NeoForge 1.21.1)
docker build -f Dockerfile.neoforge -t bonocraft-neoforge:dev .

# run di prova
docker run -it --rm -p 25565:25565 -e MEMORY=6G bonocraft-neoforge:dev

# inventario mod (NON usare grep/Read sui .jar: sono binari)
ls mods_neoforge | sort
ls mods_neoforge | grep -ci cobble

# ispezionare i metadati di un jar senza estrarlo
unzip -p mods_neoforge/<file>.jar META-INF/neoforge.mods.toml   # NeoForge
unzip -p mods/<file>.jar fabric.mod.json                        # Fabric
```

Non esistono test. La verifica è: **il build passa** e **il server arriva a "Done"** con i mod
caricati. Se non puoi avviare un server, dillo esplicitamente invece di dichiarare verificato.

## 4. Regole di tagging delle immagini (CI)

Identiche nei due workflow, `steps.prep`:

- push sul branch di default → `:latest`
- push su altro branch → `:<branch-con-slash-sostituiti-da->`
- tag git `vX.Y.Z` → `:vX.Y.Z`, `:vX.Y`, `:vX`, `:latest`
- tag git non-semver → `:<tag>`
- PR → `:pr-<numero>`
- `schedule` → `:nightly`

Piattaforme: `linux/amd64,linux/arm64` (build lento, due arch × due immagini per ogni push).

## 5. Regole per modificare le cartelle mod

Queste sono le convenzioni che contano davvero. Violarle rompe il server in runtime, non in build.

1. **Un jar deve corrispondere a loader + versione MC della sua cartella.** Un jar Fabric in
   `mods_neoforge/` (o viceversa) non viene caricato o fa crashare l'avvio. Il nome file è
   l'unica documentazione: rispetta la convenzione `nome-<loader>-<versione>+mc<MC>.jar`.
2. **Non aggiungere Cobblemon dentro `mods/` o `mods_neoforge/`.** Arriva via `ADD` dal Dockerfile.
   Averlo in due posti significa due copie nella stessa cartella `/data/mods` → crash.
3. **Le dipendenze vanno aggiunte a mano.** Niente risolve i requisiti dei mod qui. Se aggiungi un
   mod che richiede Architectury / Kotlin for Forge / GeckoLib / Curios / Cloth Config / Balm /
   Bookshelf, verifica che la versione già presente sia compatibile prima di aggiungerne un'altra.
4. **Aggiungere e rimuovere nella stessa PR quando fai un upgrade.** Due versioni dello stesso mod
   nella cartella = crash all'avvio. Cerca sempre `ls mods_neoforge | grep -i <nome>` prima.
5. **I mod client-side vivono in queste cartelle.** Sodium, Iris, Xaero's, FancyMenu, Dynamic FPS,
   NotEnoughAnimations, InvMove, BetterThirdPerson ecc. sono nel mods folder del *server*. Fabric e
   NeoForge saltano i mod dichiarati client-only, quindi in genere non crashano, ma gonfiano
   l'immagine. Questa cartella è di fatto un pack client riusato come pack server: se togli
   qualcosa "perché è client", controlla prima che non sia intenzionale.
6. **Un mod nuovo che non riesci a verificare** → aggiungilo, ma segnalalo nella PR come non
   testato. Non silenziare il dubbio.

## 6. Problemi noti (non sono task attivi — chiedi prima di "risolverli")

Sono osservazioni verificabili leggendo i file, non speculazioni. Vanno confermate con chi
mantiene il server prima di modificare qualcosa.

- **Java 17 con MC 1.21.1.** Entrambi i Dockerfile usano
  `ghcr.io/itzg/minecraft-server:2025.3.0-java17-graalvm`. Minecraft 1.20.5+ richiede Java 21;
  `Dockerfile.neoforge` gira su 1.21.1. Sospetto che l'immagine NeoForge non parta. Il fix è la
  variante `java21-graalvm` (per il ramo Fabric 1.20.1 Java 17 è corretto).
- **Nessun limite di memoria.** `MAX_MEMORY` è commentato in `Dockerfile`, assente in
  `Dockerfile.neoforge`. Il default dell'immagine itzg è 1G, insufficiente per 84 mod + Cobblemon.
  Va impostato a runtime (`-e MEMORY=6G`) oppure nel Dockerfile.
- **Mismatch di versione:** `mods_neoforge/reeses-sodium-options-neoforge-1.8.3+mc1.21.4.jar` è per
  MC 1.21.4 in un pack 1.21.1.
- **Peso del repo:** ~1.6 GB di working tree, ~1.0 GB di storia git. In `.gitignore` la riga
  `#*.jar` è commentata, quindi i jar sono committati. Ogni upgrade di mod aggiunge un binario
  nuovo alla storia per sempre. Vedi la sezione 8.
- **`LICENSE` non esiste** ma il README dichiara MIT e rimanda al file.
- **CI datata:** `actions/checkout@v3`, `actions/github-script@v4`, e `::set-output` (deprecato da
  GitHub, sostituire con `$GITHUB_OUTPUT`).
- **Nessun path filter nei workflow:** ogni push ricostruisce entrambe le immagini per entrambe le
  architetture, anche se hai toccato solo una cartella.
- **README obsoleto:** parla di Forge e di una cartella `server/` che non esiste.

## 7. Cosa NON è in questo repo

Non cercarli e non inventarli: world data, `server.properties`, `ops.json`, `whitelist.json`,
config dei mod (`config/`), datapack del mondo, credenziali RCON, docker-compose di produzione.
Vivono sul volume `/data` dell'host. Se una modifica richiede un cambio di config, scrivilo nella
PR come passo manuale da fare sul server.

## 8. Convenzioni di lavoro

- **Non committare jar nuovi senza dirlo.** Sono binari da decine di MB in un repo già da 1.6 GB.
  Se una PR aggiunge jar, dichiara nel corpo quanti e quanto pesano.
- **Non riscrivere la storia git** per recuperare spazio (`filter-repo`, BFG) senza richiesta
  esplicita: rompe ogni clone esistente.
- Commit message descrittivi. La storia attuale è una sequenza di "Add files via upload" (upload
  dalla UI di GitHub): non è un modello da imitare.
- Un cambio per PR: upgrade di mod, aggiunta di mod, e modifiche a Dockerfile/CI separati.
- Quando cambi la lista mod, aggiorna il README se cambia il set di feature.
