# Change: Releasegebundene atomare Projektinitialisierung

## Why
Der geführte Init kann portable Projektstrukturen erzeugen, ist aber noch nicht atomar mit der Installation eines final gebundenen Spectra-Releases verbunden. Ein realer Kundenworkspace darf niemals ohne verifizierte Releasebindung als vollständig initialisiert entstehen.

## What Changes
- Atomare Komposition aus finaler Releaseinstallation und geführtem Projektlayer.
- Reale Apply-Ausführung nur mit Version, CustomerAlias, finalem Manifest und annotiertem Tag.
- Vollständige Workspacevalidierung vor dem finalen Move.
- Synthetischer Modus bleibt ausdrücklich getrennt.
- `validate` erkennt reale und synthetische Workspaces und delegiert an den passenden read-only Validator.

## Nicht-Scope
- Keine Live-Systemverbindung oder Kundendaten.
- Keine Candidate- oder Releaseerzeugung.
- Keine Änderung an bestehenden veröffentlichten Releases.
