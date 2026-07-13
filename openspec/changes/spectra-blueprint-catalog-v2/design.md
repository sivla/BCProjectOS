# Design: Blueprint-Katalog

Der Katalog ist ein versionierter, read-only Vertrag. Ein Blueprint beschreibt nur portable Struktur und Blankovorlagen. `Initialize-SpectraBlueprintPreview` erzeugt eine Proposal-Vorschau mit stabilen IDs, Herkunft und Ziel-Diff. Bestehende Zielobjekte werden nur verglichen; Apply/Connectoren bleiben spaeteren Changes vorbehalten.

Jeder Blueprint enthaelt `blueprint_id`, `version`, `kind`, `purpose`, `leading_location`, `required_fields`, `optional_fields`, `roles`, `references` und `modules`. Jira-Tickets werden hierarchisch referenziert; billable ist nur fuer `task` erlaubt. Module sind optional und duerfen leer bleiben, solange keine Pflichtseite behauptet wird.
