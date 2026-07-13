---
name: operate-bc-pilot-sandbox
description: Einen vollständigen Business-Central-Playthrough ausschließlich in einer ausdrücklich autorisierten Pilotsandbox planen oder ausführen. Verwenden für Company, Setup, Packages, Stammdaten, Prozesse, Posting, Korrektur und Abstimmung nach harter Environment-/Company-/Version-/Role-/Reset-Bindung; niemals für Produktion.
---

# BC-Pilotsandbox bedienen

1. Lies [Vertrag](references/contract.md) und [Safety/Evidence](../_shared/safety-and-evidence.md).
2. Prüfe Sandbox, Company, BC-Version, Locale, Rolle, Work Date und Resetpfad.
3. Lade die benötigte Prozessreferenz; erzeuge keinen Skill pro Prozess.
4. Plane Precondition, zulässige Mutation, erwartetes Ergebnis und Stop-Code.
5. Führe Imports, Posting, Korrektur oder Reset nur nach enger expliziter Freigabe aus.
6. Prüfe Ledger-/Kontrollzustand und bereinigte Evidence; stoppe vor externen Übermittlungen.
