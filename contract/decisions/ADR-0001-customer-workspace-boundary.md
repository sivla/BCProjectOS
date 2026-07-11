# ADR-0001: Kundenworkspace als Isolationsgrenze

Status: Accepted

Entscheidung: Jeder Kunde erhaelt ein eigenes physisches Workspace-Root und Repository mit genau einem OpenSpec-Root. Kundenuebergreifende Relationen und Blob-Stores sind verboten.

Konsequenz: Isolation, Backup, Restore und Loeschung bleiben nachvollziehbar. Kundenuebergreifende Suche ist kein Bestandteil des Kundenworkspace.
