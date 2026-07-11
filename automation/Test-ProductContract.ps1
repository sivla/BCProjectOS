[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$findings = New-Object System.Collections.ArrayList

function Get-RepositoryAuthoredFiles {
    return @(Get-ChildItem -LiteralPath $root -Recurse -File -Force | Where-Object {
        $_.FullName -notmatch '[\\/](?:\.git|node_modules)[\\/]'
    })
}

function Get-ProductContractFiles {
    $allowedRoots = @('automation','catalogs','contract','examples\minimal-contract','pilots','release','schemas','tests')
    $files = New-Object System.Collections.ArrayList
    foreach ($relative in $allowedRoots) {
        $path = Join-Path $root $relative
        if (Test-Path -LiteralPath $path -PathType Container) {
            foreach ($file in Get-ChildItem -LiteralPath $path -Recurse -File -Force) {
                [void]$files.Add($file)
            }
        }
    }
    foreach ($relative in @('AGENTS.md','README.md','.gitattributes','.gitignore')) {
        $path = Join-Path $root $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            [void]$files.Add((Get-Item -LiteralPath $path -Force))
        }
    }
    return @($files)
}

function Add-Finding {
    param([string]$Code, [string]$Message)
    [void]$script:findings.Add([pscustomobject]@{ code = $Code; message = $Message })
}

function Read-StructuredFile {
    param([string]$Path)
    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        Add-Finding -Code 'STRUCTURED_SYNTAX_INVALID' -Message "$Path cannot be parsed as JSON-compatible YAML 1.2: $($_.Exception.Message)"
        return $null
    }
}

function Get-PropertyValue {
    param($Object, [string]$Name)
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $null
}

function Test-ContractFixture {
    param($Fixture)

    $result = New-Object System.Collections.ArrayList
    function Add-LocalFinding([string]$Code, [string]$Message) {
        [void]$result.Add([pscustomobject]@{ code = $Code; message = $Message })
    }

    if ($null -eq $Fixture -or $null -eq $Fixture.workspace) {
        Add-LocalFinding 'WORKSPACE_MISSING' 'Fixture has no workspace.'
        return @($result)
    }

    $workspace = $Fixture.workspace
    $customerId = [string]$workspace.id
    $all = @($workspace) + @($Fixture.entities)
    $idPattern = '^(CUS|PRJ|SUP|MTG|FILE|KNO|PROC|BR|TKT|REQ|CHG|EVD)-[0-9A-HJKMNP-TV-Z]{26}$'
    $prefixByType = @{
        customer='CUS'; project='PRJ'; support_case='SUP'; meeting='MTG'; external_file='FILE';
        knowledge_item='KNO'; business_process='PROC'; business_rule='BR'; ticket='TKT';
        requirement='REQ'; openspec_change='CHG'; evidence='EVD'
    }
    $ids = @{}
    $types = @{}

    foreach ($entity in $all) {
        foreach ($required in @('schema_version','id','customer_id','entity_type','title','lifecycle_status','created_at','relations')) {
            if ($entity.PSObject.Properties.Name -notcontains $required -or [string]::IsNullOrWhiteSpace([string]$entity.$required)) {
                if ($required -ne 'relations') { Add-LocalFinding 'ENTITY_FIELD_MISSING' "Entity is missing '$required'." }
            }
        }
        $id = [string]$entity.id
        $type = [string]$entity.entity_type
        if ($id -notmatch $idPattern -or -not $prefixByType.ContainsKey($type) -or -not $id.StartsWith($prefixByType[$type] + '-')) {
            Add-LocalFinding 'ID_INVALID' "Invalid ID/type combination '$id' / '$type'."
        }
        if ($ids.ContainsKey($id)) { Add-LocalFinding 'ID_DUPLICATE' "Duplicate ID '$id'." }
        else { $ids[$id] = $true; $types[$id] = $type }
        if ([string]$entity.customer_id -ne $customerId) {
            Add-LocalFinding 'CUSTOMER_BOUNDARY_VIOLATION' "Entity '$id' does not belong to workspace '$customerId'."
        }
    }

    if ([string]$workspace.customer_id -ne $customerId -or @($workspace.relations).Count -ne 0) {
        Add-LocalFinding 'WORKSPACE_IDENTITY_INVALID' 'Customer must self-namespace and have no belongs_to relation.'
    }
    if (@($workspace.openspec_roots).Count -ne 1 -or [string]$workspace.openspec_roots[0] -ne 'openspec') {
        Add-LocalFinding 'OPENSPEC_ROOT_COUNT_INVALID' 'Exactly one OpenSpec root named openspec is required.'
    }
    if ([string]$workspace.blueprint_id -ne 'bcprojectos' -or [string]$workspace.blueprint_version -notmatch '^\d+\.\d+\.\d+$') {
        Add-LocalFinding 'BLUEPRINT_VERSION_INVALID' 'Blueprint identity or semantic version is invalid.'
    }

    $relationCatalog = Read-StructuredFile -Path (Join-Path $root 'catalogs\relation-types.yaml')
    $relationsByName = @{}
    foreach ($definition in @($relationCatalog.relations)) { $relationsByName[[string]$definition.type] = $definition }
    foreach ($entity in @($Fixture.entities)) {
        $hasBelongsTo = $false
        foreach ($relation in @($entity.relations)) {
            $relationType = [string]$relation.type
            $targetId = [string]$relation.target_id
            if (-not $relationsByName.ContainsKey($relationType)) {
                Add-LocalFinding 'RELATION_TYPE_UNKNOWN' "Unknown relation '$relationType' on '$($entity.id)'."
                continue
            }
            if (-not $ids.ContainsKey($targetId)) {
                Add-LocalFinding 'RELATION_TARGET_UNKNOWN' "Unknown target '$targetId' on '$($entity.id)'."
                continue
            }
            $definition = $relationsByName[$relationType]
            if (@($definition.sources) -notcontains [string]$entity.entity_type -or @($definition.targets) -notcontains [string]$types[$targetId]) {
                Add-LocalFinding 'RELATION_ENDPOINT_INVALID' "Relation '$relationType' has invalid endpoint types."
            }
            if ((Get-PropertyValue -Object $definition -Name 'same_entity_type') -eq $true -and [string]$entity.entity_type -ne [string]$types[$targetId]) {
                Add-LocalFinding 'RELATION_ENDPOINT_INVALID' "Relation '$relationType' requires equal entity types."
            }
            if ($relationType -eq 'belongs_to' -and $targetId -eq $customerId) { $hasBelongsTo = $true }
        }
        if (-not $hasBelongsTo) { Add-LocalFinding 'CUSTOMER_RELATION_MISSING' "Entity '$($entity.id)' lacks belongs_to customer relation." }
    }

    $expectedTypes = @('project','support_case','meeting','external_file','knowledge_item','business_process','business_rule','ticket','requirement','openspec_change','evidence')
    foreach ($expectedType in $expectedTypes) {
        if (@($Fixture.entities | Where-Object { $_.entity_type -eq $expectedType }).Count -ne 1) {
            Add-LocalFinding 'ENTITY_COVERAGE_INVALID' "Synthetic fixture must contain exactly one '$expectedType'."
        }
    }

    $documentCatalog = Read-StructuredFile -Path (Join-Path $root 'catalogs\document-types.yaml')
    $tagCatalog = Read-StructuredFile -Path (Join-Path $root 'catalogs\tags.yaml')
    foreach ($entity in @($Fixture.entities)) {
        $documentType = Get-PropertyValue -Object $entity -Name 'document_type'
        if ($null -ne $documentType -and @($documentCatalog.values) -notcontains [string]$documentType) {
            Add-LocalFinding 'DOCUMENT_TYPE_UNKNOWN' "Unknown document type '$documentType'."
        }
        $tags = Get-PropertyValue -Object $entity -Name 'tags'
        if ($null -ne $tags) {
            foreach ($tagProperty in $tags.PSObject.Properties) {
                if ($tagCatalog.dimensions.PSObject.Properties.Name -notcontains $tagProperty.Name -or @($tagCatalog.dimensions.$($tagProperty.Name)) -notcontains [string]$tagProperty.Value) {
                    Add-LocalFinding 'TAG_INVALID' "Invalid tag '$($tagProperty.Name)=$($tagProperty.Value)'."
                }
            }
        }
    }

    foreach ($file in @($Fixture.entities | Where-Object { $_.entity_type -eq 'external_file' })) {
        $hash = Get-PropertyValue -Object $file -Name 'sha256'
        if ([string]::IsNullOrWhiteSpace([string]$hash)) {
            Add-LocalFinding 'ORIGINAL_HASH_MISSING' "External file '$($file.id)' has no SHA-256."
        }
        elseif ([string]$hash -notmatch '^[a-f0-9]{64}$' -or [string]$file.blob_path -ne "external-files/originals/sha256/$($hash.Substring(0,2))/$hash") {
            Add-LocalFinding 'ORIGINAL_INTEGRITY_INVALID' "External file '$($file.id)' has invalid hash/blob path."
        }
    }

    foreach ($entity in @($Fixture.entities)) {
        $approval = Get-PropertyValue -Object $entity -Name 'approval_status'
        if ([string]$approval -eq 'approved') {
            $refs = @(Get-PropertyValue -Object $entity -Name 'evidence_refs')
            if ($refs.Count -eq 0) { Add-LocalFinding 'APPROVAL_EVIDENCE_MISSING' "Approved entity '$($entity.id)' has no evidence reference." }
            foreach ($ref in $refs) {
                if (-not $types.ContainsKey([string]$ref) -or $types[[string]$ref] -ne 'evidence') {
                    Add-LocalFinding 'APPROVAL_EVIDENCE_INVALID' "Approval reference '$ref' is not canonical evidence."
                }
            }
        }
    }
    return @($result)
}

# Snapshot proves that this validator performs no writes.
$repositoryFiles = @(Get-RepositoryAuthoredFiles)
$before = @{}
foreach ($file in $repositoryFiles) {
    $before[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
}

$productFiles = @(Get-ProductContractFiles)
$structuredFiles = @($productFiles | Where-Object { $_.Extension -in @('.json','.yaml') })
foreach ($file in $structuredFiles) {
    $parsed = Read-StructuredFile -Path $file.FullName
    if ($null -eq $parsed) { continue }
    if ($file.Directory.Name -eq 'schemas') {
        if ($parsed.PSObject.Properties.Name -notcontains '$schema' -or [string]$parsed.'$schema' -ne 'https://json-schema.org/draft/2020-12/schema') {
            Add-Finding -Code 'SCHEMA_DIALECT_INVALID' -Message "$($file.FullName) does not declare JSON Schema 2020-12."
        }
    }
    elseif ($file.Directory.Name -eq 'catalogs') {
        if ([int]$parsed.schema_version -ne 1 -or [string]::IsNullOrWhiteSpace([string]$parsed.catalog)) {
            Add-Finding -Code 'CATALOG_HEADER_INVALID' -Message "$($file.FullName) has an invalid catalog header."
        }
    }
}

$fixturePath = Join-Path $root 'examples\minimal-contract\contract-fixture.json'
$fixture = Read-StructuredFile -Path $fixturePath
foreach ($finding in @(Test-ContractFixture -Fixture $fixture)) { [void]$findings.Add($finding) }

foreach ($testFile in Get-ChildItem -LiteralPath (Join-Path $root 'tests\invalid') -File -Filter '*.json' | Sort-Object Name) {
    $test = Read-StructuredFile -Path $testFile.FullName
    if ($null -eq $test) { continue }
    $copy = ($fixture | ConvertTo-Json -Depth 30 | ConvertFrom-Json)
    $mutation = $test.mutation
    $entity = $copy.entities[[int]$mutation.entity_index]
    if ($mutation.PSObject.Properties.Name -contains 'relation_index') { $entity = $entity.relations[[int]$mutation.relation_index] }
    if ($mutation.PSObject.Properties.Name -contains 'remove_property') {
        $entity.PSObject.Properties.Remove([string]$mutation.remove_property)
    }
    else {
        $property = [string]$mutation.property
        $entity.$property = $mutation.value
    }
    $negativeFindings = @(Test-ContractFixture -Fixture $copy)
    $codes = @($negativeFindings | ForEach-Object { $_.code })
    if ($codes -notcontains [string]$test.expected_code) {
        Add-Finding -Code 'NEGATIVE_FIXTURE_FAILED' -Message "$($test.case) expected '$($test.expected_code)' but got '$($codes -join ',')'."
    }
}

# Detect credential-shaped assignments, not governance prose that names secret classes.
$secretPattern = '(?im)(client_secret|access_token|refresh_token|connection_string|password)\s*[:=]\s*["'']?[A-Za-z0-9_+\-/=]{8,}'
$tenantPattern = '(?im)(tenant_id|tenantid)\s*[:=]\s*["'']?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
$scanFiles = $repositoryFiles
foreach ($file in $scanFiles) {
    if ($file.Extension -notin @('.md','.json','.yaml','.ps1')) { continue }
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -match $secretPattern -or $content -match $tenantPattern) {
        Add-Finding -Code 'SENSITIVE_VALUE_DETECTED' -Message "Credential- or tenant-shaped value found in $($file.FullName)."
    }
}

$afterFiles = @(Get-RepositoryAuthoredFiles)
if ($afterFiles.Count -ne $before.Count) {
    Add-Finding -Code 'VALIDATOR_WRITE_DETECTED' -Message 'File count changed during validation.'
}
foreach ($file in $afterFiles) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    if (-not $before.ContainsKey($file.FullName) -or $before[$file.FullName] -ne $hash) {
        Add-Finding -Code 'VALIDATOR_WRITE_DETECTED' -Message "File changed during validation: $($file.FullName)"
    }
}

if ($findings.Count -gt 0) {
    Write-Host 'BLOCKED: BCProjectOS MVP 0 product contract validation failed.'
    foreach ($finding in $findings) { Write-Host "- [$($finding.code)] $($finding.message)" }
    exit 1
}

Write-Host "PASS: $($structuredFiles.Count) structured files are syntactically valid."
Write-Host 'PASS: The synthetic canonical entity and relation model is valid.'
Write-Host 'PASS: All negative fixtures fail closed with the expected finding.'
Write-Host 'PASS: No credential- or tenant-shaped values were detected.'
Write-Host 'PASS: Validator completed without changing product-contract files.'
