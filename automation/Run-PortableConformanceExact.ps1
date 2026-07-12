[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop';try{& (Join-Path $PSScriptRoot 'Invoke-PortableFullConformance.ps1') -Path $Path;exit 0}catch{Write-Output $_.Exception.Message.Split([Environment]::NewLine)[0];exit 1}
