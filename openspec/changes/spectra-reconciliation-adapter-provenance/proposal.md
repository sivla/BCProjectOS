# Project Truth and Adapter Provenance

## Why

Der veröffentlichte Spectra-Stand `0.8.0-alpha.1` besitzt Operator-, Validierungs-, Upgrade- und Recoverypfade, aber noch keinen eigenständigen Vertrag für den versionierten Baseline–Angebot–Ist-Abgleich und keine maschinenlesbare Provenienz einer dateibasierten Projektion. Ein vollständig synthetischer BC-Basic-Referenzplaythrough hat diese beiden generischen Lücken fachlich belegt, ohne als Produktdatenquelle zu dienen.

## What Changes

- Ein generischer Reconciliation-Vertrag bindet Baseline, Angebotsstand und Ist-Stand über Version, Stunden, Rate, Betrag, Abweichung und begründete Wahrheitsgrenze.
- Ein generischer Adapter-Provenienzvertrag bindet Quellblob, Source-Hash, Mappingversion, Projektionsdigest und expliziten Schreibschutz.
- Read-only-Validatoren und Operator-CLI-Routen prüfen beide Verträge fail-closed.
- Zwei isolierte synthetische Beispielprofile (`implementation`, `support-only`) belegen die produktneutrale Verwendung.
- Bestehende 0.8-Workspaces bleiben gültig: Beide Verträge sind additive optionale Artefakte. Upgrade, Backup und Restore dürfen bestehende Kundeninhalte nicht überschreiben.

## Nicht-Scope

- keine Rechnung, Buchung, Zahlung oder produktive Leistungserfassung;
- keine Übernahme von Kunden-, Projekt-, ID-, Wert-, Entscheidungs- oder Evidence-Inhalten aus der Anforderungsquelle;
- kein Live-Adapter, kein Schreiben in Quellsysteme und keine Project-Twin-Aktion;
- kein finales Manifest, Tag, Release oder produktiver Fremdsystemzugriff.

## Releaseeinordnung

Der additive, rückwärtskompatible Funktionsumfang gegenüber dem veröffentlichten `0.8.0-alpha.1` rechtfertigt den getrennten Candidate `0.9.0-alpha.1`. Der Candidate bleibt `PENDING_BCPROJECTOS_RELEASE`; `1.0.0` ist wegen noch ausstehender vollständiger Pilot-/RC-Evidence nicht gerechtfertigt.
