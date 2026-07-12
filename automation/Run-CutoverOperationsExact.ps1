[CmdletBinding()]param([Parameter(Mandatory=$true)][string]$Path)
try{& (Join-Path $PSScriptRoot 'Test-CutoverOperationsHandover.ps1') -Path $Path|Out-Null;Write-Output 'PASS';exit 0}catch{Write-Output $_.Exception.Message;exit 1}
