# Spectra Release-Promotion (synthetischer Trockenlauf)

`automation/New-ReleaseCandidate.ps1` verlangt einen expliziten, bereits existierenden `-CandidateSourceCommit` (`-SourceCommit` bleibt als Aufrufalias kompatibel). Der Commit muss `HEAD` sein und darf die eigene Candidate-Evidence noch nicht enthalten. Der Schema-v4-Candidate bindet ihn als `candidate_source_commit/tree`; `source_commit/tree` bleiben null. Pfad, SHA-256, Groesse und sicherer Git-Dateimodus jedes Payloadblobs fliessen in die Bindung ein. Er bleibt `CONTRACT_REFERENCE_ONLY` und ist mit `installable_blueprint: false` nicht installierbar.

`automation/Promote-ReleaseCandidate.ps1` darf ohne ausdrückliche Real-Repository-Freigabe ausschließlich mit `-SyntheticRepository` in einem isolierten Temp-Git-Repository ausgeführt werden. Der Befehl akzeptiert nur einen committeden, source-/tree-/mode-gebundenen Schema-v4-Candidate, prüft den Git-Payload-Digest, erzeugt atomar ein finales installierbares Manifest, commitet es einmal und setzt den annotierten `spectra-v<SemVer>`-Tag im Test-Repository.

Der produktive Arbeitsbaum bleibt ohne finalen externen Release-Tag bei `PENDING_BCPROJECTOS_RELEASE`. Ein Candidate, ein vorhandener Tag, ein vorhandenes finales Versionsverzeichnis, ein leichter Tag, eine Payload-Änderung oder widersprüchliche Commit-/Digest-Evidence muss fail-closed abgebrochen werden.
