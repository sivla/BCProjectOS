---
name: index-project-repository
description: Projekt-Repositories und BC-Extensions strikt read-only nach Identität, Branches, Commit, Tree, App-ID, Publisher, Version und Abhängigkeiten inventarisieren. Verwenden für Kunden-/Environment-/Company-Kontext; niemals Checkout, Branch, Commit, Push, Merge oder Deployment ausführen.
---

# Projektrepository inventarisieren

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Prüfe Repositoryidentität, Remote und explizite Lesefreigabe.
3. Lies Default-/beobachtete Branches sowie gepinnten Commit und Tree ohne Checkout.
4. Extrahiere App-/Extensionmetadaten und Abhängigkeiten aus Git-Blobs.
5. Ordne ausschließlich über belegte Workspace-IDs zu.
6. Gib Inventar, Provenienz und unbekannte Felder aus; führe null Writes aus.
