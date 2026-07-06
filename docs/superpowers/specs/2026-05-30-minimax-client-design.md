# MiniMax Client — Integración API en Pipeline YouTube

**Fecha:** 2026-05-30
**Estado:** Diseño aprobado — Pendiente implementación

## Resumen

Script `minimax_client.py` que llama a la API de MiniMax/Hailuo para generar clips de video desde prompts, con polling asíncrono y descarga automática. Se integra al pipeline YouTube existente en `youtube_automation/`.

## Ubicación

```
youtube_automation/scripts/minimax_client.py
```

## Ejecución

```powershell
cd A:\PROYECTOS\free-claude-code\youtube_automation
python scripts/minimax_client.py proyectos/video3_ia/minimax.json
```

Flags:
| Flag | Default | Descripción |
|------|---------|-------------|
| `--poll` | 10 | Segundos entre chequeos de estado |
| `--max-attempts` | 60 | Intentos máximos de polling |
| `--dry-run` | false | Validar JSON sin llamar API |
| `--resume` | true | Saltar escenas ya completadas |

## Formato JSON (entrada/estado)

```json
{
  "project": "video3_ia",
  "model": "MiniMax-Hailuo-2.3-Fast",
  "resolution": "1080P",
  "scenes": [
    {
      "id": "intro_1",
      "prompt": "A glowing AI brain floating in dark space [Slow zoom in]",
      "duration": 6
    }
  ]
}
```

Al terminar el script, el mismo JSON se actualiza con estado:
```json
{
  "id": "intro_1",
  "status": "completed",
  "task_id": "abc123",
  "file_id": "xyz789",
  "download_url": "https://...",
  "clip_file": "clips/intro_1.mp4"
}
```

## Flujo por escena

1. Leer `minimax.json`
2. Por cada escena:
   - Si ya tiene `download_url` → skip (resume)
   - Si tiene `task_id` → salta a polling
   - Si no → POST `/v1/video_generation` → guarda task_id
   - Polling: GET `/v1/query/video_generation` cada N segundos
   - Cuando status=Success → GET `/v1/files/{file_id}/url`
   - Descarga MP4 a `proyecto/clips/{scene_id}.mp4`
   - Actualiza `minimax.json`

## Estructura de salida

```
proyectos/video3_ia/
├── minimax.json          ← entrada + estado actualizado
├── clips/                ← clips descargados
│   ├── intro_1.mp4
│   └── body_1.mp4
├── audio/
├── music.mp3
└── final.mp4
```

## API Key

Variable de entorno `MINIMAX_API_KEY` o archivo `.env` en el proyecto.

## Endpoints

- `POST https://api.minimax.io/v1/video_generation` — crear tarea (async)
- `GET https://api.minimax.io/v1/query/video_generation?task_id=X` — estado
- `GET https://api.minimax.io/v1/files/{file_id}/url` — URL descarga

## Modelos y precios

| Modelo | Resolución | Precio/clip (6s) |
|--------|-----------|-------------------|
| Hailuo 2.3 Fast | 768p | $0.19 |
| Hailuo 2.3 Fast | 1080p | $0.33 |
| Hailuo 2.3 | 768p | $0.28 |
| Hailuo 2.3 | 1080p | $0.49 |

## No hace (v1)

- No genera prompts (lo hace VideoCraft en ChatGPT)
- No ensambla video final (lo hace `assemble_video.py`)
- No genera TTS ni imágenes (posible v2)
- No usa el endpoint `image_generation` ni `t2a_v2` (posible v2)

## Integración con pipeline

1. VideoCraft (ChatGPT) genera storyboard + prompts → copiar a `minimax.json`
2. `python scripts/minimax_client.py proyecto/minimax.json` → genera clips
3. `assemble_video.py` con clips + TTS + música → video final
