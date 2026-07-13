[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$d=Join-Path ([IO.Path]::GetTempPath()) ('inbox-positive-'+[guid]::NewGuid().ToString('N'))
try {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\New-SyntheticInformationInbox.ps1') -Destination $d | Out-Null
  $json=Join-Path $d 'information-inbox.json';$target=Join-Path $d 'targets/status.md';$jsonBefore=(Get-FileHash $json -Algorithm SHA256).Hash;$targetBefore=(Get-FileHash $target -Algorithm SHA256).Hash
  foreach($run in 1..2){& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\Run-InformationInboxExact.ps1') -Path $d | Out-Null;if($LASTEXITCODE-ne0){throw "INBOX_POSITIVE_VALIDATION_FAILED:$run"}}
  if((Get-FileHash $json -Algorithm SHA256).Hash -cne $jsonBefore -or (Get-FileHash $target -Algorithm SHA256).Hash -cne $targetBefore){throw 'INBOX_VALIDATOR_MUTATED_SOURCE'}
  Write-Host 'PASS: Information-Inbox positive, idempotent und Zielartefakte unverändert.'
} finally {if(Test-Path $d){Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue}}
