# Design

The intake is local and date-/hash-bound. Unknown classification, unsafe paths, hash mismatch, duplicates and unsupported types are rejected or quarantined. Original bytes are never overwritten. Dry-run writes nothing; apply requires an isolated synthetic destination. The proposed `0.4.0-alpha.1` remains below 1.0 because Backup/Restore, full CLI and pilot evidence remain open.
