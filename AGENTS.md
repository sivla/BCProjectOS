# BCProjectOS – Arbeitsanweisung

## Rolle dieses Repositories

Dieses Repository ist die technische Herkunft **BCProjectOS** fuer den kundenunabhaengigen Produktvertrag **Spectra**. Spectra definiert wiederverwendbare Schemas, IDs, Relationen, Statusmodelle, Ticketstrukturen, Generatoren, Validatoren und allgemeines Business-Central-Wissen.

BCProjectOS ist technischer Projekt-/Repositoryname und niemals Kunden-Source-of-Truth. Reale Kundendaten, Kunden-Evidence, Tenant-/Umgebungswerte, konkrete Projektentscheidungen und ungefiltertes Kundenwissen gehoeren nicht in dieses Repository.

Die verbindliche fachliche Produktidentitaet lautet `product_id: spectra` beziehungsweise `productId: spectra`. Der verbindliche Datenfluss lautet:

`Spectra aus BCProjectOS` -> versionierter Produktvertrag -> Kundeninstanz -> validierter Snapshot -> Project Twin

Ein Kontrollzentrum steht ausserhalb dieser Kette. BCProjectOS bearbeitet weder Kundeninstanzen noch Project Twin oder Kontrollzentrum aus diesem Repository heraus. Das kanonische Remote bleibt `https://github.com/sivla/BCProjectOS.git`.

## Repository- und Zweigbindung

- Erwartetes Remote: `https://github.com/sivla/BCProjectOS.git`
- Stabiler Zweig: `main`
- Koordinierter MVP-1-Arbeitszweig: `codex/define-reduced-bcprojectos-mvp1`
- Absolute lokale Pfade duerfen nur zur Erkennung des geoeffneten Projekts dienen und werden nie als dauerhafte Laufzeitbindung gespeichert.
- Vor Schreibarbeit sind Git-Root, aktueller Zweig, Remote und Arbeitsbaum zu pruefen.
- Branches, Remotes, Tags, Releases, Pull Requests und Pushes werden nur nach ausdruecklicher Autorisierung veraendert.

## Verbindliche Quellen und OpenSpec

- `contract/`, `catalogs/` und `schemas/` bilden den normativen Produktvertrag.
- `openspec/` ist der einzige OpenSpec-Root dieses Produkt-Repositories.
- Koordinierte Vorhaben beginnen als OpenSpec-Change. Proposal, Design, Specs und Tasks muessen vor der Implementierung konsistent sein.
- Der technische Spike unter `examples/bc-enterprise-blueprint/` ist Referenzmaterial und wird im reduzierten MVP 1 nicht nebenbei veraendert.
- `pilots/` enthaelt ausschliesslich synthetische, nicht produktive Nachweise.
- `notes/` dokumentiert Produktstrategie und Grenzen, ersetzt aber keinen normativen Vertrag oder Release-Nachweis.

## Sicherheits- und Datenregeln

- Keine echten Kunden-, Personen-, Tenant-, Firmen-, Umgebungs-, Budget-, Freigabe-, UAT-, Authentifizierungs- oder Evidence-Daten aufnehmen.
- Geheimnisse bleiben in Umgebungsvariablen oder lokalen, ignorierten Dateien. `.env*`, Tokens, Browserprofile und Authentifizierungszustaende werden weder gelesen noch committed.
- Unbekannte Klassifikation, Sensitivitaet, Freigabe und Evidence werden fail-closed behandelt.
- Approval- oder Evidence-Status ist nur mit expliziter Nachweisreferenz zulaessig.
- Kundenworkspaces sind physisch und logisch isoliert und besitzen genau einen eigenen OpenSpec-Root.
- Externe Systeme, Business Central, Kunden-Repositories und Zielcode werden ohne spaetere projektspezifische Autorisierung weder gelesen noch beschrieben.
- Produktseitige, nutzersichtbare Eigeninhalte sind professionell auf Deutsch; technische IDs, Schemaschluessel, API-Pfade und unveraenderliche externe Werte bleiben technisch stabil.

## Generator- und Release-Regeln

- Vor einem verifizierten installierbaren Release darf `New-CustomerWorkspace.ps1` nur klar markierte, nicht installierbare synthetische Fixtures in test-eigenen lokalen Zielen erzeugen.
- Keine Version wird aus einem Arbeitsbaum, Verzeichnisnamen, Roadmaptext oder erwarteten Tag abgeleitet.
- Eine Spectra-Version gilt erst als gebunden, wenn annotierter unveraenderlicher Tag, aufgeloester Commit, finales Manifest und neu berechneter Produkt-Digest zusammenpassen.
- Release-Tags verwenden das Praefix `spectra-v<SemVer>`.
- Solange dieser Nachweis fehlt, bleibt der Status exakt `PENDING_BCPROJECTOS_RELEASE`.
- `0.0.x` ist nur ein Produktvertrags-Release. Ein installierbarer Blank-Workspace beginnt fruehestens mit `0.1.0` nach bestandenem MVP-1-Vertrag.
- Releasekandidaten werden ausschliesslich mit `automation/New-ReleaseCandidate.ps1` erzeugt und mit `automation/Test-ReleaseCandidate.ps1` geprueft.
- Ein Kandidatenverzeichnis, Manifest oder Checksum-Set ist kein veroeffentlichter Release.

## Arbeits- und Pruefweise

- Keine inhaltsarmen Mikro- oder Alibi-Commits. Eine zusammenhaengende Aenderung wird als ein reviewbarer Commit uebergeben.
- Keine automatischen Reparaturen ausserhalb dieses Repositories.
- Generierte Laufzeitartefakte, Abhaengigkeiten und lokale Kundenworkspaces bleiben unversioniert, sofern sie nicht ausdruecklich synthetische, reviewte Repository-Evidence sind.
- Vor einer Uebergabe mindestens ausfuehren:
  - `powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-ProductContract.ps1`
  - die zum aktiven OpenSpec-Change gehoerenden positiven und negativen Tests
  - `openspec validate <change-id> --strict`
  - `git diff --check`
  - einen diff-bezogenen Geheimnis-/Tenant-Scan
- Eine Uebergabe nennt Zweig, volle Commit-SHA, Pruefergebnisse, offenen Release-Status und Arbeitsbaumzustand.
- `Nicht ausgefuehrt`, `unbekannt` oder `PENDING_BCPROJECTOS_RELEASE` darf nie als bestanden oder veroeffentlicht dargestellt werden.
