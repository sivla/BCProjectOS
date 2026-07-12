# Referenzgraph-Projektions- und Coverage-Vertrag

## Warum

Ein vollständig synthetischer, fachlich geprüfter Referenzplaythrough belegt eine generische Produktlücke: Native Relationen können korrekt zusammengeführt, transformiert oder begründet ausgeschlossen werden, ohne dass die Anzahl portabler Kanten der Anzahl nativer Relationen entspricht. Spectra besitzt bislang keinen maschinenlesbaren Nachweis, der diese Differenz je Relationsklasse erklärt und fail-closed prüft.

## Was ändert sich

- Ein geschlossener Vertrag beschreibt native und portable Relationsklassen, deterministische Zuordnungen, Mengen, Outcomes und kontrollierte Reason-Codes.
- Coverage bedeutet den Anteil vollständig erklärter nativer Relationen; sie behauptet weder 1:1-Abbildung noch vollständige portable Repräsentation.
- Quellgraph, Mappingregeln und portable Projektion werden über sichere relative Pfade und SHA-256 an eine read-only Provenienz gebunden.
- Ein synthetischer Generator, Validator, CLI-Befehl und Full-Conformance-Einstieg liefern positive und gezielte negative Evidence.

## Nicht-Scope

- keine Kundenwerte, Fremdprojekt-IDs, Fremdcommits oder Kunden-Evidence;
- keine Live-Adapter, externen Schreibzugriffe oder Project-Twin-Änderungen;
- keine neue parallele Grapharchitektur und keine stillen Änderungen bestehender Project-Story-Verträge;
- kein Candidate-Manifest, Tag oder Release in diesem Funktionsblock.
