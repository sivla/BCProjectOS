# Proposal: Generischer Blueprint-Katalog und Bootstrap-Vorschlaege

## Ziel

Spectra soll fuer neue Kunden-, Implementierungs- und Supportkontexte versionierte, portable Strukturvorschlaege liefern. Die Vorschau erzeugt ausschliesslich Inbox-/Proposal-Artefakte; fuehrende Kundenquellen werden nie direkt veraendert.

## Scope

- drei generische Blueprint-Typen: Kunde mit Implementierungsprojekt, Kunde nur mit Support, BC-Basic-Einfuehrung;
- Blankovorlagen mit Zweck, Pflicht-/optionalen Feldern, Rollen, fuehrendem Ablageort und Referenzen;
- Confluence-Module und Jira-Hierarchie Phase > Epic > Story/Bug > Task, nur Tasks abrechenbar;
- stabile IDs, variable Kardinalitaet, Blueprint-Provenienz, Vorschau/Diff und Konflikterkennung;
- synthetischer Generator und fail-closed Validator ohne Live-Connector.

## Nicht-Scope

- keine Jira-/Confluence-API, Secrets, Tokens oder Live-Mutation;
- keine Kundenwerte, UABC-IDs oder echte Evidence;
- keine festen Ticket-/Seitenmengen und keine automatische Uebernahme;
- kein Release, Tag oder Versionsclaim.

## Nutzen

Consultants erhalten einen reproduzierbaren Startpunkt fuer Scope, Prozesse, Dokumentation und Arbeitshierarchie, ohne Kundenwahrheit zu erfinden oder bestehende Strukturen zu ueberschreiben.
