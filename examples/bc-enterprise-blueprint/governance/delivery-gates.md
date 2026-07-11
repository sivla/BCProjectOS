# Delivery Gates

OpenSpec-Artefaktstatus und Delivery-Bereitschaft sind getrennt. Vorhandene Dateien allein sind kein Freigabenachweis.

## Planning

- OpenSpec-Schema und Change sind valide.
- `delivery-plan.json` ist strukturell gueltig.
- Requirements besitzen stabile `REQ-*`-IDs und Szenarien.
- Tasks besitzen stabile `TASK-*`-IDs und gueltige Story-Zuordnungen.
- Externe Veroeffentlichung ist deaktiviert.

## BuildReady

Zusaetzlich zu Planning:

- Keine `TBD`- oder `BLOCKER:`-Marker in Proposal, Business Context und Design.
- Referenzierte Geschaeftsregeln sind explizit freigegeben.
- Lokale Lieferobjekte wurden generiert.
- Quell- und Ausgabedateien stimmen mit dem Hash-Manifest ueberein.

## ReleaseReady

Zusaetzlich zu BuildReady:

- Alle Tasks sind abgeschlossen.
- Automatisierte Tests sind `passed` und besitzen Evidence-Referenzen.
- Erforderliche UAT ist `passed` und besitzt Evidence-Referenzen.
- Dokumentation ist `approved` und besitzt Evidence-Referenzen.
- Erforderliche Schulung ist `delivered` und besitzt Evidence-Referenzen.
- Release Approval ist `approved` und besitzt Evidence-Referenzen.

Das Gate arbeitet fail-closed. Unbekannte, fehlende oder widerspruechliche Werte blockieren.
