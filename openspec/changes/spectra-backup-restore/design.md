# Design

Backups contain only allowlisted relative files and SHA-256 metadata. Restore validates every file into a staging directory and publishes only after all checks pass. Non-empty targets and manipulated manifests fail closed. `automation/Test-BackupRestore.ps1` is the concrete roundtrip evidence; `Backup-Workspace.ps1` and `Restore-Workspace.ps1` are the executable routes.
