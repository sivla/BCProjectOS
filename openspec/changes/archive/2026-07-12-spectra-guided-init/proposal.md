# Change: Geführter Spectra-Init-Assistent

## Why
Der maschinenlesbare Init-Vertrag ist vollständig, verlangt aber bislang eine manuell erstellte JSON-Datei. Ein neuer Implementierer soll aus einem frischen Clone alle notwendigen Entscheidungen geführt erfassen können.

## What Changes
- `spectra init -Guided` fragt Projektmodus, Profil, BC-Prozesse, Zusammenarbeit, Projekt-Space, Ticketstrategie und Blueprintauswahl ab.
- Derselbe Pfad ist über eine Answer-Datei deterministisch automatisierbar.
- Das Spectra-Standardticketprofil wird angeboten; eigene Strukturen werden ausschließlich aus einer expliziten Mappingdatei übernommen.
- Die erzeugte Init-Konfiguration kann zur Prüfung gespeichert werden.

## Nicht-Scope
- Keine Live-Atlassian-Verbindung.
- Keine Zugangsdaten oder Kundenwerte im Produkt.
- Keine automatische fachliche Entscheidung.
- Keine Veröffentlichung oder Versionsbehauptung.
