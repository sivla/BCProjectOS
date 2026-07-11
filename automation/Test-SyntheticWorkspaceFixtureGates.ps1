[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sandbox = Join-Path ([System.IO.Path]::GetTempPath()) ('bcprojectos-synthetic-gates-' + [Guid]::NewGuid().ToString('N'))
$destination = Join-Path $sandbox 'fixture'

function Invoke-GateScript([string]$ScriptPath, [string[]]$Arguments) {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $allArguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$ScriptPath) + $Arguments
    $startInfo.Arguments = (($allArguments | ForEach-Object { '"' + $_.Replace('"', '\"') + '"' }) -join ' ')
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    [void]$process.StandardOutput.ReadToEnd()
    [void]$process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    $process.Dispose()
    return $exitCode
}

try {
    [void](New-Item -ItemType Directory -Path $sandbox)
    if ((Invoke-GateScript -ScriptPath (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Arguments @('-Destination',$destination,'-Profile','implementation','-SyntheticFixture')) -ne 0) { throw 'SYNTHETIC_GENERATION_FAILED' }
    if ((Invoke-GateScript -ScriptPath (Join-Path $PSScriptRoot 'Test-SyntheticWorkspaceFixture.ps1') -Arguments @('-Path',$destination)) -ne 0) { throw 'SYNTHETIC_POSITIVE_VALIDATION_FAILED' }

    if ((Invoke-GateScript -ScriptPath (Join-Path $PSScriptRoot 'New-CustomerWorkspace.ps1') -Arguments @('-Destination',$destination,'-Profile','implementation','-SyntheticFixture')) -eq 0) { throw 'DESTINATION_OVERWRITE_ACCEPTED' }
    Write-Host 'PASS: Existing synthetic destination is not overwritten.'

    [System.IO.File]::WriteAllText((Join-Path $destination 'workspace.yaml'), "synthetic: false`n")
    if ((Invoke-GateScript -ScriptPath (Join-Path $PSScriptRoot 'Test-SyntheticWorkspaceFixture.ps1') -Arguments @('-Path',$destination)) -eq 0) { throw 'SYNTHETIC_PUBLICATION_SHAPE_ACCEPTED' }
    Write-Host 'PASS: Synthetic fixture containing workspace.yaml fails closed.'
}
finally {
    if (Test-Path -LiteralPath $sandbox -PathType Container) { Remove-Item -LiteralPath $sandbox -Recurse -Force }
}
