# POV-001 Entscheidungsvorlage

Status: Decided - Reduce

Entschieden am: 2026-07-11

## Optionen

| Entscheidung | Bedeutung | Bewertung aus POV-001 |
|---|---|---|
| Go | MVP 1 im geplanten Umfang starten | Zu stark: reale Baseline und freiwillige Wiederverwendung sind nicht belegt. |
| Reduce | Kernworkflow behalten, Pflichtmetadaten und Ausgaben minimal halten | Empfohlen: Traceability und fail-closed Verhalten funktionieren; der volle Spike-Output ist fuer den Pilot zu breit. |
| Reframe | Problem oder Produktgrenze grundlegend neu schneiden | Derzeit nicht erforderlich; das lokale Dateimodell blieb ohne UI verstaendlich. |
| Stop | BCProjectOS nicht fortsetzen | Nicht empfohlen; der Pilot erzeugt nachvollziehbare, lokal nutzbare Ergebnisse. |

## Festgelegte Entscheidung: Reduce

Der Nutzer hat `Reduce` explizit freigegeben. MVP 1 darf damit als schlanker Blank-Workspace fortgesetzt werden. Beibehalten werden stabile IDs, Originalregister, vier Tag-Dimensionen, Draft-Review, Support-Promotion und getrennte Gates. Nicht vorziehen: produktive Intake-Automation, neue Taxonomie, Project Twin, UI, externe Systeme oder der volle Delivery-Ausgabebaum.

## Gate-Auswirkung

Das Proof-of-Value-Produkt-Gate ist mit `Reduce` entschieden. Der Start von MVP 1 ist im reduzierten Umfang freigegeben, aber durch diese Entscheidung noch nicht begonnen. Spaetere MVPs und Plattformarbeit benoetigen weiterhin ihre eigenen Freigaben.
