Set-StrictMode -Version 2.0

function Get-BCProjectOSRoot {
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
}

function Get-BCProjectOSReleaseScope {
    param([Parameter(Mandatory = $true)][string]$Root)

    $scopePath = Join-Path $Root 'release\release-scope.json'
    if (-not (Test-Path -LiteralPath $scopePath -PathType Leaf)) {
        throw "Release scope is missing: $scopePath"
    }

    $scope = Get-Content -LiteralPath $scopePath -Raw | ConvertFrom-Json
    if ([int]$scope.schema_version -ne 1 -or [string]$scope.product_id -ne 'spectra') {
        throw 'Release scope has an unsupported schema or product identity.'
    }
    return $scope
}

function Resolve-BCProjectOSPayloadPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath) -or $RelativePath -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "Release scope contains an unsafe path: $RelativePath"
    }

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
    $rootPrefix = $Root.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Release scope escapes the product root: $RelativePath"
    }
    return $fullPath
}

function Get-BCProjectOSPayloadFiles {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)]$Scope
    )

    $paths = @{}
    foreach ($relativePath in @($Scope.payload_files)) {
        $fullPath = Resolve-BCProjectOSPayloadPath -Root $Root -RelativePath ([string]$relativePath)
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            throw "Release payload file is missing: $relativePath"
        }
        $normalized = [string]$relativePath -replace '\\', '/'
        $paths[$normalized] = $fullPath
    }

    foreach ($relativeRoot in @($Scope.payload_roots)) {
        $fullRoot = Resolve-BCProjectOSPayloadPath -Root $Root -RelativePath ([string]$relativeRoot)
        if (-not (Test-Path -LiteralPath $fullRoot -PathType Container)) {
            throw "Release payload root is missing: $relativeRoot"
        }
        foreach ($file in Get-ChildItem -LiteralPath $fullRoot -Recurse -File) {
            $relative = $file.FullName.Substring($Root.TrimEnd('\', '/').Length + 1) -replace '\\', '/'
            $paths[$relative] = $file.FullName
        }
    }

    $sortedPaths = [string[]]@($paths.Keys)
    [System.Array]::Sort($sortedPaths, [System.StringComparer]::Ordinal)
    foreach ($relativePath in $sortedPaths) {
        [pscustomobject]@{
            path = $relativePath
            full_path = $paths[$relativePath]
        }
    }
}

function Get-BCProjectOSPayloadRecords {
    param([Parameter(Mandatory = $true)]$Files)

    foreach ($file in @($Files)) {
        $item = Get-Item -LiteralPath $file.full_path
        [pscustomobject]@{
            path = [string]$file.path
            sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
            size_bytes = [int64]$item.Length
        }
    }
}

function Get-BCProjectOSChecksumsText {
    param([Parameter(Mandatory = $true)]$Records)

    $lines = @($Records | ForEach-Object { "$($_.sha256)  $($_.path)" })
    return ($lines -join "`n") + "`n"
}

function Get-BCProjectOSTextSha256 {
    param([Parameter(Mandatory = $true)][string]$Text)

    $encoding = New-Object System.Text.UTF8Encoding($false)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $encoding.GetBytes($Text)
        return ([System.BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
    }
}

function Write-BCProjectOSUtf8File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $directory -Force)
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, ($Content -replace "`r`n", "`n"), $encoding)
}
