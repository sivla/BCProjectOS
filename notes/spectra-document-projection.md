# Operatorhinweis: Dokumentprojektion

Eine Projektion beschreibt Dokumentation und Jira unabhängig voneinander. Für neue lokale Tests erzeugt `Invoke-Spectra.ps1 -Command generate-document-projection -Workspace <ziel> -Profile implementation -Apply` eine klar synthetische Fixture. Ohne `-Apply` bleibt der Aufruf ein Dry-run ohne Writes.

`validate-document-projection` liest nur. Generierte Dokumente brauchen Blueprint- und vollständige Quellprovenienz. Authored Dokumente bleiben führende menschliche Inhalte; der Renderer erzeugt oder überschreibt sie nicht. Support-only darf ohne Tickets arbeiten.

Live-Confluence, Jira, Rovo, Zugangsdaten und Kundeninhalte sind Nicht-Scope. Der spätere Materialisierungsmechanismus darf erst nach validiertem Plan und expliziter Freigabe schreiben.
