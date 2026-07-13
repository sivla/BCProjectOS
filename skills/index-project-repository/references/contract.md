# Vertrag

- Freiheit: mittel, aber vollständig read-only.
- Zulässige Writes: nur neues lokales Inventar im autorisierten Workspace.
- Verboten: Checkout, Branch, Commit, Push, Merge, Reset, Deployment oder Hookausführung.
- Evidence: Repo-URL, beobachteter Ref, Commit, Tree und Blobpfade.
- Stop-Codes: `REPOSITORY_IDENTITY_UNKNOWN`, `REPOSITORY_COMMIT_UNPINNED`, `REPOSITORY_TREE_MISMATCH`, `REPOSITORY_WRITE_ATTEMPT`.
- Reset/Rollback: nicht erforderlich; Quellrepository bleibt bytegenau unverändert.
