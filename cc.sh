#!/usr/bin/env bash

# Claude Code launcher.
#
# Uso:
#   cc                  -> Claude normal
#   cc --deepseek       -> Claude usando DeepSeek via proxy
#   cc [args...]        -> pasa argumentos a Claude
#
# Se puede ejecutar desde cualquier repositorio sin cambiar el cwd.
# Aplica dvk-claude/settings/settings.json antes de arrancar Claude.

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_SRC="$SCRIPT_DIR/settings/settings.json"
SETTINGS_DST="$HOME/.claude/settings.json"
PROXY_DIR="$SCRIPT_DIR/proxy"
PROXY_LOG="${TMPDIR:-/tmp}/dvk-claude-proxy.log"
PROXY_PID_FILE="${TMPDIR:-/tmp}/dvk-claude-proxy-${UID}.pid"

USE_DEEPSEEK=0
PROXY_PID=""

if [[ "${1:-}" == "--deepseek" ]]; then
    USE_DEEPSEEK=1
    shift
fi

apply_settings() {
    if [[ ! -f "$SETTINGS_SRC" ]]; then
        echo "ERROR: no existe el archivo de settings:"
        echo "  $SETTINGS_SRC"
        exit 1
    fi

    mkdir -p "$(dirname "$SETTINGS_DST")"
    cp "$SETTINGS_SRC" "$SETTINGS_DST"
}

cleanup_proxy() {
    if [[ -n "${PROXY_PID:-}" ]] && kill -0 "$PROXY_PID" 2>/dev/null; then
        echo
        echo "Deteniendo proxy DeepSeek..."
        kill "$PROXY_PID" 2>/dev/null || true
        wait "$PROXY_PID" 2>/dev/null || true
    fi

    if [[ -f "$PROXY_PID_FILE" ]]; then
        local saved_pid
        saved_pid="$(cat "$PROXY_PID_FILE" 2>/dev/null || true)"
        if [[ "$saved_pid" == "${PROXY_PID:-}" ]]; then
            rm -f "$PROXY_PID_FILE"
        fi
    fi
}

stop_previous_managed_proxy() {
    [[ -f "$PROXY_PID_FILE" ]] || return 0

    local old_pid
    old_pid="$(cat "$PROXY_PID_FILE" 2>/dev/null || true)"

    if [[ "$old_pid" =~ ^[0-9]+$ ]] && kill -0 "$old_pid" 2>/dev/null; then
        # Solo detiene un proxy iniciado previamente por este launcher.
        if ps -p "$old_pid" -o args= 2>/dev/null | grep -Fq "uvicorn server:app"; then
            echo "Deteniendo proxy DeepSeek anterior (PID $old_pid)..."
            kill "$old_pid" 2>/dev/null || true
            sleep 1
        else
            echo "WARNING: el PID guardado no parece ser el proxy esperado; no se mata."
        fi
    fi

    rm -f "$PROXY_PID_FILE"
}

start_deepseek_proxy() {
    if [[ ! -d "$PROXY_DIR" ]]; then
        echo "ERROR: no existe el directorio del proxy:"
        echo "  $PROXY_DIR"
        exit 1
    fi

    stop_previous_managed_proxy

    echo "Arrancando proxy DeepSeek desde:"
    echo "  $PROXY_DIR"

    (
        cd "$PROXY_DIR" || exit 1
        exec uv run uvicorn server:app \
            --host 127.0.0.1 \
            --port 8082
    ) >"$PROXY_LOG" 2>&1 &

    PROXY_PID=$!
    echo "$PROXY_PID" > "$PROXY_PID_FILE"
    trap cleanup_proxy EXIT

    sleep 4

    if ! kill -0 "$PROXY_PID" 2>/dev/null; then
        echo "ERROR: el proxy DeepSeek no ha arrancado."
        echo "Log: $PROXY_LOG"
        tail -n 20 "$PROXY_LOG" 2>/dev/null || true
        exit 1
    fi
}

apply_settings

if (( USE_DEEPSEEK )); then
    start_deepseek_proxy

    export ANTHROPIC_BASE_URL="http://127.0.0.1:8082"
    export ANTHROPIC_API_KEY="freecc"
    export ANTHROPIC_CLIENT_MODE="api-key"
    export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1

    echo "Lanzando Claude Code con DeepSeek..."
    claude "$@"
    exit $?
fi

# Evita que variables heredadas de una sesion DeepSeek redirijan
# accidentalmente Claude al proxy.
unset ANTHROPIC_BASE_URL
unset ANTHROPIC_API_KEY
unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_CLIENT_MODE
unset CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY

echo "Lanzando Claude Code..."
exec claude "$@"
