# Change: P0-Skillkatalog für Spectra

## Why

Spectra besitzt Produktverträge und Automationen, aber noch keine knappen, versionierten Betriebsanweisungen, die Codex zuverlässig auf den richtigen Projektworkflow und Freiheitsgrad binden. Elf klar getrennte, verb-led Skillfamilien sollen die V1-Arbeit abdecken, ohne Seiten-/Prozess-Skillflut oder Kundendaten im Produktpayload.

## What Changes

- Versionierter Katalog für elf P0-Skillfamilien mit eindeutigen Triggern und Risikoklassen.
- Kurze `SKILL.md`, passende `agents/openai.yaml` und direkte Referenzen.
- Gemeinsamer Safety-/Evidence-Vertrag für Zielbindung, zulässige Writes, Freigaben, Reset/Rollback, Evidence und Stop-Codes.
- Fail-closed Validator für Namen, Metadaten, Triggerüberschneidung, Referenzen und mutierende Guardrails.
- Quick-Validation und minimale Forward-Szenarien ohne Live-Systeme.

## Nicht-Scope

- Keine Live-Atlassian-, BC-, Browser-, Posting-, Import-, Reset- oder Deploymentausführung.
- Keine Prozessskills je P2P/O2C/Page und keine Kundenwerte, Authstates oder Runtime-Evidence.
- Keine Journalfunktion, kein Candidate und keine Releaseversion.
