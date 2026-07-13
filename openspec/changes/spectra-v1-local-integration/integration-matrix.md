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

## Commitgebundene lokale Evidence

- Die normale Zusammenfuehrung liegt als Mergecommit mit den unveraenderten Source-Linien als Eltern vor; es gab weder Rebase noch Force.
- Die zentrale Integrationssuite und neun isolierte Manipulationsfaelle sind gruen.
- P0-/Init-Fokus: 13 von 13 Skripten gruen; darunter 11 Skillfamilien, 13 Skill-Negativfaelle, 11 Forward-Trigger, 6 Guided-Init-, 17 Project-Init-, 9 Scenario- und 7 Pilot-Evidence-Negativfaelle.
- Foundation-Fokus: Customer-Knowledge inklusive 29 Negativfaellen, Document-Projection inklusive 12 Negativfaellen und BC-Reference-Library inklusive 21 Negativfaellen gruen.
- Neue Produktvertraege: Story-Cardinality inklusive drei Hierarchie-Negativfaellen, Portable-Conformance inklusive 32 Negativfaellen und Oracle, Information-Inbox inklusive 11 Negativfaellen, Blueprint V2 inklusive 23 Negativfaellen sowie Consultant-Knowledge inklusive 16 Negativfaellen gruen.
- Breite Regression: Operator positiv/negativ, Backup/Restore, Upgrade, Workspace-Validator, Schema-Paritaet, synthetische und installierbare Fixture-Gates, releasegebundenes Init sowie Product Contract gruen.
- OpenSpec strict ist fuer alle 29 Specs gruen; Release-Diff gegen RC.1, feste Story-Kardinalitaeten, absolute lokale Pfade sowie Kunden-/Secret-/Tenant-Marker zeigen keine unzulaessige Integration.
- RC.1 bleibt die einzige veroeffentlichte Basis. Der Integrationsbranch ist kein Candidate und bleibt `PENDING_BCPROJECTOS_RELEASE`.
- No-Hardlinks-Fresh-Clone: zentrale Integration, neun Manipulationsfaelle, Product Contract, 29 OpenSpec-Items, 13 P0-/Init-Skripte, 12 Foundation-Skripte, zehn neue Vertragssuites und zehn breite Regressionen sind commitgebunden gruen; alle Pruefkopien blieben sauber und wurden sicher entfernt.
