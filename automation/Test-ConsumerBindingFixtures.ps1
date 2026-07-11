[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$fixtureRoot = Join-Path $root 'tests\consumer-binding'
$validator = Join-Path $PSScriptRoot 'Test-ConsumerBinding.ps1'

& powershell -NoProfile -ExecutionPolicy Bypass -File $validator -Path (Join-Path $fixtureRoot 'pending-valid.json')
if ($LASTEXITCODE -ne 0) { throw 'PENDING_POSITIVE_FIXTURE_FAILED' }

foreach ($fixture in @('pending-with-version.json','bound-unverified.json')) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $validator -Path (Join-Path $fixtureRoot $fixture) -RepositoryRoot $root
    if ($LASTEXITCODE -eq 0) { throw "NEGATIVE_FIXTURE_ACCEPTED: $fixture" }
    Write-Host "PASS: Negative consumer-binding fixture failed closed: $fixture"
}

Write-Host 'PASS: Consumer-binding positive and negative fixtures are deterministic.'
