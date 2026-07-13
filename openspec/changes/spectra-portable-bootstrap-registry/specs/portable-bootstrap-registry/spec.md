# Portable Bootstrap Registry Specification

## ADDED Requirements

### Requirement: Ein Produktclone bedient getrennte Kundenworkspaces

Spectra MUST aus einem unveränderten Produktclone neue oder bestehende Kundenworkspaces außerhalb des Produktrepositories initialisieren beziehungsweise adoptieren. Es MUST verhindern, dass Produktpayload in einen Kundenworkspace kopiert wird.

#### Scenario: Getrennter Workspace

- **WHEN** ein Workspace unter dem Registry-Root erstellt wird
- **THEN** enthält er nur Workspaceartefakte und eine gebundene Produktreferenz, aber keinen Spectra-Produktclone

### Requirement: Doctor ist read-only und plattformehrlich

Doctor MUST Git, PowerShell, Produktroot, Releasebindung, Registry-Root und Pfadsemantik ohne bleibende Writes prüfen. Eine sofort entfernte Schreibprobe ist ausschließlich innerhalb der konfigurierten Config-/Registry-Roots zulässig. Windows- und macOS-Evidence MUST getrennt ausgewiesen werden.

Auf macOS MUST Spectra ausschließlich PowerShell 7 über `pwsh` verwenden. Doctor MUST zusätzlich Node.js, den konfigurierten Config-Root und Schreibfähigkeit ausschließlich in Config-/Registry-Root prüfen. Fehlende Werkzeuge MUST mit exakten Homebrew-Hinweisen gemeldet, aber niemals automatisch installiert werden.

#### Scenario: Fehlender macOS-Nachweis

- **WHEN** kein echter macOS-Runnernachweis vorliegt
- **THEN** bleibt macOS mit `MACOS_RUNNER_EVIDENCE_MISSING` offen und wird nicht als bestanden behauptet

#### Scenario: macOS-Werkzeug fehlt

- **WHEN** `pwsh`, Git oder Node auf einem macOS-System fehlt
- **THEN** endet Doctor fail-closed mit stabilem Fehlercode und einem nicht-ausführenden Homebrew-Hinweis

### Requirement: macOS verwendet portable lokale Konfiguration

Spectra MUST auf macOS standardmäßig `~/.config/spectra/` und `~/.local/share/spectra/` verwenden, XDG- und Argument-Overrides erlauben und Leerzeichen sowie case-sensitive Pfade korrekt behandeln. Runtimepfade, Tokens, Passwörter, Browserprofile oder Authzustände MUST aus versionierten Dateien ausgeschlossen sein.

#### Scenario: Synthetisches XDG-Home

- **WHEN** ein frisches macOS-Home mit XDG-Overrides und Leerzeichen verwendet wird
- **THEN** werden ausschließlich die konfigurierten lokalen Roots angelegt und Registryeinträge bleiben relativ

#### Scenario: Secret in Projektkonfiguration

- **WHEN** eine versionierte Init-/Adoption-Konfiguration ein Token oder eine nicht erlaubte Secret-Referenz enthält
- **THEN** wird sie vor Init oder Adoption fail-closed abgelehnt

### Requirement: macOS-Evidence bleibt ehrlich

Das macOS-Abnahmeskript MUST bereinigte JSON-Evidence für Fresh Clone, Installation, Doctor, Init, Adoption, Validierung, Snapshot, Remote-Write-Sperre und Pfadsemantik erzeugen. Nur ein echter macOS-Lauf MAY `PASS` ausweisen.

#### Scenario: Abnahme auf Windows

- **WHEN** das Abnahmeskript auf Windows oder einer anderen Plattform läuft
- **THEN** sind Gesamtstatus und sämtliche macOS-Gates `PENDING` mit `MACOS_RUNNER_EVIDENCE_MISSING`

### Requirement: Installation ist releasegebunden und reversibel

Der Installer MUST Windows und macOS unter PowerShell 7 unterstützen, ausschließlich einen exakten annotierten und installierbaren `spectra-v<SemVer>`-Stand akzeptieren und jeden Payloaddigest vor dem Kopieren prüfen. Wiederholte Installation desselben unveränderten Releases MUST ohne Writes enden. Uninstall MUST ausschließlich bekannte Produktpayloads entfernen und Registry, Konfiguration sowie Kundenprojekte erhalten.

#### Scenario: Branch statt Release

- **WHEN** als Installationsquelle `main`, ein Featurebranch oder ein nicht exakt ausgecheckter Release-Tag verwendet wird
- **THEN** endet die Installation vor jedem Write fail-closed

#### Scenario: Idempotente Reinstallation

- **WHEN** derselbe validierte Release erneut in dasselbe unveränderte Ziel installiert wird
- **THEN** meldet der Installer `ALREADY_INSTALLED` und verändert keine Datei

#### Scenario: Uninstall mit Kundenprojekt

- **WHEN** eine Installation entfernt wird
- **THEN** bleiben Registry-, Config- und Kundenprojektdateien unverändert erhalten

### Requirement: Portabilitätsworkflow erzeugt bereinigte Evidence

Die Candidate-WIP-Abnahme MUST unter `windows-latest` und `macos-14` aus einem frischen Checkout eines expliziten annotierten Release-Tags laufen. Sie MUST Doctor, Installation, Idempotenz, Init/Adoption, Registry, Validation, Snapshot, Kundenisolation, Remote-Write-Sperre und Uninstall prüfen und eine bereinigte JSON-Evidence hochladen. Ein Skip oder Nicht-macOS-Lauf MUST niemals als macOS-PASS gelten.

#### Scenario: Workflow ohne annotierten Tag

- **WHEN** der Workflow mit Branch, SHA ohne annotierten Tag oder ungültigem Tagnamen gestartet wird
- **THEN** endet er fail-closed vor der Installation

### Requirement: Gemeinsame PowerShell-Laufzeit bleibt plattformneutral

Spectra MUST von PowerShell deserialisierte `DateTime`- und `DateTimeOffset`-Werte vor der gemeinsamen Schemaprüfung deterministisch als UTC-ISO-8601-Strings behandeln. Temporäre Testpfade MUST über die Plattform-API bestimmt werden. Kindprozesse MUST denselben aktuellen PowerShell-Host verwenden. Link-Negativtests MUST unter Windows Junctions und unter macOS symbolische Links fail-closed prüfen.

Die Releasebindung MUST die beiden semantisch identischen kanonischen HTTPS-Remoteformen `https://github.com/sivla/BCProjectOS` und `https://github.com/sivla/BCProjectOS.git` akzeptieren. Benutzerinformationen, SSH-Remotes, andere Repositories und bloße Präfixtreffer MUST fail-closed bleiben.

Der Installer MUST Payloadbytes aus den Git-Blobs des gebundenen `source_commit` extrahieren und den SHA-256-Digest nach dem Schreiben erneut prüfen. Er MUST unabhängig von Arbeitsbaum-Zeilenendennormalisierung sein und unter macOS den im Manifest gebundenen Modus `100644` beziehungsweise `100755` wiederherstellen. Das finale Release-Manifest und seine Checksum-Datei MUST als getrennte, taggebundene Betriebsmetadaten mitinstalliert und beim Uninstall wieder entfernt werden.

Die Moduswiederherstellung MUST mit BSD-`chmod` auf macOS funktionieren. Evidence-Schreiber MUST sowohl absolute als auch dateinamensrelative Ausgabepfade atomar unterstützen; Workflow-Kindprozesse MUST ihren Exitcode vor dem Lesen der Evidence explizit prüfen.

Eine lokal erzeugte macOS-Fresh-Clone-Prüfkopie MUST vor der Releaseprüfung explizit auf den kanonischen Repository-Remote gebunden werden. Ein lokaler Quellpfad darf niemals als veröffentlichte Repository-Identität akzeptiert werden.

`bootstrap -Apply` MUST bei einem sauberen macOS-XDG-First-Run sowohl den Config- als auch den Registry-Parent sicher erzeugen. Der nachfolgende Doctor MUST deshalb ohne manuelle Voranlage der XDG-Unterverzeichnisse starten können.

Doctor und installierte Vertragstests MUST eine vollständig validierte `.spectra-install.json` samt aktuellem Release-Manifest als Alternative zu einem Produkt-Git-Checkout akzeptieren. Untergates MUST die tatsächlich geprüfte Releaseversion weiterreichen und dürfen in der installierten Kopie keine alte Manifestversion voraussetzen.

#### Scenario: Echter macOS-Runner ohne TEMP

- **WHEN** der Portabilitätsvertrag unter PowerShell 7 auf macOS ohne gesetztes `TEMP` ausgeführt wird
- **THEN** verwenden Tests den System-Temppfad, Kindprozesse `pwsh` und der SymbolicLink-Negativfall bleibt wirksam

#### Scenario: Actions-Checkout verwendet den kanonischen Remote ohne Suffix

- **WHEN** ein unveränderlicher Release-Tag durch `actions/checkout` mit `https://github.com/sivla/BCProjectOS` ausgecheckt wird
- **THEN** bleibt die Releasebindung gültig, während jede nicht exakt kanonische Repository-Identität blockiert wird

#### Scenario: Checkout normalisiert Textdateien im Arbeitsbaum

- **WHEN** der Arbeitsbaum andere Zeilenenden als die gebundenen Git-Blobs besitzt
- **THEN** installiert Spectra weiterhin exakt die Blobbytes und der installierte SHA-256-Digest entspricht dem Release-Manifest

### Requirement: Registry ist lokal, relativ und idempotent

Das Projektregister MUST Workspacepfade relativ zu seinem Root speichern und wiederholte identische Registrierung ohne Dateiveränderung akzeptieren. Absolute, traversierende, plattformgebundene oder root-externe Pfade MUST fail-closed sein.

#### Scenario: Windows- oder macOS-Pfad

- **WHEN** dieselbe relative Struktur mit nativen Windows- oder POSIX-Separatoren übergeben wird
- **THEN** entsteht derselbe kanonische Registrypfad mit `/`

### Requirement: Twin-Handoff ist read-only und snapshotgebunden

Der Twin-Handoff MUST genau einen validierten Snapshot über relativen Pfad, SHA-256, Produktbindung und `read_only=true` referenzieren. Er MUST keine Kundeninhalte, Secrets oder absoluten Pfade enthalten.

#### Scenario: Manipulierter Snapshot

- **WHEN** Snapshotbytes oder relative Referenz nach Handoff-Erzeugung abweichen
- **THEN** schlägt die Validierung fail-closed fehl

### Requirement: Remote-Systeme bleiben außerhalb des Bootstrap

Bootstrap MUST vorhandene Jira-/Confluence-Zielbindungen übernehmen können, darf aber keine Remote-Mutation auslösen. Live-Apply bleibt dem separat autorisierten Adaptervertrag vorbehalten.

#### Scenario: Remote-Write-Anforderung

- **WHEN** Bootstrap eine Remote-Mutation anfordert
- **THEN** wird sie ohne lokale oder entfernte Schreibwirkung abgelehnt

### Requirement: Source Inventory ist revisions- und checkpointgebunden

Jeder Snapshot MUST seine Quellen stabil identifizieren. Confluence-Seiten MUST Seiten-ID, Version, normalisierten Inhalts-Hash, Attachment-Digests, Space-/Parent-Bindung und Sync-Checkpoint enthalten. Unbekannte Quellen, unstabile IDs, fehlende Checkpoints oder Digestfehler MUST fail-closed sein.

#### Scenario: Fehlender Checkpoint

- **WHEN** eine Confluence-Quelle keine stabile ID oder keinen Sync-Checkpoint besitzt
- **THEN** wird der Snapshot fail-closed abgelehnt

### Requirement: Delta und Tombstones sind vollständig nachvollziehbar

Delta MUST ausschließlich `added`, `modified`, `renamed`, `moved`, `deleted`, `inaccessible` oder `conflicted` verwenden. Geloeschte und unzugängliche Objekte MUST passende Tombstones besitzen; Tombstones ohne belegtes Delta sind unzulässig.

#### Scenario: Tombstone ohne Delta

- **WHEN** ein Tombstone kein passendes `deleted`- oder `inaccessible`-Delta bindet
- **THEN** wird der Snapshot fail-closed abgelehnt

### Requirement: Wissen wird erst nach Review zur Wahrheit

Wissensänderungssätze MUST Quelle, Reviewstatus und betroffene Artefakte binden. Nur `accepted` darf als Wahrheit projiziert werden. Coverage, Widerspruchsregister und Brownfield-Reconciliation MUST offene Lücken sichtbar halten.

#### Scenario: Ungeprüftes Wissen

- **WHEN** ein pending Wissensänderungssatz als Wahrheit projiziert wird
- **THEN** wird der Snapshot fail-closed abgelehnt

### Requirement: Snapshot-Releases sind immutable und kundensepariert

Jeder Katalogeintrag MUST genau einen freigegebenen immutable Snapshot-Release referenzieren. `current.json` ist nur ein Zeiger. Cross-Customer- oder Cross-Project-Referenzen, veränderte Releasebytes und Katalogeinträge ohne freigegebenen Snapshot MUST fail-closed sein.

#### Scenario: Kundenübergreifende Referenz

- **WHEN** ein Katalogprojekt ein Snapshot-Release eines anderen Kunden referenziert
- **THEN** wird der Katalog fail-closed abgelehnt

### Requirement: Filesystem und HTTP verwenden denselben Datenvertrag

Filesystem- und HTTP-Transport MUST denselben Schema-Identifier, Media Type und Payloaddigest für dasselbe Snapshotobjekt verwenden. Divergierende Transportsemantik ist unzulässig. Commit-SHAs MAY ausschließlich unter Snapshot-Provenienz erscheinen und MUST für den Twin keine Laufzeitadresse bilden.

#### Scenario: Divergierender Transport

- **WHEN** Filesystem- und HTTP-Transport unterschiedliche Payloaddigests ausweisen
- **THEN** wird das Release fail-closed abgelehnt
