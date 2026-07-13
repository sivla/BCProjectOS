[CmdletBinding()]
param()
$ErrorActionPreference='Stop';Set-StrictMode -Version 2.0
. (Join-Path $PSScriptRoot 'Release.Common.ps1')
$sandbox=Join-Path ([System.IO.Path]::GetTempPath()) ('spectra-digest-' + [Guid]::NewGuid().ToString('N'))
try {
    [void](New-Item -ItemType Directory -Path $sandbox)
    $file=Join-Path $sandbox 'payload.bin'
    [System.IO.File]::WriteAllBytes($file,[byte[]](0x53,0x70,0x65,0x63,0x74,0x72,0x61,0x0A,0xFF))
    & git -C $sandbox init -b main | Out-Null; & git -C $sandbox config user.email 'spectra-digest@example.invalid'; & git -C $sandbox config user.name 'Spectra Digest'; & git -C $sandbox add payload.bin; & git -C $sandbox commit -m 'digest source' | Out-Null
    $first=(& git -C $sandbox rev-parse HEAD).Trim();$record=Get-BCProjectOSGitBlobRecord -Root $sandbox -Revision $first -RelativePath 'payload.bin' -IncludeMode;$expected=([System.BitConverter]::ToString(([System.Security.Cryptography.SHA256]::Create().ComputeHash([byte[]](0x53,0x70,0x65,0x63,0x74,0x72,0x61,0x0A,0xFF))))).Replace('-','').ToLowerInvariant();if([string]$record.sha256 -ne $expected -or [int64]$record.size_bytes -ne 9 -or [string]$record.mode -ne '100644'){throw 'DIGEST_POSITIVE_FAILED'};Write-Host 'PASS: Git-blob digest, size and mode match exact source.'
    $firstText=Get-BCProjectOSChecksumsText -Records @($record) -IncludeMode;$firstDigest=Get-BCProjectOSTextSha256 -Text $firstText;& git -C $sandbox update-index --chmod=+x payload.bin;& git -C $sandbox commit -m 'mode mutation' | Out-Null;$modeCommit=(& git -C $sandbox rev-parse HEAD).Trim();$modeChanged=Get-BCProjectOSGitBlobRecord -Root $sandbox -Revision $modeCommit -RelativePath 'payload.bin' -IncludeMode;$modeText=Get-BCProjectOSChecksumsText -Records @($modeChanged) -IncludeMode;if([string]$modeChanged.sha256-ne[string]$record.sha256-or[string]$modeChanged.mode-ne'100755'-or(Get-BCProjectOSTextSha256 -Text $modeText)-eq$firstDigest){throw 'MODE_DIGEST_NEGATIVE_FAILED'};Write-Host 'PASS: Mode-only Git mutation changes the mode-bound bundle digest.'
    [System.IO.File]::WriteAllBytes($file,[byte[]](0x53,0x70,0x65,0x63,0x74,0x72,0x61,0x0A,0xFE));& git -C $sandbox add payload.bin;& git -C $sandbox commit -m 'single byte mutation' | Out-Null;$second=(& git -C $sandbox rev-parse HEAD).Trim();$changed=Get-BCProjectOSGitBlobRecord -Root $sandbox -Revision $second -RelativePath 'payload.bin' -IncludeMode;if([string]$changed.sha256 -eq [string]$record.sha256){throw 'DIGEST_NEGATIVE_FAILED'};Write-Host 'PASS: Single-byte Git-blob mutation changes digest.'
}
finally { if(Test-Path -LiteralPath $sandbox -PathType Container){Remove-Item -LiteralPath $sandbox -Recurse -Force} }
