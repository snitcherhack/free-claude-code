#!/usr/bin/env bash

# Codex sin sandbox ni aprobaciones.
# Usar solo cuando se haya decidido explicitamente conceder acceso completo.

set -euo pipefail

echo "WARNING: Codex arrancara SIN sandbox ni aprobaciones."
exec codex \
    --dangerously-bypass-approvals-and-sandbox \
    "$@"
