# Proposal: Portables Bootstrap und lokales Projektregister

## Warum

Der veröffentlichte Release `spectra-v1.1.0-alpha.1` kann bestehende Projekte adoptieren, setzt aber weiterhin einen bereits passend vorbereiteten Produktclone und manuell koordinierte Laufzeitpfade voraus. Für einen neuen Rechner fehlt ein kleiner, reproduzierbarer Einstieg, der Installation, Projekttrennung und Twin-Handoff prüft, ohne Spectra in Kundenrepositories zu kopieren.

## Ziel

Spectra erhält ein plattformneutrales Bootstrap-/Doctor-Modell und ein lokales, nicht versioniertes Projektregister. Ein Benutzer betreibt genau einen Spectra-Produktclone und initialisiert oder adoptiert davon getrennte Kundenworkspaces. Registry und Twin-Handoff speichern ausschließlich relative Pfade und gebundene Produkt-/Snapshotprovenienz.

Zusätzlich normiert derselbe lokale Betriebsvertrag den Weg von isolierten Kundeninstanzen über immutable Snapshot-Releases in einen Multi-Kunden-Katalog für Project Twin. Der Katalog enthält ausschließlich freigegebene Snapshotreferenzen und niemals Kundeninhalte oder Git als Laufzeitschnittstelle.

## Scope

Der portable Bootstrap umfasst außerdem den releasegebundenen Windows-/macOS-Installer, Doctor, lokale Init-/Adoption-/Registry-/Snapshot-Kommandos, sicheren Uninstall und eine plattformehrliche CI-Abnahme. Live-Remote-Schreiben, automatische Werkzeuginstallation und eine Veröffentlichung dieses WIP bleiben außerhalb des Scopes.

- `doctor`, `register`, `init`, `adopt`, `handoff` und `validate` über eine PowerShell-Oberfläche;
- Windows-Pfadnachweis und macOS-kompatible Pfad-/PowerShell-Semantik;
- projektlokale Init-/Adoption über vorhandene Generatoren, ohne Produktkopie;
- lokale Registry für mehrere isolierte Workspaces;
- Jira-/Confluence-Zielkonfiguration bleibt im bestehenden Adoption-Vertrag;
- read-only Twin-Handoff mit Snapshotdigest und relativen Referenzen;
- Source-Inventar mit revisionsgebundenen Confluence-Seiten, Attachments und Checkpoints;
- Delta, Tombstones, reviewte Wissensänderungen, Coverage, Widersprüche und Brownfield-Reconciliation;
- immutable Snapshot-Releases, `current.json` und isolierter Multi-Kunden-Katalog;
- identischer digestgebundener Datenvertrag für Filesystem- und HTTP-Transport;
- Idempotenz, atomare Writes, Secret-/Absolutpfad-Gates und deutsche Bedienung.

## Nicht-Scope

- kein Live-Atlassian-Zugriff oder Remote-Writeback;
- keine Kundeninhalte, Secrets, Authstates oder Browserprofile;
- keine Spectra-Kopie im Kundenrepo;
- kein macOS-ready-Claim ohne echten macOS-Runner;
- keine dauerhafte Git-Runtimekopplung des Twin; Commit-SHA bleibt reine Provenienz;
- kein Candidate, Tag, Push oder Release.

## SemVer

Gegenüber `1.1.0-alpha.1` ist der Block additiv und rückwärtskompatibel. Die unveränderlichen Releases bis `spectra-v1.2.0-alpha.10` dokumentieren die schrittweise Plattformabnahme; `alpha.10` trennte den PowerShell-Alias korrekt, zeigte aber danach, dass macOS 14 kein natives `/usr/bin/realpath` bereitstellt. Die kleinste portable Korrektur verwendet das POSIX-verfügbare `/bin/pwd -P` und ist ausschließlich `1.2.0-alpha.11`. Bestehende Tags und ihre rote Portabilitätsevidence bleiben unverändert; dieser Change erzeugt noch keinen Candidate oder Release.
