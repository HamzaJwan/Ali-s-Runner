# Audio Credits & Licensing

This document tracks the source and license of all audio assets used in Ali Runner.

## Current Audio Assets

All files below were sourced from **Kenney UI Audio** pack, available under Creative Commons 0 (CC0) license. No attribution is strictly required, but Kenney is credited for these amazing assets.
Source Repository: https://github.com/Calinou/kenney-ui-audio
Original License: CC0 1.0 Universal

### UI
* `res://assets/audio/ui/button_click.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `click1.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/ui/dialogue_blip.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `click2.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

### Player
* `res://assets/audio/player/jump.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch7.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/player/land.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch8.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

### Gameplay
* `res://assets/audio/gameplay/hit.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `click5.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

### Story
* `res://assets/audio/story/checkpoint.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch1.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/story/reward_star.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch2.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/story/reward_heart.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch3.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/story/reward_key.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch4.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/story/victory.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch5.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

* `res://assets/audio/story/game_over.wav`
  * Source Pack: Kenney UI Audio
  * Original Name: `switch6.wav`
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

### Ambience
* `res://assets/audio/ambience/city_soft_loop.ogg` - Missing (No safe CC0 candidate found yet)
* `res://assets/audio/ambience/birds_soft_loop.ogg` - Missing (No safe CC0 candidate found yet)
* `res://assets/audio/ambience/wind_soft_loop.ogg` - Missing (No safe CC0 candidate found yet)

### Music
* `res://assets/audio/music/main_theme_soft_loop.ogg`
  * Source Page: https://opengameart.org/content/icy-heights
  * Direct URL: https://opengameart.org/sites/default/files/theme-loop.ogg
  * Original Name: `theme-loop.ogg`
  * Author: Écrivain
  * License: CC0 1.0 Universal
  * Date Downloaded: 2026-06-28
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED

## Sourced Candidates Pass 2
The following candidates were sourced to replace click-like sounds and provide more lively, expressive alternatives, while remaining CC0 child-friendly.
Vocal jump sourcing was blocked due to OpenGameArt zip download timeouts, so a lively non-vocal jump alternative was provided.

### Player Jump Candidates
* `res://assets/audio/candidates/player/jump_option_1.flac`
  * Source Page: https://opengameart.org/content/jump-and-run-and-stand
  * Original Name: `jump.flac`
  * Author: dklon
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED
  * Engine note: Godot 4 has no built-in FLAC importer, so `.flac` cannot be
    loaded as an `AudioStream` directly. A same-content, same-license
    `res://assets/audio/candidates/player/jump_option_1.wav` was generated
    from this file (lossless PCM16 re-encode via `soundfile`, no audio
    processing/editing applied) so the engine can actually load it. The
    `.wav` twin carries the same source/author/license/status above and is
    now the active in-game jump sound, with `assets/audio/player/jump.wav`
    kept as the automatic fallback if it's ever removed.

### Gameplay Hit Candidates
* `res://assets/audio/candidates/gameplay/hit_option_1.wav`
  * Source Page: https://opengameart.org/content/jump-landing-sound
  * Original Name: `jumpland.wav`
  * Author: Iwan Gabovitch
  * License: CC0 1.0
  * Status: HUMAN_AUDIO_REVIEW_REQUIRED
  * Now the active in-game hit sound, with `assets/audio/gameplay/hit.wav`
    kept as the automatic fallback if it's ever removed.

### Music Candidates (Level 1)
* `res://assets/audio/candidates/music/level1_music_option_1.ogg`
  * Source Page: https://opengameart.org/content/upbeat-short-music-loop-vorbis-oog
  * Direct URL: https://opengameart.org/sites/default/files/Upbeat%20Loop_2.ogg
  * Author: HorrorPen
  * License: CC0 1.0
  * Status: BLOCKED_BY_ASSET (Download repeatedly timed out due to OGA rate limits, owner must download manually)
