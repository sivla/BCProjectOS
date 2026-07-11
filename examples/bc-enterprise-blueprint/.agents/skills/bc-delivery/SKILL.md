---
name: bc-delivery
description: Generate, inspect, and gate local Business Central delivery packages from this repository's OpenSpec changes. Use for creating Epic/Story/Task drafts, UAT plans, Confluence-style documentation, training material, release drafts, manifests, or for checking Planning, BuildReady, and ReleaseReady without publishing to external systems.
---

# BC Delivery

Operate from the repository root containing `openspec/config.yaml` and `automation/`.

## Workflow

1. Read `AGENTS.md`, the selected change's six core artifacts, and referenced company, business, application, and project sources.
2. Confirm `delivery-plan.json` uses stable IDs, the intended Epic, only required deliverables, and `externalPublishingEnabled: false`.
3. Run the Planning gate before generation or implementation.
4. Generate the local package with `automation/Generate-Deliverables.ps1`.
5. Run BuildReady and report every blocker exactly as emitted.
6. Run ReleaseReady only when implementation and evidence are in scope.

## Commands

```powershell
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate Planning
powershell -ExecutionPolicy Bypass -File automation/Generate-Deliverables.ps1 -ChangeId <change-id>
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate BuildReady
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate ReleaseReady
```

Use `-Force` only to regenerate an existing managed package. The generator preserves `evidence.json`.

## Integrity Rules

- Never publish to Jira, Azure DevOps, Confluence, BC, or another external system.
- Never edit generated files under `deliverables/<change-id>/` manually.
- Never mark tasks complete without performing and verifying the work.
- Never change Evidence status without a concrete local reference.
- Treat `TBD`, `BLOCKER:`, unapproved business rules, stale hashes, missing outputs, open tasks, and absent evidence as blockers.
- Do not confuse OpenSpec artifact completion with BuildReady or ReleaseReady.
- Preserve the hierarchy selected by the Delivery Plan. An existing Epic such as `EPIC-SALES` remains a reference; Requirements become Stories and mapped tasks become Tasks.

## Result

Report:

- selected Change ID and Epic mode/source ID;
- generated output path and counts;
- Planning, BuildReady, and ReleaseReady status as applicable;
- exact blockers and the next source file that must change;
- confirmation that no external writes occurred.
