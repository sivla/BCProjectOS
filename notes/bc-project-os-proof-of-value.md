# BCProjectOS Proof of Value

Status: Executed locally as POV-001; Decision: Reduce
Duration limit: 2-4 person-days

## Purpose

Prove that a small BCProjectOS workflow saves time and improves traceability before building the full MVP roadmap. The Proof of Value is allowed to be manual-assisted. It must not become a hidden platform implementation.

## Pilot Scenario

Use one simulated or safely anonymized Business Central customer context containing:

- one customer workspace;
- five mixed external files;
- one meeting transcript;
- one meeting preparation and follow-up package;
- one support case;
- one small Sales, Purchasing, Inventory, or Finance change;
- one project and budget update;
- one support item promoted to the existing OpenSpec delivery flow.

## Five Workflows to Prove

### 1. External File Intake

- register the original without modifying it;
- calculate a hash;
- classify as documentation, evidence, test-file, transcript, or unknown;
- assign only necessary controlled tags and relations;
- route uncertain content to review;
- record the archive outcome.

### 2. Meeting Preparation and Follow-up

- create preparation and agenda context;
- preserve the source transcript;
- create a Draft meeting record;
- identify decisions, actions, risks, open questions, and ticket candidates;
- record preparation, meeting, and follow-up effort separately;
- require review before treating anything as confirmed.

### 3. Support Case

- record intake, classification, priority rationale, BC area, status, effort, evidence, and result;
- close a simple case without OpenSpec;
- identify when promotion to a governed change is justified.

### 4. Project and Budget Update

- record project objective, BC workstream, milestone, planned effort, actual effort, remaining effort, and forecast;
- include meeting preparation and follow-up;
- avoid accounting or invoicing behavior.

### 5. Governed Change

- promote one support or meeting outcome to OpenSpec;
- reference an existing Epic such as `EPIC-SALES`;
- generate only locally required delivery outputs;
- run Planning, BuildReady, and ReleaseReady honestly;
- keep unresolved business rules and missing evidence blocked.

## Measurement

Record for every workflow:

| Measure | Question |
|---|---|
| Setup effort | How long did preparation and metadata entry take? |
| Processing effort | How long did the workflow itself take? |
| Review effort | How many classifications or generated statements required correction? |
| Retrieval | Could the source and result be found through IDs and relations? |
| Reuse | Which generated outputs would be used in real customer work? |
| Waste | Which files, fields, or steps added no practical value? |
| Trust | Did any generated output imply an unproven decision, status, or approval? |

Do not invent a time-saving target before establishing the current manual baseline.

## Go Criteria

- no original is lost, overwritten, or confused with derived content;
- all five workflows remain understandable without reconstructing chat history;
- the user would voluntarily use the workflow again;
- useful outputs clearly outweigh metadata and review effort;
- support remains materially lighter than governed delivery;
- no false decision, approval, UAT, training, or release claim occurs;
- the pilot identifies a smaller retained field and tag set rather than expanding it by default.

## Stop or Reduce Criteria

- metadata entry costs more time than the workflow saves;
- generated artifacts are mostly ignored;
- the same fact must be maintained in several canonical locations;
- classification requires constant manual correction;
- a simple support case becomes a documentation project;
- Project Twin or another UI becomes necessary just to understand the local source model;
- the pilot starts recreating Jira, Confluence, SharePoint, accounting, or Business Central.

## Explicitly Out of Scope

- platform API or database;
- Project Twin implementation changes;
- external publishing or bidirectional synchronization;
- production customer data;
- universal OCR or file-format support;
- multi-user access and authentication;
- a final enterprise-wide taxonomy.

## Exit Package

- completed pilot workspace;
- baseline and measured effort table;
- retained, removed, and deferred fields/tags;
- list of genuinely used outputs;
- risks and maintenance observations;
- explicit Go, Reduce, Reframe, or Stop decision;
- adjusted MVP 0 scope if continuation is justified.

## POV-001 Result

The fully synthetic local pilot is stored under `pilots/POV-001/`. Its read-only validator confirms five immutable registered originals, fail-closed unknown-file routing, a Draft meeting package, connected support/project/budget records, exactly one governed promotion, and honest Planning/BuildReady/ReleaseReady outcomes.

Observed result:

- Planning passes.
- BuildReady remains blocked by the unapproved business rule and unresolved design.
- ReleaseReady remains blocked by the same preconditions, open tasks, and missing execution/approval Evidence.
- The existing spike generates 39 managed files; POV-001 retains only six selected delivery files and does not copy Confluence or training output.
- No manual baseline exists, so no time saving is claimed.
- No new tag dimension was required.

Recommendation: **Reduce**. Retain the local traceability and fail-closed core, but keep MVP 1 metadata and generated outputs smaller than the complete delivery spike. Final decision: **Reduce**, explicitly approved by the user on 2026-07-11. This authorizes only the reduced MVP 1 scope; later MVPs and platform work remain gated separately.
