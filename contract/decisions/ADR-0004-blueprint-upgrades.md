# ADR-0004: Blueprint-Upgrades

Status: Accepted

Entscheidung: Blueprint und Schemas verwenden Semantic Versioning. Strukturelle Updates erfolgen ausschliesslich durch explizite, versionierte und idempotente Migrationen mit Preflight und Backup.

Konsequenz: Kundendateien werden nicht blind ueberschrieben. Restore ist der garantierte Rollbackweg; Downgrades sind nicht implizit zugesichert.
