@echo off
title Claude Code Pro Launcher

:: Sincroniza hooks y memoria desde GitHub
git -C "%USERPROFILE%\.claude" pull --no-edit 2>nul

:: Añade node al PATH por si no está
set PATH=C:\Program Files\nodejs;%PATH%

echo Aplicando settings...
copy /Y "%~dp0settings\settings.json" "%USERPROFILE%\.claude\settings.json"

:: Limpia variables del proxy dvk-claude por si estan activas
set ANTHROPIC_BASE_URL=
set ANTHROPIC_API_KEY=
set ANTHROPIC_AUTH_TOKEN=
set ANTHROPIC_CLIENT_MODE=
set CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=

echo Lanzando Claude Code (Pro)...
claude
pause
