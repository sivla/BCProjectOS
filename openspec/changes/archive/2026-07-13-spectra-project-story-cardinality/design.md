# Design: Variable Kardinalität und Hierarchie

Der Validator leitet Kardinalität aus dem eingelesenen Vertrag und dem gewählten Profil ab. Er verwendet keine absoluten Count-Vergleiche und keine Ticket-ID-Präfixe als Mengenbeweis. Mindestmengen bleiben ausschließlich fachliche Profilregeln, wenn sie ausdrücklich im Schema definiert sind.

Für jede Domäne werden IDs in einer Map gesammelt. Doppelte IDs, doppelte Parent-/Order-Schlüssel und Cross-Workspace-Referenzen werden fail-closed abgelehnt. Parent-, Epic- und Abhängigkeitsketten werden nach vollständigem Map-Aufbau geprüft: unbekannter Parent ist ein Waise, wiederholte IDs in einer Kette ein Zyklus. Eine Kette darf nur auf eine zulässige Root oder ein zulässiges Profilobjekt enden.

Die bestehende synthetische Vollfixture bleibt als positive Regression erhalten, verliert aber ihre Count-Prüfung. Zusätzliche positive Fixtures variieren Ticket-, Page- und Eventmengen. Negative Fixtures mutieren jeweils nur eine Ursache und erwarten stabile Fehlercodes wie `STORY_CARDINALITY_FIXED_COUNT`, `STORY_DUPLICATE_ID`, `STORY_PARENT_ORPHAN`, `STORY_PARENT_CYCLE` und `STORY_REFERENCE_INVALID`.

Die Umstellung ist rückwärtskompatibel für gültige 0.6/0.7/RC-Verträge. Ein Upgrade darf keine Sammlung auffüllen oder verkleinern; vorhandene Kundeninhalte bleiben unverändert.
