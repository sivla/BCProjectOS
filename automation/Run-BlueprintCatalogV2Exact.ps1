[CmdletBinding()]
param([Parameter(Mandatory)][string]$CatalogPath)
$ErrorActionPreference='Stop'
try { & (Join-Path $PSScriptRoot 'Test-BlueprintCatalogV2.ps1') -CatalogPath $CatalogPath; Write-Output 'PASS'; exit 0 }
catch { Write-Output ([string]$_.Exception.Message).Split([Environment]::NewLine)[0]; exit 1 }
