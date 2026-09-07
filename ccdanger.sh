#!/usr/bin/env bash

# Claude Code sin confirmaciones.
#
# Uso:
#   ccdanger
#   ccdanger --deepseek

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAUNCHER="$SCRIPT_DIR/cc.sh"

if [[ ! -x "$LAUNCHER" ]]; then
    echo "ERROR: no encuentro el launcher ejecutable:"
    echo "  $LAUNCHER"
    exit 1
fi

echo "WARNING: Claude Code arrancara sin confirmaciones de permisos."

if [[ "${1:-}" == "--deepseek" ]]; then
    shift
    exec "$LAUNCHER" \
        --deepseek \
        --dangerously-skip-permissions \
        "$@"
fi

exec "$LAUNCHER" \
    --dangerously-skip-permissions \
    "$@"
