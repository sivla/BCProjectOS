#!/usr/bin/env sh
set -eu
if ! command -v pwsh >/dev/null 2>&1; then
  echo "PowerShell 7 fehlt. Installation auf macOS: brew install --cask powershell" >&2
  exit 1
fi
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec pwsh -NoProfile -File "$SCRIPT_DIR/install.ps1" "$@"
