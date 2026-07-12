# Spectra Engagement und Fit-to-Standard

## Why

Der veröffentlichte Stand `0.10.0-alpha.1` ist reproduzierbar installierbar, validierbar, upgrade- und recoveryfähig. Für die tatsächliche Durchführung einer Business-Central-Einführung fehlt jedoch weiterhin der fachliche Einstieg: ein PM oder Consultant kann Angebot, Scope, Annahmen, Projektphasen, Verantwortlichkeiten, Prozesslandkarten sowie Fit-/Gap-Entscheidungen noch nicht als zusammenhängenden Produktvertrag führen.

Die technische Plattform ist damit weiter als der kundennahe Projektvertrag. Dieser Change schließt genau diese größte fachliche Lücke, ohne bereits BC-Setup, Migration, Testdurchführung oder Cutover in denselben Releaseblock zu ziehen.

## What Changes

- Kanonischer Engagement-Vertrag für versioniertes Angebot, Scope, Ausschlüsse, Annahmen, Phasen, Deliverables, Rollen, RACI und Gates.
- Fit-to-Standard-Vertrag für Prozesslandkarten, E2E-Geschäftsfälle, Fit-/Gap-Klassifikation, Optionen, Empfehlungen und Entscheidungen.
- Explizites Register offener Kunden-, Steuer-, Rechts-, Sicherheits- und Technikfragen mit Owner, Fälligkeit, Quellen und blockierender Wirkung.
- Deterministischer synthetischer BC-Basic-Referenzfall ohne Kundenwerte oder Live-Systembehauptung.
- Read-only Validator, stabile Fehlercodes, CLI-Route und isolierte Negativmatrix.
- Aktualisierte 1.0-Gap-Evidence auf Basis des veröffentlichten `0.10.0-alpha.1`-Stands.

## Nicht-Scope

- keine konkreten Kunden-, Tenant-, Steuer- oder Rechtsentscheidungen;
- keine vollständigen BC-Setup-, Migrations-, Test-, Trainings- oder Cutoververträge;
- keine Live-BC-, Jira-, Confluence-, Bank- oder Steueranbindung;
- keine Candidate-, Versions-, Tag- oder Releasebehauptung.
