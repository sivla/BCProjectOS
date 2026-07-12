[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path,[string]$CoveragePath)
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'Test-PortableSchema.ps1') -StoryPath $Path|Out-Null
& (Join-Path $PSScriptRoot 'Test-PortableProjectStoryConformance.ps1') -Path $Path|Out-Null
& (Join-Path $PSScriptRoot 'Test-PortableStructuralGates.ps1') -Path $Path|Out-Null
if($CoveragePath){& (Join-Path $PSScriptRoot 'Test-ReferenceGraphCoverage.ps1') -Path $CoveragePath|Out-Null}
