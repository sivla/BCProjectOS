function Get-SpectraPowerShellHostPath {
  $hostPath=(Get-Process -Id $PID).Path
  if ([string]::IsNullOrWhiteSpace($hostPath) -or -not (Test-Path -LiteralPath $hostPath -PathType Leaf)) {
    throw 'SPECTRA_POWERSHELL_HOST_UNAVAILABLE'
  }
  return [IO.Path]::GetFullPath($hostPath)
}
