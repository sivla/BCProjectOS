# Spectra in ein bestehendes Projekt einfuehren

## Zweck

Spectra kann ein bestehendes Jira-/Confluence-Projekt aufnehmen, ohne dessen Struktur ungefragt zu veraendern. Der Ablauf bleibt immer: **Bestand lesen, Bindung pruefen, Mapping entscheiden, Plan pruefen, lokal uebernehmen**.

## Vorbereitung

1. Jira- und Confluence-Metadaten als `existing-project-discovery.schema.json` exportieren. Der Export enthaelt Strukturen und Revisionen, keine Seiteninhalte, Tickets, Kommentare oder Secrets.
2. `config.json` mit Customer-/Workspace-/optional Project-ID, Profil, Jira-Projekt/Board, Confluence-Spaces/Roots und Mapping erstellen.
3. Runtime-Schluessel wie `SPECTRA_ATLASSIAN_ACCOUNT` und `SPECTRA_ATLASSIAN_TOKEN` nur im Secret Store oder in der lokalen Prozessumgebung setzen. Spectra committed keine `.env`-Dateien; `AGENTS.md` verbietet dies.

`product_binding` ist entweder ehrlich `PENDING_BCPROJECTOS_RELEASE` mit `installable_blueprint: false` und leeren Releasefeldern oder `BOUND` gegen ein finales Manifest, dessen Source-Commit, Tree, Digest und annotierter Tag im angegebenen Product-Root verifiziert werden. Syntaktisch plausible Werte allein berechtigen niemals zu einem installierbaren Workspace.

## Befehle

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-ExistingProjectAdoption.ps1 -Command inspect -DiscoveryPath .\discovery.json
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-ExistingProjectAdoption.ps1 -Command configure -DiscoveryPath .\discovery.json -ConfigPath .\config.input.json -OutputPath .\config.json
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-ExistingProjectAdoption.ps1 -Command plan -DiscoveryPath .\discovery.json -ConfigPath .\config.json -OutputPath .\adoption-plan.json
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-ExistingProjectAdoption.ps1 -Command validate -DiscoveryPath .\discovery.json -ConfigPath .\config.json -PlanPath .\adoption-plan.json
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-ExistingProjectAdoption.ps1 -Command adopt -DiscoveryPath .\discovery.json -ConfigPath .\config.json -PlanPath .\adoption-plan.json -Destination .\customer-workspace -ExpectedPlanDigest <digest> -Approve
```

`inspect`, `validate` und ein Plan ohne Ausgabepfad schreiben nichts. `adopt` beziehungsweise `apply` erzeugt nur den lokalen Workspace atomar. Ein Aufruf mit `-Remote` wird blockiert, solange kein spaeter separat freigegebener Atlassian-Adapter installiert ist.

## Mapping-Review

- `adopt-as-is`: vorhandene Bezeichnung kann ohne fachliche Umdeutung verwendet werden.
- `explicit-map`: vorhandener Typ, Status, Feld oder Space erhaelt eine explizite Spectra-Rolle.
- `improvement-proposal`: moegliche Verbesserung wird nur in der Proposal-Schicht angezeigt.

BC Basic ist ein synthetisches Referenzprofil. Ein Bestandsprojekt darf andere Typen, Hierarchien, Status und Spaces besitzen. Support-only ist ohne `project_id` gueltig.

## Live-Grenze

Der spaetere Connector muss `read/plan/apply/verify`, minimale Scopes, Revision Guard, idempotente Create/Update/Skip/Conflict-Operationen, Read-back und Restplan implementieren. Loeschen oder Archivieren braucht immer einen eigenen Plan. Dieser Produktblock fuehrt keinerlei Live-Atlassian-Zugriff aus.
