# Engagement und Fit-to-Standard

Spectra führt eine Business-Central-Einführung fachlich von einer versionierten Angebotsbaseline über Scope, Annahmen, Phasen, Deliverables und RACI zu Prozesslandkarten und Fit-/Gap-Entscheidungen. Der Vertrag ist Projektsteuerung und Entscheidungsnachweis, aber weder Rechnungssystem noch Steuer-, Rechts- oder Kunden-Source-of-Truth.

## Verbindliche Kette

`Angebot -> Scope/Annahmen -> Phasen/Deliverables/RACI -> Prozess/Use-Case -> Fit-/Gap-Assessment -> Option -> Entscheidung -> Gate`

Jede Referenz verwendet eine stabile ID. Ein Gap ist erst entschieden, wenn eine erlaubte Behandlung, eine empfohlene Option und eine freigegebene Entscheidung konsistent zusammenpassen. `fit_to_standard_ready` ist ein berechneter Zustand und scheitert bei offenen Annahmen, unentschiedenen Gaps, nicht bestandenen Gates, nicht akzeptierten Deliverables oder offenen blockierenden Fragen.

## Fachliche Wahrheitsgrenze

- Reale Antworten, Scopefreigaben und Entscheidungen gehören in den isolierten Kundenworkspace.
- Spectra enthält nur generische Templates und eindeutig synthetische Fixtures.
- Steuer- und Rechtsfragen werden als Fragen mit Owner, Fälligkeit und Quellenbedarf geführt. Spectra beantwortet sie nicht selbst.
- Technische Schemagültigkeit ersetzt keine fachliche Freigabe.

## Nachfolgende Produktblöcke

BC-Setupentscheidungen, Datenmigration, Rollen/SoD, Test/UAT, Training/Change sowie Cutover/Betrieb bauen auf diesem Vertrag auf und bleiben getrennte Releaseumfänge.
