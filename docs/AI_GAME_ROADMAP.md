# Ali Runner — AI Development Roadmap

## Project Identity

**Project name:** Ali Runner
**Engine:** Godot 4.7
**Game type:** 2D side-scrolling runner / light platformer
**Target platforms:** Web first, Android later
**Current level theme:** Al-Mantarah, Zliten, Libya
**Main character:** Ali
**Art style:** Semi-realistic 2D, family-friendly, Libyan local identity

This project is a personal family game inspired by Zliten, especially Al-Mantarah. The goal is to keep the game simple, playable, and emotionally warm, not technically overcomplicated.

---

## Current Status

Current milestone:

**v0.6 — Gameplay Feel Polish (completed)**

Tuned gameplay values:

* Gravity: `1050`
* Jump velocity: `-440`
* Max fall speed: `700`
* Jump input buffer: `0.12s`
* Obstacle speed: `225`
* Spawn interval: `2.25s`

Working features:

* Godot project runs successfully.
* Main scene: `res://scenes/Main.tscn`
* Start screen works.
* Play button works.
* Tap/click jump works.
* Space/Enter jump works.
* Score counter works.
* Obstacles spawn and move.
* Collision triggers Game Over.
* Restart button works.
* Visual assets load from `assets/`.
* Placeholder fallback system exists.
* Al-Mantarah/Zliten visual scene is implemented.
* Fixed road baseline is used:

  * `CURB_TOP_Y = 470`
  * `ROAD_SURFACE_Y = 510`
* Ali and obstacles are aligned to the road surface.
* Visual layering is working:

  * Sky behind all
  * Buildings behind gameplay
  * Foreground behind gameplay
  * Road/ground at gameplay layer
  * Player and obstacles above ground
  * UI above everything

---

## Core Rule for Future AI Agents

Do not rewrite the whole project.

All future work must be done in small, testable steps.

After every change:

1. Explain what files changed.
2. Explain how to test.
3. Preserve current working gameplay.
4. Keep fallback placeholders.
5. Do not remove existing features unless explicitly requested.
6. Do not add complex systems early.
7. Do not add networking, ads, login, accounts, analytics, or online services.
8. Keep physics feel (gravity, jump arc, fall speed, obstacle spacing, reaction time) realistic and child-friendly whenever obstacles, checkpoints, or collectibles are added or tuned.

---

## Current Important Files

Scenes:

* `res://scenes/Main.tscn`
* `res://scenes/Player.tscn`
* `res://scenes/Obstacle.tscn`

Scripts:

* `res://scripts/main.gd`
* `res://scripts/player.gd`
* `res://scripts/obstacle.gd`
* `res://scripts/asset_utils.gd`

Assets:

* `res://assets/characters/ali/ali_idle.png`
* `res://assets/backgrounds/mantarha/bg_sky.png`
* `res://assets/backgrounds/mantarha/bg_buildings.png`
* `res://assets/backgrounds/mantarha/bg_foreground.png`
* `res://assets/backgrounds/mantarha/ground_mantarha.png`
* `res://assets/objects/obstacle_block.png`

Docs:

* `res://docs/ASSET_REQUIREMENTS.md`
* `res://docs/AI_GAME_ROADMAP.md`
* `res://docs/STORY_PLAN.md`
* `res://docs/FUTURE_FEATURE_BACKLOG.md`
* `res://docs/AUDIO_DESIGN_PLAN.md`

---

## Development Philosophy

This project must stay easy for a non-programmer owner to manage.

The owner should only need to:

* Generate PNG assets.
* Place PNG files in the correct folders.
* Test the game by pressing F6 or F5.
* Report screenshots or errors.

AI/Codex should handle:

* Godot scripts.
* Scene wiring.
* Asset loading.
* Scaling.
* Gameplay tuning.
* Documentation.

---

## Milestone Roadmap

### v0.55 — Story and Future Feature Documentation

Goal:
Document the story, Arabic dialogue, future features, character size rules, and implementation order.

Scope:

* Update `AI_GAME_ROADMAP.md`.
* Create/update `STORY_PLAN.md`.
* Create/update `FUTURE_FEATURE_BACKLOG.md`.
* No code changes.

Acceptance criteria:

* All three docs exist and describe the same story, thresholds, and order consistently.
* No scripts, scenes, assets, or `project.godot` are changed.

---

### v0.6 — Gameplay Feel Polish

Goal:
Tune the current runner so it feels fair and comfortable for a child.

Scope:

* Jump height.
* Gravity.
* Obstacle speed.
* Spawn spacing.
* One-tap feel.

No story checkpoints yet.

Success criteria:

* Ali jumps over obstacles comfortably.
* Obstacles are not too frequent.
* A child can understand the gameplay quickly.
* Game remains stable.

Do not add:

* animation
* collectibles
* sisters
* level system
* Android export

---

### v0.61 — Obstacle Spawn Offscreen Fix

Goal:
Fix obstacle spawning so obstacles always appear outside the right edge of the screen and move into view naturally.

Scope:

* Ensure obstacles spawn at x > viewport width + safe margin.
* Keep obstacle speed and spacing from v0.6 unless a small adjustment is needed.
* Keep current single obstacle type.
* Do not add random obstacle types yet.
* Do not add story checkpoints yet.

Acceptance criteria:

* No obstacle appears suddenly in the middle of the screen.
* Obstacles enter naturally from the right.
* Jump, score, Game Over, Restart still work.

---

### v0.65 — Story Foundations: Fatima Checkpoint Prototype

Goal:
Implement the smallest possible story checkpoint system using Fatima only.

Scope:

* Trigger checkpoint at score 15.
* Pause gameplay briefly.
* Show one reusable story/checkpoint panel.
* Show Fatima helper portrait or placeholder.
* Show Arabic dialogue (see `docs/STORY_PLAN.md`).
* Continue button resumes gameplay.
* Slight difficulty increase after Continue (do not change obstacles dramatically at this first checkpoint).

Required asset:

* `res://assets/characters/fatima/fatima_helper.png`

Fallback:

* If the Fatima asset is missing, use a simple placeholder so the checkpoint still works.

Acceptance criteria:

* When Ali reaches score 15, gameplay pauses.
* Fatima checkpoint panel appears with Arabic dialogue.
* Continue resumes the game.
* Obstacles continue after resume.
* Existing gameplay still works.

Do not add:

* Zainab
* Jomana
* father ending
* camera zoom
* animation
* real power-up effects
* audio
* parallax
* new levels

See `docs/STORY_PLAN.md` for full dialogue and story details.

---

### v0.66 — Checkpoint Retry and Emotional Game Over

Goal:
Turn reached story checkpoints into retry points and make Game Over emotionally tied to the story.

Scope:

* Track last reached checkpoint.
* On death, show story-aware Game Over text.
* Offer Retry from Last Checkpoint.
* Offer Restart from Beginning.
* If no checkpoint reached, restart from beginning only or retry from start.
* Do not add new characters beyond those already implemented.
* Do not add real reward effects yet.

Example emotional Game Over lines:

Before Fatima:

* "الطريق ما زال في بدايته يا علي… حاول مرة ثانية."

After Fatima:

* "نجمة فاطمة ما زالت تنور لك الطريق… ارجع وحاول من جديد."

After Zainab:

* "الشجاعة لا تعني أنك لا تقع… بل أنك تقوم مرة أخرى."

After Jomana:

* "مفتاح الطريق معك… النهاية قريبة."

Near Father:

* "بابا ينتظرك في آخر الطريق… لا توقف الآن."

Acceptance criteria:

* Death screen changes based on last checkpoint.
* Retry from checkpoint works.
* Restart from beginning still works.
* Existing Game Over logic remains stable.

See `docs/STORY_PLAN.md` ("Death and Retry Tone") for the emotional framing behind these lines.

---

### v0.7 — Remaining Story Checkpoints + Father Ending

Goal:
Add Zainab, Jomana, and father ending using the same checkpoint system.

Scope:

* Zainab checkpoint at score 35.
* Jomana checkpoint at score 60.
* Father ending at score 90, as a win state distinct from Game Over.
* Final success panel.
* Reuse the same checkpoint panel and pause/resume pattern from v0.65.

Required assets:

* `res://assets/characters/zainab/zainab_helper.png`
* `res://assets/characters/jomana/jomana_helper.png`
* `res://assets/characters/father/father_ending.png`

Fallback:

* If any character asset is missing, use a simple placeholder so each checkpoint still works.

Acceptance criteria:

* Ali meets Zainab, then Jomana, then Father in order as score increases.
* Each checkpoint pauses, shows Arabic dialogue, and resumes on Continue.
* Reaching Father shows the final success panel ("اكتملت الرحلة — المنطرحة، زليتن").
* Existing gameplay (jump, score, Game Over, Restart) still works.

Rewards are mostly visual/flavor text at this stage — real effects come in v0.9.

Do not add:

* real shield mechanic
* real boost mechanic
* camera zoom
* animation
* beach/desert level
* Android export

See `docs/STORY_PLAN.md` for full dialogue and story details.

---

### v0.75 — Obstacle Variety and Difficulty Chapters

Goal:
Make gameplay change slightly after each story checkpoint.

Obstacle variety comes after the checkpoint/story systems (v0.61, v0.65, v0.66, v0.7) are stable — not before.

Scope:

* Chapter 1: simple concrete obstacles (current baseline, before Fatima).
* Chapter 2, after Fatima: slightly faster obstacles.
* Chapter 3, after Zainab: one new safe obstacle type.
* Chapter 4, after Jomana: final challenge before father.

Future obstacle variety (introduced one at a time, after the offscreen spawn fix from v0.61 is stable):

* concrete block
* road barrier
* small construction cone
* low crate
* broken road sign

Rules:

* Add one obstacle type at a time.
* All obstacles must spawn offscreen (per v0.61).
* All obstacles must be child-friendly and readable.
* No impossible combinations.
* Keep fallback placeholders.
* Keep it child-friendly — do not make the game frustrating.

Random obstacle-type selection (choosing among multiple types) is a later step, only after the first simple offscreen spawn fix (v0.61) and at least one additional obstacle type are individually stable.

---

### v0.8 — Ali Basic Animation

Goal:
Add simple animation/pose switching for Ali.

Possible future poses (add incrementally, not all at once):

* `idle_breathing`
* `run`
* `jump`
* `fall`
* `land`
* `slide`
* `hurt`
* `victory`

Preferred simple implementation:

* Use separate PNG poses first.
* Add sprite sheet later only if needed.
* Keep fallback if any pose image is missing.

Success criteria:

* Ali changes visual pose while jumping.
* Idle/start pose still works.
* Gameplay collision remains simple and unchanged.

---

### v0.85 — Static Helper Assets

Goal:
Add static helper images for Fatima, Zainab, Jomana, and Father ending.

Relative size rules:

* Father is about 2x Ali's height in the ending panel (he is an adult).
* Ali is the largest child character.
* Jomana is smaller than Ali but older than the other sisters.
* Zainab is smaller than Jomana.
* Fatima is the smallest, shown as a seated baby helper/portrait, not a full runner.

Superseded note:
The earlier "v0.85 — Collectibles" milestone is moved to `docs/FUTURE_FEATURE_BACKLOG.md` as a standalone, optional feature. A lightweight version of the same idea (Fatima's bonus star) ships as part of v0.9 instead.

---

### v0.9 — Real Reward Effects

Goal:
Turn story rewards into simple gameplay effects.

Scope:

* Fatima: bonus star / extra score.
* Zainab: one-hit shield or temporary protection.
* Jomana: short boost or safer obstacle spacing.

Implement one reward at a time.

Success criteria:

* Each reward has one clear, noticeable effect.
* Effects are small, temporary, and do not stack.
* Core gameplay loop (jump, score, Game Over, Restart) remains unchanged otherwise.

Do not add:

* multiple stacking effects
* new UI beyond what v0.65/v0.7 already added
* animation system changes

---

### v0.95 — Audio Foundations

Goal:
Add the first simple sounds.

Scope:

* button click
* jump
* land
* checkpoint
* game over
* victory
* one soft background loop

Do not add:

* voice acting
* advanced mixer UI
* dynamic music
* procedural audio
* large audio manager unless needed

See `docs/AUDIO_DESIGN_PLAN.md` for the full sound list, file format rules, bus layout, and licensing rules.

---

### v0.96 — Dialogue Typing Sound

Goal:
Add dialogue text blips for story panels.

Scope:

* Arabic text appears gradually.
* A small blip sound plays while text appears.
* Player can press Space / click / tap to advance.
* Must not spam sound too loudly.
* Add an option to skip/complete the line instantly.

See `docs/AUDIO_DESIGN_PLAN.md` for the proposed `dialogue_blip.wav` asset path.

---

### v0.97 — Ambience Layers

Goal:
Add soft background life.

Scope:

* wind loop
* birds loop
* distant city loop
* optional palm rustle later

Important:

* Ambience must be low volume.
* It should not distract from gameplay.
* It should loop smoothly.

---

### v1.0 — Level 1 Complete: Al-Mantarah, Zliten

Goal:
Complete the first full playable story level.

Features:

* Intro.
* Start/Play.
* Gameplay.
* Fatima checkpoint.
* Zainab checkpoint.
* Jomana checkpoint.
* Father ending.
* Arabic dialogue.
* Score.
* Obstacles.
* Restart.
* Stable gameplay.

Success criteria:

* The game feels like a complete small level.
* It can be shown to family.
* It works reliably on desktop.

---

### v1.1 — Cinematic Intro Prototype

Goal:
Add a simple opening story scene.

Scope:

* Static background.
* Arabic narration.
* "هنا تبدأ القصة..." moment.
* Then start game.

Important:

* No complex cutscene system.
* Camera zoom only if safe later (see v1.15).

---

### v1.15 — Camera Zoom and Focus Moments

Goal:
Add limited camera/focus effects after the story is stable.

Scope:

* Optional `Camera2D`.
* Zoom on Ali at intro.
* Focus on checkpoint moments.

Important:

* Do not break the fixed viewport layout.
* Implement as a separate step, after v1.1 is stable.

---

### v1.2 — Background Motion / Parallax

Goal:
Make the environment feel alive.

Scope:

* Moving clouds.
* Subtle parallax.
* Dust particles.
* Moving palm leaves later.

Do not affect gameplay collision.

---

### v1.3 — Character Animation Expansion

Goal:
Later animation expansion for Ali and family.

Do not start this before static story (v1.0) works.

---

### v1.4 — Web Export

Goal:
Export the game to HTML5/Web.

Tasks:

* Configure export preset.
* Test browser play.
* Confirm click/tap input works.
* Confirm asset paths work after export.
* Confirm screen size and scaling are acceptable.

Success criteria:

* Game opens in browser.
* Play button works.
* Tap/click jump works.
* Game is playable.

---

### v1.5 — Android Preparation

Goal:
Prepare Android export only after the web version is stable.

Tasks:

* Configure Android export.
* Check screen scaling.
* Check touch input.
* Check performance.
* Create APK for local family testing.

Do not start Android before v1.4 is stable.

---

### v1.6 — Level 2 / Part 2: Sisters Adventure

Goal:
Future idea only.

Maybe allow playing as one of Ali's sisters in another location such as beach, garden, or another part of Zliten.

This is backlog only and should not affect Level 1 development. See `docs/FUTURE_FEATURE_BACKLOG.md` ("Dream backlog") for details.

---

## Future — Coins / Collectibles Risk-Reward

Goal:
Add coins or light fragments to tempt the player and create interesting decisions.

Possible items:

* `coin_collectible.png`
* `light_fragment.png`
* `date_collectible.png`
* `star_collectible.png`

Design:

* Coins should encourage risk, but not feel unfair.
* Coins should sometimes appear near obstacles, but never inside impossible paths.
* Coins should support the story idea of collecting light/hope.
* Collectibles should come after checkpoints (v0.61/v0.65/v0.66/v0.7) are stable.

This is not yet scheduled as a numbered milestone. See `docs/FUTURE_FEATURE_BACKLOG.md` ("Medium-Risk Features") for tracking.

---

## Future — Dynamic Music

Goal:
Change music mood between story chapters.

* Intro: calm.
* After Fatima: warmer.
* After Zainab: braver.
* After Jomana: more energetic.
* Father ending: emotional/victory.

This is later, not part of v0.95. It depends on v0.95 (Audio Foundations) and v0.97 (Ambience Layers) being stable first. See `docs/AUDIO_DESIGN_PLAN.md` and `docs/FUTURE_FEATURE_BACKLOG.md` ("High-Risk / Later Features") for tracking.

---

## Asset Naming Rules

Use exact file names.
Avoid double extensions.

Correct:

* `ali_idle.png`

Wrong:

* `ali_idle.png.png`

Transparent PNGs must have real alpha transparency.
Do not export checkerboard preview pixels as part of the image.

---

## Current Known Visual Notes

Current scene is acceptable for v0.5.

Possible future polish:

* Ali can be moved slightly more toward the road lane if needed.
* Background composition can be refined later.
* Road and building layers are currently good enough for prototype.
* Do not over-polish before gameplay feel is improved.

---

## Next Recommended Task

**v0.6 — Gameplay Feel Polish is complete.** Tuned values are recorded under "Current Status" above.

The next implementation task is:

**v0.61 — Obstacle Spawn Offscreen Fix**

Prompt to use later:

“Fix obstacle spawning only. Make obstacles always spawn outside the right edge of the viewport and move into view naturally, instead of appearing suddenly inside the visible play area. Keep the current obstacle speed and spacing from v0.6 unless a small adjustment is required. Do not add new obstacle types, story checkpoints, or any other feature. Do not rewrite the project.”

After v0.61, the next milestones are **v0.65 — Story Foundations: Fatima Checkpoint Prototype** and then **v0.66 — Checkpoint Retry and Emotional Game Over**. Full dialogue and story details are documented in `docs/STORY_PLAN.md`, and the longer-term feature order is documented in `docs/FUTURE_FEATURE_BACKLOG.md`.

Audio (v0.95/v0.96/v0.97 and beyond) is planned in `docs/AUDIO_DESIGN_PLAN.md` but is not implemented yet and does not change this order — v0.65 remains the next implementation task.

---

## Final Instruction for AI Agents

This is a working project. Treat it carefully.

Make small changes.
Test often.
Preserve the current playable state.
