#!/usr/bin/env bash

# Codex estrictamente read-only.
# No permite escrituras ni solicita escalado de permisos.

set -euo pipefail

echo "Lanzando Codex en modo READ-ONLY..."
exec codex \
    --sandbox read-only \
    --ask-for-approval never \
    "$@"
