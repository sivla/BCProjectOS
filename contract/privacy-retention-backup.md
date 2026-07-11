# Datenschutz, Backup, Restore, Aufbewahrung und Loeschung

Status: Accepted for MVP 0

## Datenschutz und Isolation

- Ein physischer Workspace und ein Repository je Kunde.
- Keine relativen oder absoluten Referenzen ausserhalb des Workspace und kein kundenuebergreifender Blob-Store.
- Workspace und Backups liegen auf verschluesseltem Speicher mit Least-Privilege-Dateirechten.
- Secrets, Tokens, Connection Strings und nicht erforderliche Identifikatoren gehoeren nicht in den Workspace.
- Generierte Dateien erben die hoechste Sensitivitaet ihrer Quellen.
- Externe Schreibzugriffe sind standardmaessig deaktiviert.

## Backup und Restore

Backupeinheit ist der vollstaendige Kundenworkspace einschliesslich Git-Historie und der aus Git ausgeschlossenen Originalblobs. Jedes Backup besitzt ein Manifest mit Kunden-ID, Blueprint-Version, Zeitpunkt, relativen Pfaden, Groessen und SHA-256. RPO, RTO, Frequenz und Zielmedium werden je realem Betrieb festgelegt und nicht erfunden.

Restore erfolgt in einen neuen leeren Zielpfad. Danach werden Manifest, Kunden-ID, Blueprint-Version, Pfadgrenzen, Blob-Referenzen und Hashes geprueft. Ein aktiver Workspace wird nicht direkt ueberschrieben. MVP 0 fuehrt keine echte Backup- oder Restoreoperation aus; der reale Restore-Test gehoert zum Pilot.

## Aufbewahrung und Loeschung

Jeder Workspace erhaelt spaeter eine explizite `retention-policy.yaml` fuer Originale, Meetingquellen, Supportfaelle, Evidence, generierte Dateien und Backups. Es gibt keine erfundene globale Frist. `legal_hold` blockiert Loeschung.

Loeschung ist zweistufig: `deletion_requested` und `deletion_approved`. Vor physischer Loeschung werden aktive Relationen, Aufbewahrung und Legal Hold geprueft. Generierte Dateien duerfen zuerst geloescht werden. Originale oder Evidence bleiben erhalten, solange aktive oder aufbewahrungspflichtige Entitaeten sie benoetigen. Ein zulaessiger Tombstone enthaelt nur ID, Zeitpunkt, Grundklasse und Freigabenachweis.
