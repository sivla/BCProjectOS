# P0-Skillkatalog

## ADDED Requirements

### Requirement: Skillfamilien sind triggerklar und überschneidungsarm
Spectra MUST elf verb-led P0-Familien mit vollständiger Triggerbeschreibung und eindeutigem Verantwortungsbereich führen.

#### Scenario: Intake versus Atlassian-Materialisierung
- **WHEN** neue Projektinformationen aufgenommen werden
- **THEN** darf `process-project-intake` niemals implizit `materialize-atlassian-project` auslösen

### Requirement: Risiko bestimmt den Freiheitsgrad
Spectra MUST mutierende oder irreversible Abläufe an low-freedom Guardrails, explizite Freigaben und Stop-Codes binden.

#### Scenario: Nicht autorisierte BC-Mutation
- **WHEN** keine explizite Sandboxbindung vorliegt
- **THEN** darf `operate-bc-pilot-sandbox` keine Mutation ausführen

### Requirement: Skills bleiben generisch und kompakt
Spectra MUST Kundenwerte, Authstates und Runtime-Evidence ausschließen und Varianten über direkte Referenzen statt neue Skills modellieren.

#### Scenario: Kundenspezifischer Wert
- **WHEN** ein Skillpayload einen Tenant-, Kunden- oder Secretwert enthält
- **THEN** lehnt der Katalogvalidator den Stand fail-closed ab

### Requirement: Metadaten und Referenzen sind validierbar
Spectra MUST Namen, Frontmatter, OpenAI-Metadaten, Pflichtreferenzen und lokale Links deterministisch prüfen.

#### Scenario: Fehlende Safety-Referenz
- **WHEN** ein mutierender Skill keine Safety-/Evidence-Referenz besitzt
- **THEN** endet die Validierung mit einem stabilen Fehlercode
