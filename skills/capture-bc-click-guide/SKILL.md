---
name: capture-bc-click-guide
description: Einen gebundenen Business-Central-Browserflow read-only erkunden und als bereinigte Klickanleitung mit Screenshots, Rollenhinweisen, Learn-Links, Ergebnissen und Fehlerbehandlung dokumentieren. Verwenden für Kundenanleitungen; keine Buchung oder fachliche Mutation ausführen.
---

# BC-Klickanleitung erfassen

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Binde BC-Version, Locale, Rolle, Environment und Company.
3. Erfasse DOM-/A11y-Grundwahrheit mit semantischen Locators, nie Mauskoordinaten.
4. Formuliere kleine fachliche Primitive mit Vor-/Nachbedingungen.
5. Wiederhole den Flow aus frischer Session read-only und prüfe sichtbaren Zustand.
6. Bereinige Screenshots; UI-Drift erzeugt einen Vorschlag, keine stille Selbstanpassung.
