# Design

`profile` beschreibt weiterhin die technische Workspaceform und bleibt auf `implementation` und `support-only` begrenzt. `project_type` beschreibt den fachlichen Auftrag. Ein versionierter Produktkatalog ordnet jeder Projektart genau ein Workspaceprofil und einen empfohlenen Blueprintsatz zu.

Die Auswahl bleibt operatorgeführt: Empfehlungen werden im Dry-run und im persistierten Projektvertrag sichtbar, aber nur explizit ausgewählte Blueprints werden erzeugt. Damit bleibt ein Supportprojekt schlank, während Fit-Gap, Implementation und Migration die passenden Blankovorlagen wählen können.

Eine optionale `predecessor`-Referenz bindet ausschließlich stabile Projekt-ID, Projektart, Beziehung und `read_only=true`. Sie kopiert keine Inhalte. Erlaubte Übergänge werden katalogseitig definiert und fail-closed geprüft. Legacy-Konfigurationen ohne `project_type` bleiben lesbar und werden deterministisch aus dem technischen Profil abgeleitet; neu geführte Initialisierungen schreiben die Projektart immer explizit.
