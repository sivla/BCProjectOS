[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath($Path)
$before=@{};Get-ChildItem $root -Recurse -File|ForEach-Object{$before[$_.FullName]=(Get-FileHash $_.FullName -Algorithm SHA256).Hash}
$fixture=Get-Content (Join-Path $root 'fixture.json') -Raw|ConvertFrom-Json
if($fixture.product_id -ne 'spectra' -or $fixture.synthetic -ne $true -or $fixture.customer_evidence -ne $false -or $fixture.profile -notin @('implementation','support-only')){throw 'SPECTRA09_FIXTURE_IDENTITY_INVALID'}
$reconciliation=Get-Content (Join-Path $root 'reconciliation\project-reconciliation.json') -Raw|ConvertFrom-Json
$provenance=Get-Content (Join-Path $root 'adapter\adapter-provenance.json') -Raw|ConvertFrom-Json
if($reconciliation.profile -ne $fixture.profile -or $provenance.profile -ne $fixture.profile){throw 'SPECTRA09_PROFILE_BOUNDARY_INVALID'}
& (Join-Path $PSScriptRoot 'Test-ProjectReconciliation.ps1') -Workspace $root
& (Join-Path $PSScriptRoot 'Test-AdapterProvenance.ps1') -Workspace $root
$after=@{};Get-ChildItem $root -Recurse -File|ForEach-Object{$after[$_.FullName]=(Get-FileHash $_.FullName -Algorithm SHA256).Hash}
if($before.Count -ne $after.Count -or @($before.Keys|Where-Object{$after[$_] -ne $before[$_]}).Count -gt 0){throw 'SPECTRA09_VALIDATOR_MUTATED_FIXTURE'}
Write-Host "PASS: Synthetisches Spectra-0.9-Profil '$($fixture.profile)' validiert strikt read-only."
