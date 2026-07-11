# Design

`New-SyntheticBCBasicFixture.ps1` erzeugt nur eine isolierte, nicht installierbare Fixture mit vier BC-Bereichen und einer expliziten Prozesskette. `Test-SyntheticBCBasicWorkspace.ps1` validiert sie read-only, fail-closed und ohne Netzwerk. Alle Records bleiben Draft oder Active und enthalten keine Kundenidentität. Die Gap-/Nutzungsanalyse in `notes/spectra-bc-basic-gap-analysis.md` belegt das Delta von Alpha.2 und begründet `0.1.0-beta.1` als Candidate; für `1.0.0` fehlen reale Pilot-/Betriebsevidence und externe Integrationsnachweise.
