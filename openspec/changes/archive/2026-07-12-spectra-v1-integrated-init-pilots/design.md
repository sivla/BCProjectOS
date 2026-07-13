# Design

Der Pilot erzeugt ein isoliertes synthetisches Git-Repository, erstellt daraus über den vorhandenen Candidate-/Promotionpfad einen final gebundenen Testrelease und verwendet ausschließlich die öffentliche `Invoke-Spectra.ps1`-Oberfläche.

Das Implementation-Profil erhält Projekt-Confluence, Jira, Consulting-Blankovorlagen und Metadaten. Das Support-only-Profil erhält bewusst nur Projekt-Confluence, Jira und Metadaten. Beide Pfade führen Guided Init, read-only Workspacevalidierung, profilgerechte Fachstrecken, Backup, Restore und erneute Validierung aus.

Die resultierende Evidence bindet Testtag und Tag-Commit, nennt die tatsächlich ausgewählten Blueprints, Dokumentationsnachweis, Recovery und offene P1/P2. Ein eigener read-only Validator prüft diese Evidence fail-closed. Isolierte Mutationen beweisen, dass falsche Bindung, unvollständige Profile, überladene Blueprintauswahl, fehlende Recovery, unzureichende Dokumentation und ein falsches GO abgelehnt werden.
