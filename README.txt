DVK LAUNCHERS - Claude Code + Codex
==================================

Contenido
---------
Linux:
  cc.sh
  ccdanger.sh
  cx.sh
  cxro.sh
  cxdanger.sh

Windows:
  cc.bat
  ccdanger.bat
  cx.bat
  cxro.bat
  cxdanger.bat

Uso
---
Claude:
  cc                  Claude normal + settings
  cc --deepseek       Claude + settings + proxy DeepSeek
  ccdanger            Claude sin confirmaciones
  ccdanger --deepseek DeepSeek sin confirmaciones

Codex:
  cx                  Codex normal
  cxro                Codex read-only, sin escalado de permisos
  cxdanger            Codex sin sandbox ni aprobaciones

Estructura esperada del repo dvk-claude
---------------------------------------
  dvk-claude/
    cc.sh / cc.bat ...
    settings/settings.json
    proxy/

Linux
-----
Mantener en ~/.zshrc y ~/.bashrc:
  export PATH="$HOME/Proyectos/dvk-claude:$PATH"

Aliases recomendados:
  alias cc='cc.sh'
  alias ccdanger='ccdanger.sh'
  alias cx='cx.sh'
  alias cxro='cxro.sh'
  alias cxdanger='cxdanger.sh'

Dar permisos:
  chmod +x cc.sh ccdanger.sh cx.sh cxro.sh cxdanger.sh

Windows
-------
Anadir al PATH de usuario la raiz de dvk-claude, por ejemplo:
  A:\PROYECTOS\dvk-claude

Los .bat se invocan como:
  cc
  ccdanger
  cx
  cxro
  cxdanger

Notas
-----
- Los launchers conservan el directorio/repo desde el que se ejecutan.
- cc aplica settings/settings.json antes de lanzar Claude.
- No se hace git pull automatico sobre ~/.claude / %USERPROFILE%\.claude.
- DeepSeek queda como opcion explicita con --deepseek.
- cxro usa sandbox read-only + approval never, por lo que las acciones fuera
  del sandbox fallan en vez de pedir escalado.
- cxdanger elimina sandbox y aprobaciones: usar solo de forma consciente.
