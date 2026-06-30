# Audio Asset Sourcing Report

## Summary
* **Files successfully sourced:** 12
* **Files still missing:** 3
* **CC0 assets count:** 12
* **CC-BY assets count:** 0

## Source Packs Used
* **Kenney UI Audio** (via Calinou GitHub mirror)
  * License: CC0 1.0 Universal
  * URL: `https://github.com/Calinou/kenney-ui-audio`

* **OpenGameArt: Icy Heights**
  * License: CC0 1.0 Universal
  * URL: `https://opengameart.org/content/icy-heights`

## Sourced Files (Human Review Required)
All files below have been safely downloaded as CC0 candidates. They are currently marked **HUMAN_AUDIO_REVIEW_REQUIRED** to ensure they fit the "warm, soft, child-friendly" emotional tone requested.
* `res://assets/audio/ui/button_click.wav`
* `res://assets/audio/ui/dialogue_blip.wav`
* `res://assets/audio/player/jump.wav`
* `res://assets/audio/player/land.wav`
* `res://assets/audio/gameplay/hit.wav`
* `res://assets/audio/story/checkpoint.wav`
* `res://assets/audio/story/reward_star.wav`
* `res://assets/audio/story/reward_heart.wav`
* `res://assets/audio/story/reward_key.wav`
* `res://assets/audio/story/victory.wav`
* `res://assets/audio/story/game_over.wav`
* `res://assets/audio/music/main_theme_soft_loop.ogg`

## Missing Files
The following background loops/music could not be safely sourced via CC0 packages at this time without listening verification. They remain missing.
* `res://assets/audio/ambience/city_soft_loop.ogg`
* `res://assets/audio/ambience/birds_soft_loop.ogg`
* `res://assets/audio/ambience/wind_soft_loop.ogg`

## Candidate Source Pass 2
Following user feedback, additional CC0 assets were sourced to provide livelier and more expressive alternatives:
* **Jump Candidate**: `res://assets/audio/candidates/player/jump_option_1.flac` (Source: OpenGameArt, dklon, CC0) - A lively non-vocal jump alternative. True vocal options were blocked by asset download zip timeouts.
* **Hit Candidate**: `res://assets/audio/candidates/gameplay/hit_option_1.wav` (Source: OpenGameArt, Iwan Gabovitch, CC0) - A soft impact landing sound suitable for a mild ouch feel.
* **Music Candidate**: `res://assets/audio/candidates/music/level1_music_option_1.ogg` (Source: OpenGameArt, HorrorPen, CC0) - Upbeat loop intended for Level 1. Sourcing marked as BLOCKED_BY_ASSET due to OpenGameArt rate limits/download timeouts. The owner must download it manually from [here](https://opengameart.org/content/upbeat-short-music-loop-vorbis-oog).


## Suggested Volume Levels
When the coding agent integrates these files into `AudioStreamPlayer` nodes, please use the following DB offsets:
* Master Music: `-12 dB` to `-18 dB`
* Ambience: `-20 dB`
* UI Sfx: `-5 dB`
* Player Sfx (Jump/Land): `-10 dB`
* Gameplay Sfx (Hit): `-8 dB` 
* Story/Reward Sfx: `-5 dB`

## Integrity Confirmation
* No scripts were changed.
* No scenes were changed.
* `project.godot` was not changed.
* No game logic was altered.
