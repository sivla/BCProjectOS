[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$temp = Join-Path $env:TEMP ('spectra-foundation-cli-' + [guid]::NewGuid().ToString('N'))
try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  foreach ($profile in @('implementation', 'support-only')) {
    $workspace = Join-Path $temp $profile
    $dry = & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command generate-customer-knowledge -Workspace $workspace -Profile $profile | ConvertFrom-Json
    if ($dry.writes_performed -or (Test-Path -LiteralPath $workspace)) { throw "FOUNDATION_CLI_DRYRUN_MUTATED:$profile" }
    $apply = & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command generate-customer-knowledge -Workspace $workspace -Profile $profile -Apply | ConvertFrom-Json
    if (-not $apply.writes_performed -or $apply.status -ne 'APPLIED') { throw "FOUNDATION_CLI_APPLY_FAILED:$profile" }
    $validate = & (Join-Path $PSScriptRoot 'Invoke-Spectra.ps1') -Command validate-customer-knowledge -Workspace $workspace | ConvertFrom-Json
    if ($validate.status -ne 'VALIDATED' -or $validate.writes_performed) { throw "FOUNDATION_CLI_VALIDATE_FAILED:$profile" }
  }
  Write-Host 'PASS: Kundenworkspace-/Knowledge-Inbox-CLI ist dry-run-first und validiert beide Profile read-only.'
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
