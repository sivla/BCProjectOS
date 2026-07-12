[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'
try{& (Join-Path $PSScriptRoot 'Test-ReferenceGraphCoverage.ps1') -Path $Path *> $null;Write-Output 'PASS';exit 0}catch{Write-Output $_.Exception.Message.Split([Environment]::NewLine)[0].Split(':')[0];exit 1}
