#!/usr/bin/env bash

# Codex normal.
# Usa ~/.codex/config.toml y ~/.codex/AGENTS.md.
# Conserva el directorio desde el que se ejecuta.

set -euo pipefail

echo "Lanzando Codex..."
exec codex "$@"
