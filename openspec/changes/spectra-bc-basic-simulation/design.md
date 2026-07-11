# Design

`New-SyntheticBCBasicFixture.ps1` erzeugt nur eine isolierte, nicht installierbare Fixture mit vier BC-Bereichen und einer expliziten Prozesskette. `Test-SyntheticBCBasicWorkspace.ps1` validiert sie read-only, fail-closed und ohne Netzwerk. Alle Records bleiben Draft oder Active und enthalten keine Kundenidentität. Eine Releaseversion wird erst nach der Analyse festgelegt.
