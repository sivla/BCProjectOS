[CmdletBinding()]
param(
    [string]$ChangeId = 'control-partial-delivery-shipping-costs'
)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$generator = Join-Path $PSScriptRoot 'Generate-Deliverables.ps1'
$gate = Join-Path $PSScriptRoot 'Test-DeliveryGate.ps1'
. (Join-Path $PSScriptRoot 'Delivery.Common.ps1')
$openSpecCommand = Get-LocalOpenSpecCommand

Push-Location $root
try {
    & $openSpecCommand schema validate bc-delivery
    if ($LASTEXITCODE -ne 0) { throw 'OpenSpec schema validation failed.' }

    & $openSpecCommand validate $ChangeId
    if ($LASTEXITCODE -ne 0) { throw 'OpenSpec change validation failed.' }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $generator -ChangeId $ChangeId -Force
    if ($LASTEXITCODE -ne 0) { throw 'Local deliverable generation failed.' }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $gate -ChangeId $ChangeId -Gate Planning
    if ($LASTEXITCODE -ne 0) { throw 'Planning gate should pass for the example change.' }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $gate -ChangeId $ChangeId -Gate BuildReady
    if ($LASTEXITCODE -ne 1) { throw 'BuildReady gate should fail closed for the intentionally incomplete example.' }

    & powershell -NoProfile -ExecutionPolicy Bypass -File $gate -ChangeId $ChangeId -Gate ReleaseReady
    if ($LASTEXITCODE -ne 1) { throw 'ReleaseReady gate should fail closed for the intentionally incomplete example.' }

    Write-Host "PASS: Blueprint structure, generation, and fail-closed gates behave as expected."
}
finally {
    Pop-Location
}
