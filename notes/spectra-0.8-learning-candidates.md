# Generische Lernkandidaten für Spectra 0.8

Alle Befunde sind anonymisiert und enthalten keine Kundenwerte oder projektspezifische Entscheidungen. Der übergebene Input nennt keinen vollständigen beobachteten BC-Basic-Commit. Deshalb bleibt die Herkunftsevidence fail-closed als `not_provided` klassifiziert; kein Kandidat wird in diesem Releaseblock implementiert oder als veröffentlicht behauptet.

## SPECTRA-LEARN-BASELINE-001

- Herkunftsprojekt: BC Basic
- Beobachteter vollständiger Commit: `not_provided`
- Problem: Baseline, Angebotsstand und Ist-Werte benötigen einen generischen Reconciliation-Vertrag.
- Evidence-Referenz: anonymisierter Kontrollzentrum-Input zum Spectra-0.8-Folgeblock; commitgebundene Quelle ausstehend
- Klassifikation: `generic-product-gap`
- Anonymisierungsprüfung: `passed`; keine Kundenwerte übernommen
- Betroffene Verträge: Angebot, Projektstory, Worklogs und Kostenabgleich
- Zielentscheidung: als eigener späterer WIP-1-Releaseblock bewerten
- Entscheidung/Status: `deferred` / `proposed`
- Begründung: generischer Nutzen ist plausibel, aber Herkunftscommit und konkrete Conformance-Evidence fehlen; kein Scope-Drift in die Operator-CLI.

## SPECTRA-LEARN-ADAPTER-001

- Herkunftsprojekt: BC Basic
- Beobachteter vollständiger Commit: `not_provided`
- Problem: Dateibasierte Adapter benötigen Quellhash, Mappingversion, Projektionsdigest und Schreibschutz.
- Evidence-Referenz: anonymisierter Kontrollzentrum-Input zum Spectra-0.8-Folgeblock; commitgebundene Quelle ausstehend
- Klassifikation: `generic-product-gap`
- Anonymisierungsprüfung: `passed`; keine Quellartefakte oder Kundenwerte übernommen
- Betroffene Verträge: portable Consumerbindung und dateibasierte Mappingexports
- Zielentscheidung: nach commitgebundener Evidence als eigener späterer WIP-1-Releaseblock bewerten
- Entscheidung/Status: `deferred` / `proposed`
- Begründung: die Provenienzfelder sind generisch sinnvoll, dürfen aber ohne belegte Herkunft nicht als implementierungsreif gelten.

## SPECTRA-LEARN-GRAPH-001

- Herkunftsprojekt: BC Basic
- Beobachteter vollständiger Commit: `not_provided`
- Problem: Native und portable Graphabdeckung müssen getrennt und gemeinsam prüfbar bleiben.
- Evidence-Referenz: anonymisierter Kontrollzentrum-Input sowie der veröffentlichte Spectra-0.7-Vertrag `spectra-v0.7.0-alpha.1`
- Klassifikation: `consumer-contract-gap`
- Anonymisierungsprüfung: `passed`; ausschließlich generische Graphdomänen und Conformance-Regeln
- Betroffene Verträge: nativer Referenzgraph, portable Project-Story-Conformance und Consumerprüfung
- Zielentscheidung: als Akzeptanzregel für spätere Graphänderungen übernehmen; keine Grapherweiterung in 0.8
- Entscheidung/Status: `accepted` / `accepted`
- Begründung: der veröffentlichte portable Vertrag liefert produktseitige Evidence für die Trennung; die Operator-CLI nutzt nur bestehende Validatoren.

Keiner der Kandidaten besitzt den Status `implemented`, `released`, `bound` oder `visualized`.
