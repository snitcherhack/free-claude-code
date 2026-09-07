@echo off
setlocal

echo Lanzando Codex en modo READ-ONLY...
call codex --sandbox read-only --ask-for-approval never %*
exit /b %ERRORLEVEL%
