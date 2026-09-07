@echo off
setlocal

echo WARNING: Codex arrancara SIN sandbox ni aprobaciones.
call codex --dangerously-bypass-approvals-and-sandbox %*
exit /b %ERRORLEVEL%
