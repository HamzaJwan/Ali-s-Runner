# Ali Runner — Audio Design Plan

This is a planning document only. No audio is implemented yet, no audio files are downloaded, and no scripts/scenes are modified by this document.

## Audio Design Goal

Make Ali Runner feel alive, emotional, warm, and story-driven — not dry or silent. Audio should support the existing tone from `docs/STORY_PLAN.md`: warm, suspenseful but not scary, family-friendly, no violence, no horror.

## Full Sound List (Future)

* Background music
* City ambience loop
* Wind ambience
* Birds ambience
* Button click sound
* Jump sound
* Landing sound
* Running footstep loop (continuous, tied to Ali's run state — distinct from the one-shot jump/land sounds above; a later refinement, not part of v0.95)
* Obstacle hit sound
* Checkpoint sound
* Reward sound
* Game Over sound
* Victory sound
* Dialogue typing sound — small "تيت تيت تيت" keyboard/typewriter blips while Arabic text appears
* Optional soft story transition sound

## Implementation Direction (For Later — Not Now)

* Use `AudioStreamPlayer` for UI sounds, music, ambience, and other non-positional sounds. No `AudioStreamPlayer2D`/3D panning is needed for this game.
* Separate audio buses, added later:
  * Master
  * Music
  * SFX
  * UI
  * Ambience
* File formats:
  * WAV for short sound effects (jump, land, click, blip, checkpoint, hit).
  * OGG for music and ambience loops where possible.
* Keep volume low and comfortable — nothing jarring or loud for a child.
* No voice acting at first.
* No complex audio manager at first. Start with simple individual `AudioStreamPlayer` nodes; only introduce a small AudioManager singleton if and when implementation reveals it's actually needed (e.g. too many duplicated player nodes).
* No dynamic mixer UI, no procedural audio generation.

## Licensing / Free Audio Rules

All future audio assets must be free and legally usable.

**Preferred:**

* CC0 audio first (no attribution required, safest for a project that may be shared publicly).
* CC-BY only if attribution is documented in `docs/AUDIO_CREDITS.md`.

**Avoid:**

* NonCommercial (NC) licenses, if the game may be shared publicly.
* Unknown or undocumented license files.
* Random downloads with no traceable source.

## Future Free Audio Source Candidates

* Kenney audio assets, especially CC0 packs.
* OpenGameArt CC0 audio/music.
* Pixabay music/sound effects — check the license per asset before use.
* Freesound — only when the license is CC0, or attribution is properly documented.
* Mixkit — check its license per asset before use.

## Required Future Documentation: docs/AUDIO_CREDITS.md

When audio files are actually added (not now), create or update `docs/AUDIO_CREDITS.md`. Each audio file must document:

* File name
* Source URL
* Author
* License
* Usage in game
* Whether attribution is required

**No audio file may be added to the project without a matching `docs/AUDIO_CREDITS.md` entry at the same time.** See `docs/ASSET_SOURCING_PLAN.md` for the full sourcing/license plan shared with visual assets (CC0 preferred, no random downloads without a documented license).

**Ambience loop requirement:** every ambience loop (wind, birds, distant city) must stay low-volume and loop cleanly — no audible seam, click, or volume jump at the loop point — so it stays in the background and never competes with dialogue, SFX, or the player's attention.

## Proposed Future Audio Asset Paths

As of v0.68, all six audio subfolders below already exist on disk (each kept tracked with a small `README.md`), but **no audio files exist in any of them yet**. Do not download or place any audio file without first documenting its license per the rules above — when an audio file is actually added, create or update `docs/AUDIO_CREDITS.md` for it. See `docs/ASSET_FOLDER_MAP.md` for the full folder map alongside characters/UI/obstacles.

UI:

* `res://assets/audio/ui/button_click.wav`
* `res://assets/audio/ui/dialogue_blip.wav`

Player:

* `res://assets/audio/player/jump.wav`
* `res://assets/audio/player/land.wav`

Gameplay:

* `res://assets/audio/gameplay/hit.wav`

Story:

* `res://assets/audio/story/checkpoint.wav`
* `res://assets/audio/story/reward_star.wav`
* `res://assets/audio/story/reward_heart.wav`
* `res://assets/audio/story/reward_key.wav`
* `res://assets/audio/story/game_over_soft.wav`
* `res://assets/audio/story/victory.wav`

Ambience:

* `res://assets/audio/ambience/city_day_loop.ogg`
* `res://assets/audio/ambience/wind_light_loop.ogg`
* `res://assets/audio/ambience/birds_light_loop.ogg`

Music:

* `res://assets/audio/music/main_loop.ogg`
* `res://assets/audio/music/checkpoint_soft.ogg`
* `res://assets/audio/music/victory_theme.ogg`

## Implementation Order (See docs/AI_GAME_ROADMAP.md for full milestone details)

1. **v0.95 — Audio Foundations**: button click, jump, land, checkpoint, game over, victory, one soft background loop.
   * **v0.95A — STATUS: PARTIAL_COMPLETE (2026-06-28).** SFX wired via `scripts/audio/audio_manager.gd`: button click, dialogue blip, jump, land, hit, checkpoint, reward_star/heart/key, game over, victory — all 11 CC0 candidates from `docs/AUDIO_CREDITS.md` (Kenney UI Audio pack) load once and play through dynamically-created `AudioStreamPlayer`s, with safe no-crash fallback if any file is missing. **The "one soft background loop" part of v0.95 is still not done** — no ambience/music files exist yet (see `docs/AUDIO_CREDITS.md`), so it stays out of scope until a licensed loop is sourced. All 11 integrated sounds remain `HUMAN_AUDIO_REVIEW_REQUIRED` — they are generic Kenney UI clicks/switches repurposed for jump/land/hit/reward roles, not custom-composed for this game's tone, and haven't been quality-checked by ear yet.
2. **v0.96 — Dialogue Typing Sound**: typewriter-style blips during Arabic story text. Note: v0.95A already added a simple non-typewriter `dialogue_blip` on each dialogue *advance* (one blip per line shown, not per character) — v0.96 would still be the separate, later step of blips per-character while text appears, if ever pursued.
3. **v0.97 — Ambience Layers**: wind, birds, distant city loop. Still blocked — no licensed files exist.
4. **Future — Dynamic Music**: mood changes per story chapter (intro calm → after Fatima warmer → after Zainab braver → after Jomana more energetic → father ending emotional/victory).

Audio implementation must not begin before v0.95 is reached in the roadmap, and must not block or delay v0.65 (Fatima Checkpoint Prototype), which remains the next implementation task.
