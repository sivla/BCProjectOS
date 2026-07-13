[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$temp = Join-Path $env:TEMP ('spectra-foundation-recovery-' + [guid]::NewGuid().ToString('N'))
try {
  New-Item -ItemType Directory -Path $temp | Out-Null
  foreach ($profile in @('implementation', 'support-only')) {
    $workspace = Join-Path $temp "$profile-workspace"
    $backup = Join-Path $temp "$profile-backup"
    $restored = Join-Path $temp "$profile-restored"
    & (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Destination $workspace -Profile $profile -SyntheticFixture | Out-Null
    $foundation = Join-Path $workspace 'generated\customer-knowledge-foundation'
    & (Join-Path $PSScriptRoot 'New-SyntheticCustomerKnowledgeWorkspace.ps1') -Destination $foundation -Profile $profile | Out-Null
    & (Join-Path $PSScriptRoot 'Test-CustomerKnowledgeWorkspace.ps1') -Path $foundation | Out-Null
    $foundationHash = (Get-FileHash -LiteralPath (Join-Path $foundation 'customer-workspace-foundation.json')).Hash
    $inboxHash = (Get-FileHash -LiteralPath (Join-Path $foundation 'knowledge-inbox.json')).Hash
    & (Join-Path $PSScriptRoot 'Backup-Workspace.ps1') -Source $workspace -Destination $backup | Out-Null
    & (Join-Path $PSScriptRoot 'Restore-Workspace.ps1') -Backup $backup -Destination $restored | Out-Null
    $restoredFoundation = Join-Path $restored 'generated\customer-knowledge-foundation'
    & (Join-Path $PSScriptRoot 'Test-CustomerKnowledgeWorkspace.ps1') -Path $restoredFoundation | Out-Null
    if ((Get-FileHash -LiteralPath (Join-Path $restoredFoundation 'customer-workspace-foundation.json')).Hash -cne $foundationHash -or (Get-FileHash -LiteralPath (Join-Path $restoredFoundation 'knowledge-inbox.json')).Hash -cne $inboxHash) { throw "FOUNDATION_RECOVERY_IDENTITY_MISMATCH:$profile" }
  }
  Write-Host 'PASS: Kundenworkspace-/Inbox-Fundament beider Profile übersteht Backup/Restore byteidentisch.'
} finally {
  if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
