[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$temp = Join-Path $env:TEMP ('spectra-foundation-contract-' + [guid]::NewGuid().ToString('N'))
try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  foreach ($profile in @('implementation', 'support-only')) {
    $a = Join-Path $temp "$profile-a"
    $b = Join-Path $temp "$profile-b"
    & (Join-Path $PSScriptRoot 'New-SyntheticCustomerKnowledgeWorkspace.ps1') -Destination $a -Profile $profile | Out-Null
    & (Join-Path $PSScriptRoot 'New-SyntheticCustomerKnowledgeWorkspace.ps1') -Destination $b -Profile $profile | Out-Null
    foreach ($relative in @('customer-workspace-foundation.json', 'knowledge-inbox.json', 'inbox\originals\meeting.txt')) {
      if ((Get-FileHash -LiteralPath (Join-Path $a $relative) -Algorithm SHA256).Hash -cne (Get-FileHash -LiteralPath (Join-Path $b $relative) -Algorithm SHA256).Hash) { throw "FOUNDATION_GENERATOR_NOT_DETERMINISTIC:${profile}:$relative" }
    }
    $beforeFoundation = (Get-FileHash -LiteralPath (Join-Path $a 'customer-workspace-foundation.json')).Hash
    $beforeInbox = (Get-FileHash -LiteralPath (Join-Path $a 'knowledge-inbox.json')).Hash
    & (Join-Path $PSScriptRoot 'Test-CustomerKnowledgeWorkspace.ps1') -Path $a | Out-Null
    if ((Get-FileHash -LiteralPath (Join-Path $a 'customer-workspace-foundation.json')).Hash -cne $beforeFoundation -or (Get-FileHash -LiteralPath (Join-Path $a 'knowledge-inbox.json')).Hash -cne $beforeInbox) { throw "FOUNDATION_VALIDATOR_MUTATED_SOURCE:${profile}" }
    $foundation = Get-Content -LiteralPath (Join-Path $a 'customer-workspace-foundation.json') -Raw | ConvertFrom-Json
    if ($profile -eq 'support-only' -and @($foundation.projects).Count -ne 0) { throw 'FOUNDATION_SUPPORT_REQUIRES_NO_PROJECT' }
    if (@($foundation.role_assignments | Where-Object occupant_status -in @('pending', 'unknown') | Where-Object { $null -ne $_.person_id }).Count -ne 0) { throw 'FOUNDATION_PENDING_ROLE_FABRICATED_PERSON' }
  }
  Write-Host 'PASS: Implementation und Support ohne Projekt sind deterministisch; People, Rollen und Inbox bleiben read-only.'
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
