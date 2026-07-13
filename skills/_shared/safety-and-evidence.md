# Gemeinsame Safety- und Evidence-Regeln

1. Binde vor jeder Aktion Produkt, Kundenworkspace, Environment, Company, Projekt/Supportfall, Revision und Rolle soweit relevant.
2. Behandle fehlende Klassifikation, Berechtigung, Provenienz oder Zielbindung fail-closed.
3. Trenne Analyse, Proposal, menschliche Entscheidung, Plan, Apply und Verify.
4. Gib zulässige Writes, verbotene Systeme, Reset/Rollback und Stop-Codes vor Apply explizit aus.
5. Speichere keine Tokens, Secrets, `.env`, Browserprofile, Authstates, Tenant-, Session- oder Telemetriedaten.
6. Automation belegt technische Ausführung, übernimmt aber keine Kunden-, Steuer-, Rechts-, UAT- oder Go-Live-Freigabe.
7. Evidence enthält Quelle, Revision, Digest, Zeitpunkt, Rolle, Resultat, WritesPerformed und bekannte Grenzen.
8. Erzeuge bei Drift oder Konflikt einen Vorschlag; passe Skills, Locators oder Kundenwahrheit nie still an.
