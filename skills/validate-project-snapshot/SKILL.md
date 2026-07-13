---
name: validate-project-snapshot
description: Spectra-Projektverträge, IDs, Referenzgraph, Provenienz, Secrets, Releasebindung und Consumerfähigkeit strikt read-only validieren. Verwenden vor Twin-Projektion, Übergabe, Backup, Upgrade, Pilot oder Release; bei unbekanntem Gate fail-closed bleiben.
---

# Projektsnapshot validieren

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Binde Repository, Commit, Tree, Release und Snapshotdigest.
3. Prüfe Schema-Parität, Kundenisolation, Referenzen, Provenienz, Pfade und Secrets.
4. Führe alle erforderlichen Profil-, Upgrade-, Backup-/Restore- und Consumer-Gates aus.
5. Erzeuge deterministische maschinenlesbare Findings ohne Workspaceinhalte zu leaken.
6. Melde GO nur bei vollständig ausgeführten Gates und null offenen P1/P2.
