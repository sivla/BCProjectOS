function Test-SpectraInboxCompatibility {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]$Foundation,
    [Parameter(Mandatory)]$LegacyInbox,
    [Parameter(Mandatory)]$InformationInbox
  )

  if ($LegacyInbox.writes_performed -ne $false -or $LegacyInbox.target_mutation -ne $false) {
    throw 'INBOX_LEGACY_IMPLEMENTATION_FORBIDDEN'
  }
  $authorityProperty = @($LegacyInbox.PSObject.Properties | Where-Object { $_.Name -ceq 'lifecycle_authority' })
  if ($authorityProperty.Count -ne 1 -or [string]$authorityProperty[0].Value -cne 'foundation-read-only') {
    throw 'INBOX_LEGACY_AUTHORITY_FORBIDDEN'
  }
  if ([string]$InformationInbox.customer_id -cne [string]$Foundation.customer.id) {
    throw 'INBOX_LEADING_TRUTH_CONFLICT'
  }

  $projectIds = @($Foundation.projects | ForEach-Object { [string]$_.id })
  $supportIds = @($Foundation.support_cases | ForEach-Object { [string]$_.id })
  if ($null -ne $InformationInbox.project_id -and $projectIds -notcontains [string]$InformationInbox.project_id) {
    throw 'INBOX_LEADING_TRUTH_CONFLICT'
  }
  if ($null -ne $InformationInbox.support_case_id -and $supportIds -notcontains [string]$InformationInbox.support_case_id) {
    throw 'INBOX_LEADING_TRUTH_CONFLICT'
  }

  $legacySources = @{}
  foreach ($item in @($LegacyInbox.intake_items)) {
    $key = "$([string]$item.source_object_id)|$([string]$item.source_revision)|$([string]$item.sha256)"
    if ($legacySources.ContainsKey($key)) { throw 'INBOX_LEADING_SOURCE_DUPLICATE' }
    $legacySources[$key] = $true
  }
  foreach ($item in @($InformationInbox.intake_items)) {
    $source = $item.source
    $key = "$([string]$source.source_object_id)|$([string]$source.revision)|$([string]$source.sha256)"
    if (-not $legacySources.ContainsKey($key)) { throw 'INBOX_LEADING_TRUTH_CONFLICT' }
  }

  [pscustomobject]@{
    authority = 'information-inbox'
    legacy_mode = [string]$authorityProperty[0].Value
    implementation_allowed_from_legacy = $false
  }
}
