Set-StrictMode -Version 2.0

function Get-BCProjectOSRoot {
    return [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
}

function Get-BCProjectOSReleaseScope {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [string]$Revision
    )

    $scopePath = Join-Path $Root 'release\release-scope.json'
    if ([string]::IsNullOrWhiteSpace($Revision)) {
        if (-not (Test-Path -LiteralPath $scopePath -PathType Leaf)) {
            throw "Release scope is missing: $scopePath"
        }
        $scopeText = [System.IO.File]::ReadAllText($scopePath)
    }
    else {
        $scopeOutput = @(& git -C $Root show "$Revision`:release/release-scope.json" 2>$null)
        if ($LASTEXITCODE -ne 0 -or $scopeOutput.Count -eq 0) {
            throw "Release scope is missing from revision: $Revision"
        }
        $scopeText = ($scopeOutput -join "`n")
    }

    $scope = $scopeText | ConvertFrom-Json
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

function Get-BCProjectOSGitBlobRecord {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Revision,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [switch]$IncludeMode
    )
    $mode = $null
    if ($IncludeMode) {
        $modeOutput = @(& git -C $Root ls-tree '--format=%(objectmode)' $Revision -- $RelativePath 2>$null)
        if ($LASTEXITCODE -ne 0 -or $modeOutput.Count -ne 1) {
            throw "Git mode is unavailable for payload path: $RelativePath"
        }
        $mode = ([string]$modeOutput[0]).Trim()
        if ($mode -notmatch '^100(644|755)$') {
            throw "Unsupported Git payload mode '$mode': $RelativePath"
        }
    }
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.Arguments = "-C `"$Root`" cat-file blob `"$Revision`:$RelativePath`""
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $bytes = New-Object System.IO.MemoryStream
    try {
        $process.StandardOutput.BaseStream.CopyTo($bytes)
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "git cat-file failed: $stderr" }
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $record = [ordered]@{
                path = $RelativePath
                sha256 = ([System.BitConverter]::ToString($sha256.ComputeHash($bytes.ToArray()))).Replace('-', '').ToLowerInvariant()
                size_bytes = [int64]$bytes.Length
            }
            if ($IncludeMode) { $record.mode = $mode }
            return [pscustomobject]$record
        }
        finally { $sha256.Dispose() }
    }
    finally { $bytes.Dispose(); $process.Dispose() }
}

function Get-BCProjectOSGitPayloadRecords {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Revision,
        [Parameter(Mandatory = $true)]$Scope,
        [switch]$IncludeMode
    )
    $paths = @{}
    foreach ($relativePath in @($Scope.payload_files)) {
        $normalized = [string]$relativePath -replace '\\', '/'
        if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)') {
            throw "Release scope contains an unsafe path: $relativePath"
        }
        & git -C $Root cat-file -e "$Revision`:$normalized" 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Release payload file is missing from revision: $normalized" }
        $paths[$normalized] = $true
    }
    foreach ($relativeRoot in @($Scope.payload_roots)) {
        $normalizedRoot = ([string]$relativeRoot -replace '\\', '/').TrimEnd('/')
        if ([System.IO.Path]::IsPathRooted($normalizedRoot) -or $normalizedRoot -match '(^|/)\.\.(/|$)') {
            throw "Release scope contains an unsafe root: $relativeRoot"
        }
        $treePaths = @(& git -C $Root ls-tree -r --name-only $Revision -- $normalizedRoot 2>$null)
        if ($LASTEXITCODE -ne 0 -or $treePaths.Count -eq 0) {
            throw "Release payload root is missing from revision: $normalizedRoot"
        }
        foreach ($treePath in $treePaths) {
            $normalized = ([string]$treePath).Trim() -replace '\\', '/'
            if ($normalized -ne $normalizedRoot -and -not $normalized.StartsWith("$normalizedRoot/", [System.StringComparison]::Ordinal)) {
                throw "Release payload root escaped during Git enumeration: $normalized"
            }
            $paths[$normalized] = $true
        }
    }
    $sortedPaths = [string[]]@($paths.Keys)
    [System.Array]::Sort($sortedPaths, [System.StringComparer]::Ordinal)
    foreach ($relativePath in $sortedPaths) {
        Get-BCProjectOSGitBlobRecord -Root $Root -Revision $Revision -RelativePath $relativePath -IncludeMode:$IncludeMode
    }
}

function Get-BCProjectOSChecksumsText {
    param(
        [Parameter(Mandatory = $true)]$Records,
        [switch]$IncludeMode
    )

    $lines = @($Records | ForEach-Object {
        if ($IncludeMode) {
            if ($_.PSObject.Properties.Name -notcontains 'mode' -or [string]$_.mode -notmatch '^100(644|755)$') {
                throw "Payload record has no valid Git mode: $($_.path)"
            }
            "$($_.sha256)  $($_.mode)  $($_.path)"
        }
        else {
            "$($_.sha256)  $($_.path)"
        }
    })
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
