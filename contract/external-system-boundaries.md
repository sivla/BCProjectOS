# Grenzen zu externen Systemen

Status: Accepted for MVP 0

| System | Dort autoritativ | BCProjectOS |
|---|---|---|
| Business Central | operative Daten, Konfiguration und Laufzeitverhalten | Architekturwissen, Requirements, lokale Snapshots und Evidence-Referenzen |
| Jira/Azure DevOps | veroeffentlichte Keys, Status und Zuweisungen | lokaler Entwurf, Source-ID, Mapping und letzter Importstand |
| Confluence | veroeffentlichte und dort gepflegte Seiten | kuratierte Quelle und lokaler Publikationsentwurf |
| SharePoint | dort verwaltete Dokumentkopien, Versionen und Berechtigungen | Intake-Original oder Provenienzreferenz |
| Zeiterfassung | gebuchte Ist-Zeit | Planung, Forecast und importierte Zusammenfassung |
| Buchhaltung/ERP | Kosten, Rechnungen, Zahlungen und Buchungen | Plan-/Forecastwerte und externe Referenz |

Ein externer Link oder Key ist keine Synchronisation. MVP 0 schreibt in keines dieser Systeme. Spaetere Integrationen muessen Create, Update, Skip und Conflict protokollieren und duerfen lokale Source-IDs nicht ersetzen.
