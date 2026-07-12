# Quickstart: Cutover bis Handover

1. Synthetisches Profil erzeugen: `Invoke-Spectra.ps1 -Command generate-cutover-operations -Workspace <ziel> -Profile implementation -Apply`.
2. Record prüfen: `Invoke-Spectra.ps1 -Command validate-cutover-operations -Workspace <ziel>`.
3. Im Kundenprojekt werden Rollen, Termine, Evidence und Entscheidungen ausschließlich in der Kundeninstanz ergänzt.
4. GO und Hypercare-Exit bleiben blockiert, solange P1/P2 offen oder Evidence, Retest, Restart- oder Supportannahme fehlen.

Das Beispiel führt keine reale BC-, Kunden- oder Produktivaktivität aus.
