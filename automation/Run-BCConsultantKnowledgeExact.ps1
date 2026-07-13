param([Parameter(Mandatory)][string]$Path)
try{$null=&(Join-Path $PSScriptRoot 'Test-BCConsultantKnowledge.ps1') -Path $Path;Write-Output 'PASS';exit 0}catch{Write-Output ([string]$_.Exception.Message).Split([Environment]::NewLine)[0];exit 1}
