@echo off
setlocal

echo Lanzando Codex...
call codex %*
exit /b %ERRORLEVEL%
