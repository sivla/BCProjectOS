# Speicherung, Hashing und Integritaet

Status: Accepted for MVP 0

Externe Originale werden content-addressed unter `external-files/originals/sha256/<erste-zwei-Zeichen>/<vollstaendiger-sha256>` abgelegt. SHA-256 wird ueber die exakten Bytes gebildet, nach dem Schreiben erneut geprueft und im `FILE-*`-Register gespeichert. Originalname, Groesse, Medientyp, Intake-Zeit und Provenienz bleiben Metadaten.

Originale werden nie ueberschrieben, bereinigt oder konvertiert. Gleicher Hash verwendet denselben Blob, darf aber bei verschiedener Einsendung oder Herkunft mehrere `FILE-*`-Registereintraege besitzen. Gleicher Name mit anderem Hash ist eine neue Datei bzw. Version. Ableitungen liegen unter `derived/` und referenzieren ihre Quelle.

Text und kleine synthetische Fixtures liegen in Git. Originalbinaerdateien, Backups und grosse Ableitungen liegen ausserhalb von Git, aber innerhalb des verschluesselten Kundenworkspace-Speichers. Ab 10 MiB warnt die MVP-0-Git-Regel; dies ist keine fachliche Dateigroessengrenze. Git LFS, NAS oder Object Storage bleiben spaetere Backendentscheidungen.

MVP 0 behauptet keine rechtssichere WORM-Speicherung. Integritaet wird durch unveraenderliche Schreibregeln, SHA-256 und lokale Verifikation nachgewiesen.
