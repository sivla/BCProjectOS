# Vertrag

- Freiheit: niedrig; externe Mutation nur nach expliziter Rollenfreigabe.
- Zulässige Writes: freigegebene Jira-/Confluence-Create/Update-Aktionen aus einem unveränderten Plan.
- Verboten: Rovo, implizite Löschung, fremde Inhalte überschreiben, Secrets persistieren.
- Preconditions: Site-/Space-/Projectbindung, Revision Guard, Capability/Permission und Runtime-Secret-Referenz.
- Evidence: Plan-Digest, Freigaberolle, Read-back, External-ID-Mapping und Restplan.
- Stop-Codes: `ATLASSIAN_TARGET_UNBOUND`, `ATLASSIAN_REVISION_CHANGED`, `ATLASSIAN_CONFLICT`, `ATLASSIAN_PERMISSION_DENIED`.
- Reset/Rollback: keine globale Rücknahme versprechen; sichere Restplanung und Read-back verwenden.
