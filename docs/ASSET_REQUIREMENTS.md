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

## Future Character Animation, Helper, and Obstacle Assets

This table covers only the assets currently required to run the game. Future assets — Ali's animation poses, the sister/father helper portraits, reward icons, and additional obstacle types — are planned separately in `docs/ANIMATION_AND_ASSET_PLAN.md`, including the staged animation approach (separate PNG poses first), required paths, relative size rules, and the shared image-generation prompt requirements (transparent PNG, single character, no text/UI, consistent outfit, clean alpha, child-friendly semi-realistic style). None of those files exist yet.

### Ali Animation Pose Paths (slot system complete as of v0.8A/v0.8B)

These paths are the pose-slot targets used by `scripts/player_visual.gd` (v0.8A's slot system). **Owner note (verified 2026-06-28):** real distinct art now exists on disk for every path below except where noted — this section is kept even though the files exist, because the fallback behavior described below still applies to any pose file that's ever missing or removed:

* `res://assets/characters/ali/ali_idle.png` (exists, in use today)
* `res://assets/characters/ali/ali_run.png` (exists — single-pose fallback, used only if the 4-frame run cycle below is unavailable)
* `res://assets/characters/ali/ali_jump.png` (exists)
* `res://assets/characters/ali/ali_fall.png` (exists)
* `res://assets/characters/ali/ali_land.png` (exists)
* `res://assets/characters/ali/ali_slide.png` (exists)
* `res://assets/characters/ali/ali_hurt.png` (exists)
* `res://assets/characters/ali/ali_victory.png` (exists)

If any of these pose files is ever missing, the game must keep showing Ali's current `ali_idle.png` texture as the fallback — exactly the same fallback behavior already used for every other optional asset in this project. See `docs/ANIMATION_AND_ASSET_PLAN.md` ("Ali Animation Plan (Staged)") for the full staged plan.

### Ali 4-Frame Run Cycle Assets (v0.8B)

Preferred paths:

* `res://assets/characters/ali/ali_run_1.png`
* `res://assets/characters/ali/ali_run_2.png`
* `res://assets/characters/ali/ali_run_3.png`
* `res://assets/characters/ali/ali_run_4.png`

Requirements:

* Transparent PNG.
* One Ali per image — no background, no text, no UI.
* Same height and feet baseline across all four frames.
* Same outfit and identity as Ali's other poses.
* Suitable for the project's standard 100px in-game character height.
* Recommended source dimensions: `512x512` to `1024x1024` per frame, or one wider sheet used only as an art source before manually cutting it into the four separate files (see `docs/ANIMATION_AND_ASSET_PLAN.md` for the full workflow note).

Filename warning:

* Preferred names use underscores: `ali_run_1.png`, `ali_run_2.png`, `ali_run_3.png`, `ali_run_4.png`.
* A temporary compatibility path exists for `ali_run1.png` (no underscore, frame 1 only) — the loader checks it only if `ali_run_1.png` is missing. This is a fallback, not the preferred naming convention; rename to `ali_run_1.png` when convenient.

## Future Asset Folder Scaffold

As of v0.68, every future asset folder (characters, UI/reward icons, obstacles, and all audio subfolders) already exists on disk, each kept tracked with a small `README.md` instead of a placeholder asset. See `docs/ASSET_FOLDER_MAP.md` for the complete map of every folder, every expected file, which milestone needs it, and whether it's required now or later.

* Future folders may exist well before the real assets do — an empty folder (with just a `README.md`) is normal and expected, not a bug.
* Missing character assets use the game's existing placeholder/fallback behavior wherever it's implemented (e.g. Fatima's "فاطمة ⭐" text placeholder) — nothing needs to be "filled in" just to keep the game running.
* Invalid or fake PNG/audio files must never be placed in the project to "fill" an empty folder. If a folder is empty, leave it with only its `README.md` until a real, properly generated asset is ready.
