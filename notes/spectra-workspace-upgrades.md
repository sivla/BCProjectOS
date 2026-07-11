# Spectra Workspace-Upgrades

`automation/Plan-WorkspaceUpgrade.ps1` arbeitet standardmäßig als Dry-Run. Es liest eine gebundene Workspace-Bindung, prüft die höhere finale Zielversion sowie den Payload-Digest und erstellt einen maschinenlesbaren Plan. `-Apply -Approve` ist erforderlich, bevor ausschließlich `workspace.yaml` und die verwaltete Release-Bindung atomar aktualisiert werden. Kundeneigene Dateien werden nicht verändert. Katalogdrift, Downgrade, wiederholte Anwendung, ungebundene Ausgangsbindung oder ein nicht finales Ziel brechen fail-closed ab.
