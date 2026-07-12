# Design

## Ein zusammenhängender fachlicher Vertrag

`schemas/engagement-fit-standard.schema.json` beschreibt ein Engagement als fachlich verbundenes Objekt. Angebot und Scope bilden die kommerzielle Planungsgrenze, ohne Rechnungs- oder Produktivsystem zu ersetzen. Phasen, Deliverables, RACI und Gates bilden den Projektsteuerungsrahmen. Prozesslandkarten, Use-Cases und Assessments bilden Fit-to-Standard ab. Entscheidungen und offene Fragen schließen den Referenzgraph.

## Readiness statt Scheinvalidierung allein

Der Validator wendet zuerst das vollständige JSON-Schema an und prüft danach semantische Regeln: eindeutige IDs, gültige Referenzen, chronologische Phasen und Prozessschritte, mindestens Responsible und Accountable je Deliverable, konsistente Fit-/Gap-Entscheidungen und blockierende offene Fragen. `fit_to_standard_ready` darf nur gelten, wenn Annahmen bestätigt, Gaps entschieden, Gates bestanden und blockierende Fragen beantwortet sind.

## Wahrheitsgrenzen

Das Produktfixture ist ausschließlich synthetisch. Steuer- und Rechtsfragen dürfen modelliert, aber nicht durch unbelegte Produktannahmen beantwortet werden. Ein beantworteter synthetischer Fall trägt eine explizite synthetische Quellenreferenz und behauptet keine fachliche Beratung. Reale Antworten bleiben Kunden-Source-of-Truth.

## Kompatibilität

Der Vertrag ist additiv. Bestehende 0.10-Workspaces bleiben gültig; der neue Datensatz wird nicht still in bestehende Kundenworkspaces geschrieben. Backup/Restore nimmt ihn als normale allowlistfähige JSON-Datei auf, während Upgrade kundeneditierbare Inhalte weiterhin schützt.

## Releaseentscheidung

Eine Folgesemver wird erst nach vollständiger Implementierungs-, Kompatibilitäts- und Fresh-Clone-Evidence abgeleitet. Dieser Change erzeugt selbst keinen Candidate.
