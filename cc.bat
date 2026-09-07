@echo off
setlocal EnableExtensions

rem ============================================================
rem Claude Code launcher
rem
rem Uso:
rem   cc
rem   cc --deepseek
rem
rem Conserva el directorio actual.
rem Aplica dvk-claude\settings\settings.json antes de arrancar.
rem No hace git pull automatico de %%USERPROFILE%%\.claude.
rem ============================================================

set "SCRIPT_DIR=%~dp0"
set "SETTINGS_SRC=%SCRIPT_DIR%settings\settings.json"
set "SETTINGS_DST=%USERPROFILE%\.claude\settings.json"
set "PROXY_DIR=%SCRIPT_DIR%proxy"
set "PROXY_LOG=%TEMP%\dvk-claude-proxy.log"
set "USE_DEEPSEEK=0"
set "PROXY_PID="

if /I "%~1"=="--deepseek" (
    set "USE_DEEPSEEK=1"
    shift
)

call :apply_settings
if errorlevel 1 exit /b %ERRORLEVEL%

if "%USE_DEEPSEEK%"=="1" goto deepseek

:native
set "ANTHROPIC_BASE_URL="
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_AUTH_TOKEN="
set "ANTHROPIC_CLIENT_MODE="
set "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="

echo Lanzando Claude Code...
if "%DVK_CLAUDE_DANGEROUS%"=="1" (
    call claude --dangerously-skip-permissions %1 %2 %3 %4 %5 %6 %7 %8 %9
) else (
    call claude %1 %2 %3 %4 %5 %6 %7 %8 %9
)
exit /b %ERRORLEVEL%

:deepseek
if not exist "%PROXY_DIR%" (
    echo ERROR: no existe el directorio del proxy:
    echo   %PROXY_DIR%
    exit /b 1
)

call :find_port_pid
if defined PORT_PID (
    echo ERROR: el puerto 8082 ya esta ocupado por PID %PORT_PID%.
    echo No se ha matado ningun proceso automaticamente.
    exit /b 1
)

echo Arrancando proxy DeepSeek desde:
echo   %PROXY_DIR%

start "DVK Claude Proxy" /min cmd /c ^
    "cd /d ""%PROXY_DIR%"" && uv run server.py > ""%PROXY_LOG%"" 2>&1"

echo Esperando a que arranque el proxy...
timeout /t 4 /nobreak >nul

call :find_port_pid
if not defined PORT_PID (
    echo ERROR: el proxy DeepSeek no ha abierto el puerto 8082.
    echo Revisa:
    echo   %PROXY_LOG%
    exit /b 1
)

set "PROXY_PID=%PORT_PID%"
set "ANTHROPIC_BASE_URL=http://127.0.0.1:8082"
set "ANTHROPIC_AUTH_TOKEN=freecc"
set "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1"

echo Lanzando Claude Code con DeepSeek...
if "%DVK_CLAUDE_DANGEROUS%"=="1" (
    call claude --dangerously-skip-permissions %1 %2 %3 %4 %5 %6 %7 %8 %9
) else (
    call claude %1 %2 %3 %4 %5 %6 %7 %8 %9
)
set "CLAUDE_EXIT=%ERRORLEVEL%"

echo Cerrando proxy DeepSeek...
taskkill /PID %PROXY_PID% /T /F >nul 2>&1

exit /b %CLAUDE_EXIT%

:apply_settings
if not exist "%SETTINGS_SRC%" (
    echo ERROR: no existe el archivo de settings:
    echo   %SETTINGS_SRC%
    exit /b 1
)

if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude" >nul 2>&1
copy /Y "%SETTINGS_SRC%" "%SETTINGS_DST%" >nul
if errorlevel 1 (
    echo ERROR: no se pudieron aplicar los settings de Claude.
    exit /b 1
)
exit /b 0

:find_port_pid
set "PORT_PID="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8082" ^| findstr "LISTENING"') do (
    set "PORT_PID=%%P"
)
exit /b 0
