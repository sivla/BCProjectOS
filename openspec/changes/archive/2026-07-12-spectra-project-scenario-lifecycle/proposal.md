# Change: Projektarten und kontrollierte Übergänge

## Why

Spectra kann neue und bestehende Workspaces technisch initialisieren, unterscheidet aber den fachlichen Auftrag noch nicht explizit. Ein Support-Onboarding, ein Fit-Gap, eine vollständige Einführung und eine Migration benötigen unterschiedliche schlanke Empfehlungen, obwohl sie denselben Produktkern verwenden.

## What Changes

- Versionierter Katalog der vier Projektarten `implementation`, `support`, `fit-gap` und `migration`.
- Klare Trennung von fachlicher Projektart und technischem Workspaceprofil.
- Profilgerechte Blueprintempfehlung ohne automatische Erzeugung unnötiger Vorlagen.
- Optionale, read-only Vorgängerbeziehung für Fit-Gap-zu-Implementation, Migration und Onboarding.
- Persistenz der Projektart und Herkunft im Projektvertrag.
- Guided Init, Schema, Validator und deterministische Tests für alle vier Projektarten.

## Nicht-Scope

- Keine Live-Atlassian-Verbindung oder Kundenmigration.
- Kein automatischer Projektartwechsel und keine Änderung bestehender Kundeninhalte.
- Keine Version, Candidate- oder Releasebehauptung.
