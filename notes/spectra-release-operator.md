# Spectra Release-Promotion (synthetischer Trockenlauf)

`automation/Promote-ReleaseCandidate.ps1` darf ausschließlich mit `-SyntheticRepository` in einem isolierten Temp-Git-Repository ausgeführt werden. Der Befehl akzeptiert nur einen committeden Candidate, prüft den Git-Blob-Payload-Digest, erzeugt atomar ein finales Manifest, commitet es einmal und setzt den annotierten `spectra-v<SemVer>`-Tag im Test-Repository.

Der produktive Arbeitsbaum bleibt ohne finalen externen Release-Tag bei `PENDING_BCPROJECTOS_RELEASE`. Ein Candidate, ein vorhandener Tag, ein vorhandenes finales Versionsverzeichnis, ein leichter Tag, eine Payload-Änderung oder widersprüchliche Commit-/Digest-Evidence muss fail-closed abgebrochen werden.
