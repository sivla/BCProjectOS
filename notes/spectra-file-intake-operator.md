# Synthetischer Datei-Intake

`New-SyntheticFileIntake.ps1 -DryRun` schreibt nichts. Apply ist ausschließlich für isolierte synthetische Testziele erlaubt. Unbekannte oder manipulierte Eingänge werden nicht übernommen; Recovery erfolgt durch Prüfung des Originals, Korrektur der Metadaten und erneute Review-Entscheidung. Es gibt keine Live-Mail-, SharePoint-, Jira-, Confluence- oder BC-Anbindung.
