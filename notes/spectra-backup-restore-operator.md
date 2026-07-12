# Backup/Restore Operator

`Backup-Workspace.ps1 -DryRun` prüft ohne Schreiben. Apply erstellt ein Integritätsmanifest. `Restore-Workspace.ps1 -DryRun` prüft nur; Apply akzeptiert ausschließlich ein leeres Ziel und veröffentlicht erst nach vollständiger Hashprüfung. Bei Fehlern bleibt das Ziel unveröffentlicht und der Stagingrest wird entfernt.
