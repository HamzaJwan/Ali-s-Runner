# Asset Requirements

Place each PNG at the exact path below. If an image is missing, the game keeps using its colored placeholder where applicable.

| File name | Folder path | Recommended source dimensions | Transparency | Expected in-game size | Purpose |
| --- | --- | --- | --- | --- | --- |
| `ali_idle.png` | `assets/characters/ali/` | `512x512` to `1024x1024` | Yes | About `110 px` tall | Ali's idle character art |
| `bg_sky.png` | `assets/backgrounds/mantarha/` | `1152x648` | No | Fills `1152x648` | Full-screen sky layer |
| `bg_buildings.png` | `assets/backgrounds/mantarha/` | `1152x648` | Yes | Fills `1152x648` | Buildings over the sky |
| `bg_foreground.png` | `assets/backgrounds/mantarha/` | `1152x648` | Yes | Fills `1152x648` | Foreground details behind gameplay |
| `ground_mantarha.png` | `assets/backgrounds/mantarha/` | `1152x70` or wider | Yes or No | `1152x70` strip | Ground aligned with the collision surface |
| `obstacle_block.png` | `assets/objects/` | `512x512` to `1024x1024` | Yes | About `65 px` tall | Runner obstacle art |

## Exact paths

- `res://assets/characters/ali/ali_idle.png`
- `res://assets/backgrounds/mantarha/bg_sky.png`
- `res://assets/backgrounds/mantarha/bg_buildings.png`
- `res://assets/backgrounds/mantarha/bg_foreground.png`
- `res://assets/backgrounds/mantarha/ground_mantarha.png`
- `res://assets/objects/obstacle_block.png`

## File-name warning

The preferred names end in one `.png` extension. Windows may hide known extensions, which can accidentally create names such as `ali_idle.png.png`. The game temporarily supports these double-extension names, but rename them to the clean names above when convenient.

## Transparency warning

- The image must have real transparency. Do not export a checkerboard preview as pixels.
- Transparent PNG files should show alpha transparency in Godot, not gray-white squares.
- If checkerboard appears in-game, regenerate or clean the PNG.

The loader cannot safely remove a checkerboard baked into the artwork because those squares are ordinary image pixels, not transparent areas.

## Audio Assets

This document covers visual (PNG) assets only. Future audio assets (music, ambience, sound effects, dialogue blips) are planned separately in `docs/AUDIO_DESIGN_PLAN.md`, including proposed file paths, file format rules (WAV for short SFX, OGG for music/ambience), and licensing rules (CC0 preferred, CC-BY with documented attribution). No audio files exist yet.
