---
name: initialize-customer-workspace
description: Kunden-, Projekt- oder Support-only-Workspaces initialisieren oder bestehende Projekte kontrolliert onboarden. Verwenden, wenn Spectra Kundenidentität, Umgebungen, Gesellschaften, Rollen, Quellenbindungen, Inbox und Baseline neu anlegen oder aus einer autorisierten Bestandsquelle vorschlagen soll.
---

# Kundenworkspace initialisieren

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Bestimme `new|onboard`, Profil und exakt einen Kundenkontext.
3. Führe zuerst Dry-run, Pfadprüfung und Konfliktanalyse aus.
4. Erzeuge nur freigegebene leere Strukturen; markiere unbekannte Rollen und Fakten ausdrücklich.
5. Validiere Workspace, Quellbindungen und Null-Kundenwerte im Produktpayload.
6. Stoppe vor externen Writes oder erfundener Kundenwahrheit.
