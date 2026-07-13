Set-StrictMode -Version Latest

function Test-SpectraV1IntegrationReleaseDelta {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [AllowEmptyCollection()]
    [string[]]$Paths,

    [Parameter()]
    [AllowNull()]
    [object]$CandidateManifest,

    [Parameter()]
    [AllowNull()]
    [string]$ExpectedCandidateSourceCommit,

    [Parameter()]
    [AllowNull()]
    [string]$ExpectedCandidateSourceTree,

    [Parameter()]
    [bool]$TagExists = $false
  )

  $scopePath = 'release/release-scope.json'
  $candidatePaths = @(
    'release/versions/1.0.0/checksums.sha256'
    'release/versions/1.0.0/release-manifest.json'
    'release/versions/1.0.0/release-notes.md'
  )
  $allowedPaths = @($scopePath) + @($candidatePaths)
  $normalizedPaths = @($Paths | ForEach-Object { ([string]$_).Replace('\', '/') } | Sort-Object -Unique)

  foreach ($path in $normalizedPaths) {
    if ($path -cnotin $allowedPaths) {
      throw 'V1_INTEGRATION_RELEASE_DELTA_FORBIDDEN'
    }
  }

  $presentCandidatePaths = @($normalizedPaths | Where-Object { $_ -cin $candidatePaths })
  if ($presentCandidatePaths.Count -eq 0) {
    if ($null -ne $CandidateManifest) {
      throw 'V1_INTEGRATION_CANDIDATE_EVIDENCE_UNTRACKED'
    }
    if ($TagExists) {
      throw 'V1_INTEGRATION_RELEASE_TAG_FORBIDDEN'
    }
    return [pscustomobject]@{
      status = 'release-contract-only'
      candidate_evidence = $false
    }
  }

  if ($presentCandidatePaths.Count -ne $candidatePaths.Count -or
      (Compare-Object -ReferenceObject $candidatePaths -DifferenceObject $presentCandidatePaths)) {
    throw 'V1_INTEGRATION_CANDIDATE_EVIDENCE_INCOMPLETE'
  }
  if ($null -eq $CandidateManifest) {
    throw 'V1_INTEGRATION_CANDIDATE_MANIFEST_INVALID'
  }
  if ($TagExists) {
    throw 'V1_INTEGRATION_RELEASE_TAG_FORBIDDEN'
  }

  $requiredProperties = @(
    'schema_version',
    'product_id',
    'release_version',
    'expected_tag',
    'manifest_state',
    'installable_blueprint',
    'consumer_mode',
    'source_commit',
    'source_tree',
    'candidate_source_commit',
    'candidate_source_tree'
  )
  foreach ($propertyName in $requiredProperties) {
    if ($null -eq $CandidateManifest.PSObject.Properties[$propertyName]) {
      throw 'V1_INTEGRATION_CANDIDATE_MANIFEST_INVALID'
    }
  }

  if ([int]$CandidateManifest.schema_version -ne 4 -or
      [string]$CandidateManifest.product_id -cne 'spectra' -or
      [string]$CandidateManifest.release_version -cne '1.0.0' -or
      [string]$CandidateManifest.expected_tag -cne 'spectra-v1.0.0' -or
      [string]$CandidateManifest.manifest_state -cne 'candidate' -or
      [bool]$CandidateManifest.installable_blueprint -ne $false -or
      [string]$CandidateManifest.consumer_mode -cne 'CONTRACT_REFERENCE_ONLY' -or
      $null -ne $CandidateManifest.source_commit -or
      $null -ne $CandidateManifest.source_tree) {
    throw 'V1_INTEGRATION_CANDIDATE_MANIFEST_INVALID'
  }

  if ([string]::IsNullOrWhiteSpace($ExpectedCandidateSourceCommit) -or
      [string]::IsNullOrWhiteSpace($ExpectedCandidateSourceTree) -or
      [string]$CandidateManifest.candidate_source_commit -cne $ExpectedCandidateSourceCommit -or
      [string]$CandidateManifest.candidate_source_tree -cne $ExpectedCandidateSourceTree) {
    throw 'V1_INTEGRATION_CANDIDATE_SOURCE_INVALID'
  }

  [pscustomobject]@{
    status = 'candidate-evidence'
    candidate_evidence = $true
    candidate_source_commit = $ExpectedCandidateSourceCommit
    candidate_source_tree = $ExpectedCandidateSourceTree
  }
}
