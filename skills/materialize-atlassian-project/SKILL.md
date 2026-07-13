---
name: materialize-atlassian-project
description: Einen bereits validierten Jira-/Confluence-Desired-State per Plan, Apply und Verify materialisieren. Nur verwenden, wenn Zielsite, Bereiche, Revision, Runtime-Secret-Referenz und Rollenfreigabe ausdrücklich gebunden sind; niemals implizit aus Intake oder Statuspflege auslösen.
---

# Atlassian-Projekt materialisieren

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Prüfe Zielbindung, Capability, Permission und unveränderte Quellrevision.
3. Erzeuge vollständigen `Create|Update|Skip|Conflict`-Plan ohne Writes.
4. Wende nur den exakt freigegebenen Plan atomar und idempotent an.
5. Führe Read-back von IDs, Parents, Versionen, URLs und Digests aus.
6. Gib Teilfehler als Restplan zurück; lösche oder archiviere nie implizit.
