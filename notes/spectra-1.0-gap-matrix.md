# Spectra 1.0.0 Gap-Matrix nach 0.10.0-alpha.1

Bewertungsbasis ist der veröffentlichte und gebundene Spectra-Release `0.10.0-alpha.1`. Statuswerte sind `vorhanden`, `teilweise`, `fehlend` oder `unbewiesen`. Synthetische Evidence wird ausdrücklich nicht als reale Kunden-, BC-, Steuer- oder Rechtsaktivität dargestellt.

## Produkt- und Betriebsfähigkeit

| Pflichtbereich | Status | Evidence | Verbleibende Hauptlücke |
|---|---|---|---|
| Produktkern/Schemas | teilweise | `schemas/*.schema.json`, `Test-ProductContract.ps1` | Kundennahe BC-Fachverträge sind noch nicht vollständig |
| Implementation-Profil | teilweise | installierbarer Workspace, Operatorpilot, Project-Story-Fixtures | Noch kein durchgängiger Projektbetrieb über alle 1.0-Fachbereiche |
| Support-only-Profil | teilweise | isolierter Operatorpilot und Control-Fixture | Vollständige Support-/Knowledge-/Service-Übergabe unbewiesen |
| Workspace-Init | vorhanden | `New-CustomerWorkspace.ps1`, Installations- und Pfadgates | Optionale Fachmodule benötigen später deklarative Auswahl |
| Projektbetrieb | teilweise | Project-Story, Kontrollrecords, Timeline und Hypercare | Engagement/Fit-to-Standard wird in diesem Change ergänzt; Setup bis Handover bleibt unvollständig |
| Tickets/Wissen | teilweise | Ticket-/Kommentar-/Worklog-/Story-Verträge | Incident/Problem/Knowledge und fachlicher Wiederverwendungsworkflow nicht vollständig |
| Evidence/Datei-Intake | vorhanden | kontrollierter Intake, Quarantäne, Evidence-/External-File-Validator | Reale Dateitypen und Betriebsgrenzen bleiben Pilotumfang |
| Validatorplattform | vorhanden | Schema-Parität, portable Story, Coverage und stabile Negativmatrizen | Neue Fachtypen müssen je Release integriert werden |
| Upgrade/Migration | teilweise | Workspace-Upgradeplan und Konflikt-/Rollbacktests | Fachliche Datenmigration und produktweite Kompatibilitätsmatrix fehlen |
| Backup/Restore | vorhanden | deterministisches Manifest und Roundtrip für beide Profile | Größere Binär-/Recoverypiloten bleiben unbewiesen |
| Sicherheit/Datenschutz | teilweise | Pfad-, Secret-, Tenant-, Intake- und Releasegates | Ausführbare Retention-/Lösch-/Exportregeln und Threat-Matrix fehlen |
| CLI/Bedienung | vorhanden | Dispatcher für Init, Validate, Upgrade, Backup, Restore und Candidateprüfung | Fachkommandos und konsistente Hilfe wachsen mit den nächsten Verträgen |
| Dokumentation | teilweise | Release-, Operator-, Intake-, Backup- und Upgradehinweise | Durchgängige deutsche PM-/Consultant-Handbücher fehlen |
| Supply Chain | vorhanden | Schema-v2-Candidate, Promotion, Tag, Digest und Fresh-Clone | SBOM/Werkzeugtransparenz und RC-Gesamtproof bleiben offen |

## Kundennahe BC-Projektfähigkeit

| Fachbereich | Status vor diesem Change | Evidence | Zielentscheidung |
|---|---|---|---|
| Angebot, Scope, Annahmen, Ist-Abgleich | teilweise | Project Story und Reconciliation | Engagement-Vertrag mit Scope, Ausschlüssen und Annahmen umsetzen |
| Phasen, Deliverables, RACI, Entscheidungen | teilweise | Control-/Story-Fixtures | Als zusammenhängenden Projektsteuerungsvertrag umsetzen |
| Fit-to-Standard, Gaps, Entscheidungslog | fehlend | keine spezialisierte Route | Höchste Priorität dieses Changes |
| Prozesslandkarten und E2E-Geschäftsfälle | teilweise | generischer Prozess und synthetische Prozesskette | Geordnete Schritte, Rollen, Preconditions und Outcomes ergänzen |
| BC-Setupentscheidungen | fehlend | keine spezialisierte Evidence | Nächster fachlicher Releaseblock nach Engagement/Fit-to-Standard |
| Datenmigration | teilweise | Prozessphase und technisches Workspace-Upgrade | Migrationsobjekte, Mapping, Ladezyklen und Reconciliation fehlen |
| Rollen und SoD | fehlend | einfache Rollenrecords | Berechtigungspakete, Konfliktmatrix und SoD-Entscheidung fehlen |
| Integrationen, Reporting, Dokumente | teilweise | Adapter-Provenienz, Pages, Deliverables | Fachanforderung, Ownership, Mapping und Abnahme fehlen |
| Teststrategie und UAT | teilweise | Evidence-/UAT-Gates und Retest | Strategie, Zyklen, Coverage und Requirement-Traceability fehlen |
| Training und Change | fehlend | nur generische Evidencearten | Zielgruppen, Lernziele, Adoption und Readiness fehlen |
| Cutover und Mock-Cutover | teilweise | synthetische Go-/Rehearsal-Gates | Detaillierter Plan, Zeitfenster, Abhängigkeiten und Rollback fehlen |
| Go-live, Hypercare und Betrieb | teilweise | Hypercaretage, Fix, Retest und Exit | Betriebsmodell, Supportübergabe und Service-Readiness fehlen |
| Kunden-, Steuer- und Rechtsfragen | fehlend | keine spezialisierte Route | Explizite Fragen mit Owner, Quelle, Fälligkeit und Blocking umsetzen |

## Aktiver nächster großer Block

`spectra-engagement-fit-standard` schließt den zusammenhängenden Einstieg von Angebot und Scope über Projektsteuerung bis Fit-/Gap-Entscheidung. Er umfasst keine BC-Setup-, Migrations-, Test- oder Cutoverimplementierung. Eine Folgereleaseversion wird erst aus der vollständigen Evidence abgeleitet.

## Priorisierte Folgeblöcke bis 1.0

1. BC Solution Design: Setupentscheidungen, Rollen/SoD, Integrationen, Reporting und Dokumente.
2. Migration, Test und Change Readiness: Datenmigration, SIT/UAT, Defects/Retests, Training und Adoption.
3. Cutover und Betriebsübergabe: Mock-Cutover, Go-live, Hypercare, Restart, Support und Handover.
4. RC-Pilot: frischer Implementation- und Support-only-Pilot, Upgrade, Backup/Restore, Recovery, deutsche Handbücher und keine offenen P1/P2.
5. `1.0.0`: erst nach unabhängiger Evidence für alle Pflichtfähigkeiten.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth oder Kunden-Evidence wird in Spectra übernommen.
- Offizielle BC-Quellen, Kundenentscheidungen und steuerliche/rechtliche Bewertungen bleiben unterscheidbar.
- Ein Schema-PASS ist kein fachlicher Freigabenachweis.
- Releaseversionen entstehen nur aus belegtem Delta und getrenntem Release-Gate.
