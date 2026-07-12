## Why

Spectra 1.0 needs deterministic backup, safe restore and recovery evidence without exporting secrets or local runtime state.

## What Changes

Add the next release delta after `0.4.0-alpha.1`: local-only backup/restore commands with integrity manifest, safe paths, dry-run, atomic restore and roundtrip fixtures. The evidence supports `0.5.0-alpha.1` as a backward-compatible capability release; 1.0 remains unjustified because Project-Story hardening, full CLI and pilot/RC evidence are still open.
