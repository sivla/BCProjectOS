[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path,[string]$ProductRoot)
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
$contractRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'));$product=if($ProductRoot){[IO.Path]::GetFullPath($ProductRoot)}else{$contractRoot}
$file=[IO.Path]::GetFullPath($Path);if(-not(Test-Path $file -PathType Leaf)){throw 'PILOT_EVIDENCE_MISSING'};$before=(Get-FileHash $file -Algorithm SHA256).Hash;$x=Get-Content $file -Raw|ConvertFrom-Json
. (Join-Path $PSScriptRoot 'Spectra.JsonSchema.ps1');$schema=Get-Content (Join-Path $contractRoot 'schemas\v1-pilot-evidence.schema.json') -Raw|ConvertFrom-Json;try{Test-SpectraJsonSchema -Value $x -Schema $schema -RootSchema $schema -Path root}catch{throw 'PILOT_EVIDENCE_SCHEMA_INVALID'}
if([string]$x.release_version-ne'0.14.0-alpha.1'-or[string]$x.release_tag-ne'spectra-v0.14.0-alpha.1'){throw 'PILOT_RELEASE_BINDING_INVALID'}
$tagOutput=@(&git -C $product rev-parse 'refs/tags/spectra-v0.14.0-alpha.1^{commit}' 2>$null);$tagExit=$LASTEXITCODE;$resolvedTagCommit=([string]($tagOutput|Select-Object -First 1)).Trim();if($tagExit-ne0-or$resolvedTagCommit-cne[string]$x.tag_commit){throw 'PILOT_RELEASE_BINDING_INVALID'}
if($x.implementation.status-ne'PASS'){throw 'PILOT_IMPLEMENTATION_INCOMPLETE'};if($x.support_only.status-ne'PASS'){throw 'PILOT_SUPPORT_INCOMPLETE'}
if($x.upgrade.status-ne'PASS'){throw 'PILOT_UPGRADE_UNPROVEN'};if($x.recovery.status-ne'PASS'){throw 'PILOT_RECOVERY_UNPROVEN'};if($x.documentation.status-ne'PASS'-or[int]$x.documentation.files_checked-lt6-or$x.documentation.language-ne'de'){throw 'PILOT_DOCUMENTATION_UNPROVEN'}
if([int]$x.open_product_p1-gt0-or[int]$x.open_product_p2-gt0){throw 'PILOT_OPEN_HIGH_PRIORITY'};if($x.rc_decision-ne'GO'){throw 'PILOT_RC_DECISION_INVALID'}
$raw=Get-Content $file -Raw;if($raw-match'(?i)(credential_marker|tenant_marker|customer_content_marker|universaarl|uabc)'){throw 'PILOT_CUSTOMER_OR_SECRET_MARKER'};if((Get-FileHash $file -Algorithm SHA256).Hash-ne$before){throw 'PILOT_VALIDATOR_MUTATED_SOURCE'}
Write-Host 'PASS: V1-Pilot- und RC-Evidence ist releasegebunden, vollständig und read-only.'
