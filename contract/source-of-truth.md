# Source-of-Truth- und Inhaltsregeln

Status: Accepted for MVP 0

| Inhalt | Autoritative Quelle |
|---|---|
| Workspace-Identitaet und Blueprint-Version | `workspace.yaml` |
| kuratiertes Unternehmens- und BC-Wissen | akzeptierte bzw. freigegebene Dateien unter `company/` und `knowledge/` |
| externe Originalbytes | hashadressierter Blob plus `FILE-*`-Register |
| Projekt, Supportfall, Meeting und lokales Ticket | jeweilige kanonische Entitaetsdatei |
| Verhaltensaenderung und Requirements | kanonischer OpenSpec-Change |
| Freigabe oder Testergebnis | `EVD-*` plus referenzierte Quelle |
| BC-Laufzeitverhalten und operative Daten | Business Central |
| externer Ticketworkflow | Jira oder Azure DevOps nach Veroeffentlichung |
| veroeffentlichte Fremdsystemseite | Confluence oder SharePoint |
| gebuchte Zeit | autoritative Zeiterfassung |
| Kosten, Rechnung und Buchung | Buchhaltung bzw. ERP |
| generierte Lieferdatei | nie eigenstaendig; Quellen und Generatorversion sind autoritativ |

Importe duerfen kuratiertes lokales Wissen nicht automatisch ueberschreiben. Konflikte bleiben sichtbar. Extraktion, OCR, Vorschau und Konvertierung liegen unter `derived/` und veraendern das Original nicht. KI-generierte Klassifikationen, Entscheidungen, Tickets und Meetinginhalte bleiben bis menschlicher Review Entwurf.
