# Change: Unabhängige V1-Piloten und RC-Evidence

## Why
Spectra `0.14.0-alpha.1` deckt den fachlichen Produktweg von Engagement bis Handover synthetisch ab. Vor einem RC fehlen unabhängige, reproduzierbare Bedien- und Recoverynachweise für Implementation und Support-only.

## What Changes
- Zwei vollständig isolierte Piloten aus frischem Clone: Implementation und Support-only.
- End-to-End-Proof von Initialisierung beziehungsweise Supportaufnahme bis Handover.
- Upgradepfad vom veröffentlichten Vorrelease, Backup-/Restore-Roundtrip und Recoverymatrix.
- Unabhängige Bedienprüfung der deutschen Quickstarts und Operatoranleitungen.
- Konsolidierte 1.0-Akzeptanzmatrix, offene P1/P2 und begründete RC-Entscheidung.
- Vollständige SemVer-Prerelease-Kompatibilität für Alpha, Beta, RC und Final.

## Nicht-Scope
- Keine neue Fachfunktion vor nachgewiesener Pilotlücke.
- Keine Kundeninhalte, Live-Systeme oder reale Kundenevidence.
- Keine Confluence-/Jira-Übernahme; solche Erkenntnisse bleiben unbewertete Blueprint-Candidates.
- Keine Veröffentlichung ohne getrennten Candidate-, Promotion- und Release-Gate.

## SemVer-Entscheidung

Der vollständige V1-Funktionsumfang ist vorhanden und beide Profile sind synthetisch end-to-end nachgewiesen. Der nächste Candidate ist deshalb `1.0.0-rc.1`; `1.0.0` bleibt bis zur unabhängigen RC-Kontrolle gesperrt.
