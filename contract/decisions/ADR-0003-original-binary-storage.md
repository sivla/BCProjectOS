# ADR-0003: Speicherung externer Originale

Status: Accepted

Entscheidung: Originale werden SHA-256-content-addressed, unveraendert und ausserhalb von Git gespeichert. Metadaten und Provenienz bleiben versioniert. Ein gemeinsamer Kunden-Blob-Store wird nicht verwendet.

Konsequenz: Duplikate koennen denselben Blob nutzen, ohne Einsendevorgaenge zusammenzulegen. Git LFS oder Object Storage bleiben spaetere Betriebsentscheidungen.
