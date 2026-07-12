[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop';& (Join-Path $PSScriptRoot 'Test-PortableStructuralGates.ps1') -Path $Path|Out-Null;& (Join-Path $PSScriptRoot 'Test-PortableProjectStoryConformance.ps1') -Path $Path
