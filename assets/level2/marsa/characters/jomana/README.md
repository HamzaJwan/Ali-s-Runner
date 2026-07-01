# Jomana Character Assets — جمانة

**Drop final PNG files here. The game loads them automatically.**
See `docs/level2/JOMANA_IMAGE_REQUESTS.md` for exact specs and AI prompt templates.

## Folder structure

```
jomana/
├── run/        ← jomana_run_01.png … jomana_run_08.png  (REQUIRED)
├── idle/       ← jomana_idle_01.png … jomana_idle_04.png
├── jump/       ← jomana_jump_01.png, jomana_land_01.png
├── story/      ← jomana_smile_wave_01.png, jomana_dialogue_closeup_01.png
└── spritesheets/ ← jomana_run_spritesheet_8x1.png (future)
```

## Critical requirements
- Transparent PNG (no white/colored background)
- All frames SAME canvas size (256×256 recommended)
- Same character, same clothes, same face in every single frame
- Feet always at the same Y in every frame
- Facing RIGHT
- No baked-in shadows
- No text in image
