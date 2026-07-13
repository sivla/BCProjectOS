[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Root)
$ErrorActionPreference='Stop';try{& (Join-Path $PSScriptRoot 'Test-SpectraSkillCatalog.ps1') -Root $Root|Out-Null;Write-Output 'PASS';exit 0}catch{Write-Output $_.Exception.Message.Split([Environment]::NewLine)[0];exit 1}
