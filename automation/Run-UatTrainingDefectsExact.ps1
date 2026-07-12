[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop';try{& (Join-Path $PSScriptRoot 'Test-UatTrainingDefects.ps1') -Path $Path|Out-Null;Write-Output 'PASS';exit 0}catch{Write-Output $_.Exception.Message.Split([Environment]::NewLine)[0];exit 1}
