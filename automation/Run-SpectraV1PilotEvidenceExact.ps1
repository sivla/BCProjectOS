[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path,[string]$ProductRoot)
try{& (Join-Path $PSScriptRoot 'Test-SpectraV1PilotEvidence.ps1') -Path $Path -ProductRoot $ProductRoot|Out-Null;Write-Output 'PASS';exit 0}catch{Write-Output $_.Exception.Message;exit 1}
