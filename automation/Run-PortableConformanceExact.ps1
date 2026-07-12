[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop';try{& (Join-Path $PSScriptRoot 'Invoke-PortableFullConformance.ps1') -Path $Path *> $null;Write-Output 'PASS';exit 0}catch{$m=$_.Exception.Message.Split([Environment]::NewLine)[0];Write-Output $m.Split(':')[0];exit 1}
