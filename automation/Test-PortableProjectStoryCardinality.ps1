[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$utf8 = [Text.UTF8Encoding]::new($false)

function Invoke-PortableExact([string]$Path) {
  $start = [Diagnostics.ProcessStartInfo]::new()
  $start.FileName = 'powershell.exe'
  $start.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$root\automation\Run-PortableConformanceExact.ps1`" -Path `"$Path`""
  $start.UseShellExecute = $false
  $start.RedirectStandardOutput = $true
  $start.RedirectStandardError = $true
  $process = [Diagnostics.Process]::Start($start)
  $stdout = $process.StandardOutput.ReadToEnd().Trim()
  $stderr = $process.StandardError.ReadToEnd().Trim()
  $process.WaitForExit()
  [pscustomobject]@{ Exit = $process.ExitCode; Output = $stdout; Error = $stderr }
}

function Write-Story([string]$Directory, $Story) {
  [IO.File]::WriteAllText((Join-Path $Directory 'project-story.json'), (($Story | ConvertTo-Json -Depth 40) + "`n"), $utf8)
}

function Set-ActualTotals($Story) {
  $hours = 0
  $cost = 0
  foreach ($ticket in @($Story.tickets)) {
    foreach ($worklog in @($ticket.worklogs)) {
      $hours += [decimal]$worklog.hours
      $cost += [decimal]$worklog.cost
    }
  }
  $Story.offer.actual_hours = $hours
  $Story.offer.actual_cost = $cost
}

function New-Story([string]$Name, [scriptblock]$Mutation) {
  $directory = Join-Path ([IO.Path]::GetTempPath()) ("portable-cardinality-$Name-" + [guid]::NewGuid().ToString('N'))
  try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'automation\New-PortableProjectStoryFixture.ps1') -Destination $directory | Out-Null
    $story = Get-Content (Join-Path $directory 'project-story.json') -Raw | ConvertFrom-Json
    & $Mutation $story
    Set-ActualTotals $story
    Write-Story $directory $story
    return $directory
  } catch {
    if (Test-Path -LiteralPath $directory) { Remove-Item -LiteralPath $directory -Recurse -Force -ErrorAction SilentlyContinue }
    throw
  }
}

function Assert-Pass([string]$Name, [string]$Directory) {
  $result = Invoke-PortableExact $Directory
  if ($result.Exit -ne 0 -or $result.Error -ne '' -or $result.Output -cne 'PASS') {
    throw "PORTABLE_CARDINALITY_POSITIVE_FAILED:${Name}:$($result.Exit):$($result.Output):$($result.Error)"
  }
  Write-Host "PASS: variable cardinality $Name"
}

function Assert-Fail([string]$Name, [string]$Directory, [string]$Code) {
  $result = Invoke-PortableExact $Directory
  if ($result.Exit -ne 1 -or $result.Error -ne '' -or $result.Output -cne $Code) {
    throw "PORTABLE_CARDINALITY_NEGATIVE_FAILED:${Name}:${Code}:$($result.Exit):$($result.Output):$($result.Error)"
  }
  Write-Host "PASS: hierarchy negative $Name ($Code)"
}

$directories = @()
try {
  $small = New-Story 'small' {
    param($story)
    $story.tickets = @($story.tickets | Select-Object -First 2)
  }
  $directories += $small
  Assert-Pass 'two tickets' $small

  $large = New-Story 'large' {
    param($story)
    $base = $story.tickets[0]
    $tickets = @($story.tickets)
    for ($i = 18; $i -le 23; $i++) {
      $copy = ($base | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
      $id = "TKT-PORT-$('{0:D2}' -f $i)"
      $copy.id = $id
      $copy.summary = $id
      $copy.comments[0].id = "COM-$id-1"
      $copy.comments[1].id = "COM-$id-2"
      $copy.worklogs[0].id = "WL-$id"
      $tickets += $copy
    }
    $story.tickets = $tickets
  }
  $directories += $large
  Assert-Pass '23 tickets' $large

  $duplicate = New-Story 'duplicate' {
    param($story)
    $story.tickets = @($story.tickets | Select-Object -First 2)
    $story.tickets[1].id = $story.tickets[0].id
  }
  $directories += $duplicate
  Assert-Fail 'duplicate ticket id' $duplicate 'PORTABLE_DUPLICATE_ID'

  $orphan = New-Story 'orphan' {
    param($story)
    $story.pages[1].parent = 'PAGE-UNKNOWN'
  }
  $directories += $orphan
  Assert-Fail 'page orphan' $orphan 'PORTABLE_PAGE_PARENT'

  $cycle = New-Story 'cycle' {
    param($story)
    $story.pages[0].parent = 'PAGE-PORT-02'
    $story.pages[1].parent = 'PAGE-PORT-01'
  }
  $directories += $cycle
  Assert-Fail 'page cycle' $cycle 'PORTABLE_PAGE_CYCLE'

  Write-Host 'PASS: variable Project-Story-Kardinalität und Hierarchie-Negativmatrix.'
} finally {
  foreach ($directory in $directories) {
    if (Test-Path -LiteralPath $directory) { Remove-Item -LiteralPath $directory -Recurse -Force -ErrorAction SilentlyContinue }
  }
}
