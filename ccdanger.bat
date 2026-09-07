@echo off
setlocal EnableExtensions

rem Claude Code sin confirmaciones.
rem
rem Uso:
rem   ccdanger
rem   ccdanger --deepseek

set "LAUNCHER=%~dp0cc.bat"

if not exist "%LAUNCHER%" (
    echo ERROR: no encuentro:
    echo   %LAUNCHER%
    exit /b 1
)

echo WARNING: Claude Code arrancara sin confirmaciones de permisos.
set "DVK_CLAUDE_DANGEROUS=1"
call "%LAUNCHER%" %*
exit /b %ERRORLEVEL%
