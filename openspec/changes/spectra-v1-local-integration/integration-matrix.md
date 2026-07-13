# Integrationsmatrix

| Komponente | Source-Commit | Zielpfad | Fuehrender Vertrag | Konfliktentscheidung | Test/Evidence |
|---|---|---|---|---|---|
| Customer-Workspace-Inbox | `2c02c5970b7592fac3fd1fc810b202319c7318ba` | `contract/customer-workspace-knowledge-inbox.md`, zugehoerige Schemas/Automation | Workspace-Identitaet und Basismodell | Foundation bleibt unter der kontrollierten Proposal-Verarbeitung | `Test-CustomerKnowledgeWorkspace*` |
| Information-Inbox-Proposals | `b7ec32e5a31e0cb1a3ef1c2bebba193ef9901e5c` | `contract/information-inbox.md`, `schemas/information-inbox.schema.json` | fuehrender Intake-/Proposal-/Audit-Vertrag | expliziter Uebergangsautomat und getrennte Umsetzung; keine Direktmutation | `Test-InformationInbox*` plus Integrationsmanipulation |
| Kuratierter Blueprint-Katalog | `2c02c5970b7592fac3fd1fc810b202319c7318ba` | `contract/blueprints/` | Legacy-Herkunft | fuer bestehende Init-Auswahl lesbar, nicht fuehrend fuer neue Vorschauen | `Test-BlueprintCatalog*`, Init-Regression |
| Blueprint-Katalog V2 | `b7ec32e5a31e0cb1a3ef1c2bebba193ef9901e5c` | `catalogs/blueprint-catalog-v2.json`, `schemas/blueprint-catalog-v2.schema.json` | fuehrender Blueprint-/Preview-Vertrag | drei Blueprint-Typen, variable Hierarchie, Proposal-only | `Test-BlueprintCatalogV2*` plus Integrationsmanipulation |
| BC Reference Library | `dff88684d062e23794cbfb5423aecd331ac49790` | Registry, Lock-, Index- und Query-Pfade | einzige technische Wissensfoundation | 14 deklarierte Foundation-Blobs exakt einmal und bytegleich | Foundation-Import, 21 Negativfaelle, CLI |
| Consultant Knowledge/Playthrough | `b7ec32e5a31e0cb1a3ef1c2bebba193ef9901e5c` | `catalogs/bc-consultant-knowledge.json`, `contract/bc-consultant-playthrough.md` | fachliche Schicht ueber Reference Library | keine zweite Registry/Cachelogik; CRONUS bleibt Demo-Baseline | `Test-BCConsultantKnowledge*` plus Integrationsmanipulation |
| P0-Skillkatalog | `2c02c5970b7592fac3fd1fc810b202319c7318ba` | `skills/`, Skillkatalog/Validator | 11 versionierte Skillfamilien | Guardrails muessen Inbox-, Blueprint- und Knowledge-Grenzen respektieren | Quick-Validation, 13 Negativfaelle, Forward-Szenarien |
| Project-Story-Kardinalitaet | `b7ec32e5a31e0cb1a3ef1c2bebba193ef9901e5c` | portable Story-Validator und Cardinality-Test | instanzabgeleitete Mengen | keine festen 19/17/15/3- oder Kunden-ID-Annahmen | `Test-PortableProjectStoryCardinality.ps1` |
| Historische Release-Evidence | beide Linien | `release/` und archivierte Evidence | RC.1 bleibt einzige veroeffentlichte Basis | kein Candidate-/Finalclaim fuer den Integrationsbranch | Release-Diff- und Markerpruefung |

Alle Testergebnisse bleiben bis zum commitgebundenen Integrationslauf `PENDING`.
