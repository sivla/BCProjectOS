---
name: render-project-documentation
description: Validierte Workspacefakten als generated Dokumente, Kataloge und source-defined Hierarchien deterministisch rendern. Verwenden für lokale Dokumentprojektionen und Snapshots; authored Inhalte bleiben führend und dürfen niemals überschrieben werden.
---

# Projektdokumentation rendern

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Validiere Spaces, Nodes, Dokumente, Referenzen und Provenienz.
3. Trenne `generated` strikt von `authored`.
4. Rendere zuerst in ein neues Stagingziel und vergleiche Digests.
5. Gib erzeugte, übersprungene und konflikthafte Pfade aus.
6. Stoppe bei konkurrierender führender Wahrheit oder fehlender Provenienz.
