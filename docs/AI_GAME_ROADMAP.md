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

**v0.8B — Ali 4-Frame Run Cycle (complete, per Codex report). Next: v0.8B-R (owner F6 review), then v0.8C — Ali Pose Polish Pass.**

Ali now cycles through four run frames while grounded/running, using the existing `Sprite2D` texture-swap architecture (no `AnimationPlayer`, no `AnimatedSprite2D`, no sprite-sheet slicing). The run cycle is cached and runs at 10 FPS. Run animation stops the moment Ali jumps, falls, lands, is hurt, idles, or enters a story checkpoint state. The existing fallback system (frames → `ali_run.png` → `ali_idle.png` → placeholder) is preserved.

Tuned gameplay values (from v0.6):

* Gravity: `1050`
* Jump velocity: `-440`
* Max fall speed: `700`
* Jump input buffer: `0.12s`
* Obstacle speed: `225` (base, before the Fatima checkpoint)
* Spawn interval: `2.25s`

Obstacle spawn fix (v0.61):

* Obstacles spawn at `x = 1292` (offscreen right) and enter naturally.

Fatima checkpoint (v0.65), implemented in `scripts/main.gd` and `scenes/Main.tscn`:

* Triggers once when score reaches `15`.
* Pauses the scene tree (`get_tree().paused = true`).
* Shows the checkpoint panel with Fatima's Arabic dialogue and the reward text ("حصلت على نجمة الفرح").
* Continue button (متابعة / Continue) keeps processing while paused and resumes gameplay on press.
* Obstacle speed increases from `225` to `240` after Continue (spawn interval `2.25s` and spawn `x = 1292` unchanged).
* Restart resets both the checkpoint state and the difficulty bump back to baseline.
* `res://assets/characters/fatima/fatima_helper.png` is optional — currently missing, so a placeholder ("فاطمة ⭐") is shown automatically. Dropping the real PNG in later replaces it with no code changes.

Checkpoint retry and emotional Game Over (v0.66), implemented on top of v0.65:

* Game Over now tracks two checkpoint states: `NONE` and `FATIMA`.
* Game Over text changes depending on the last checkpoint reached (see the v0.66 milestone below for the exact lines).
* Retry from Last Checkpoint resumes at score `15`, obstacle speed `240` (the post-Fatima state).
* Restart from Beginning resets to score `0`, obstacle speed `225` (baseline), exactly as before.

Cinematic Fatima encounter (v0.67), implemented on top of v0.65/v0.66:

* Fatima enters from the right, like a world object, with no harmful collision.
* Cinematic dialogue advances by Space/click/tap (Fatima's line, then Ali's reply, then the reward text).
* A 3-2-1 countdown plays before gameplay resumes.
* Retry after Fatima still resumes at score `15`, obstacle speed `240`; Restart from beginning still resets to score `0`, obstacle speed `225` — unchanged from v0.66.

Asset folder scaffold (v0.68), documentation/structure only:

* Every future asset folder (characters, UI/reward icons, obstacles, all audio subfolders) now exists on disk, each kept tracked with a small `README.md`.
* `docs/ASSET_FOLDER_MAP.md` is the master map of every folder, every expected file, milestone, and fallback status.
* No real PNG/audio assets were added. No gameplay changed.
* Note: `assets/characters/fatima/fatima_helper.png` already exists on disk, but it's a real photo (not the documented transparent game asset) — see that folder's `README.md` and "Next Recommended Task" below.

Cinematic Encounter Polish (v0.70P), implemented directly in code (verified during the v0.71/v0.72 work below) — the visual presentation described as a future goal is now real:

* Fatima and Father are revealed in place with a fade-in (no walking/sliding) — correct for a newborn and for an adult who shouldn't sprint down the road. Zainab and Jomana still enter actively from offscreen right, per "Zainab and Jomana may enter more actively if needed."
* The checkpoint card is a rounded-corner `Panel` with a `StyleBoxFlat` (warm dark-brown background, thin golden border, drop shadow) instead of a plain `ColorRect`.
* A speaker-name badge (`SpeakerName` label) shows above the current line (فاطمة / زينب / جمانة / الأب / علي / النظام).
* The panel fades in and the card scales in slightly on open; the reward text pops with an ease-out scale tween; the countdown number pops on each digit change.
* Not yet done from the original polish wish list: no fade-out before gameplay resumes (countdown hides instantly), no "gentle portrait bob" idle motion, no explicit glow effect beyond the reward-text pop. These remain optional future refinements — see the v0.70P milestone below for the up-to-date status.

Zainab checkpoint (v0.70), Jomana checkpoint (v0.71), and Father ending (v0.72), all implemented on the same pattern as Fatima/v0.67:

* Zainab triggers at score 35, obstacle speed becomes `255` after Continue.
* Jomana triggers at score 60, obstacle speed becomes `270` after Continue.
* Father triggers at score 90 — a win state, not a checkpoint: the final Continue button reads "العب من جديد / Play Again" and restarts the game from the beginning (score 0, speed 225) instead of resuming with a countdown.
* Game Over now tracks `NONE`/`FATIMA`/`ZAINAB`/`JOMANA`. Retry from Last Checkpoint resumes at the correct score/speed for whichever of these was last reached; Restart from Beginning always resets to score 0 / speed 225.
* Required assets `zainab_helper.png`, `jomana_helper.png`, `father_ending.png` are all still missing — each falls back to its placeholder ("زينب ❤️", "جمانة 🗝️", "بابا") exactly like Fatima's pattern.

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
9. No HP/lives bar. Decision (2026-06-28, see `docs/FUTURE_FEATURE_BACKLOG.md` "Design Decisions — Not Doing For Now"): one hit still ends the run immediately, and v0.66's checkpoint retry plus Zainab's future one-hit shield (v0.9) already give the player a forgiving second chance without a numeric health system. Do not add a lives/HP counter.

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
* `res://docs/ANIMATION_AND_ASSET_PLAN.md`
* `res://docs/ASSET_FOLDER_MAP.md`

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

### v0.65 — Story Foundations: Fatima Checkpoint Prototype — STATUS: COMPLETE

Goal:
Implement the smallest possible story checkpoint system using Fatima only.

Implementation note (recorded after completion):
Implemented in `scripts/main.gd` and `scenes/Main.tscn` only. See "Current Status" above for the exact recorded behavior (trigger, pause, difficulty bump, fallback). No audio, animation, camera, parallax, coins, Zainab, Jomana, or Father were added — exactly as scoped below.

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

### v0.66 — Checkpoint Retry and Emotional Game Over — STATUS: COMPLETE

Goal:
Turn reached story checkpoints into retry points and make Game Over emotionally tied to the story.

Implementation note (recorded after completion):
Game Over tracks `NONE`/`FATIMA` checkpoint state. Retry from Last Checkpoint resumes at score 15 / obstacle speed 240; Restart from Beginning resets to score 0 / obstacle speed 225. See "Current Status" above.

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

### v0.67 — Cinematic Fatima Encounter Flow — STATUS: COMPLETE

Goal:
Improve the Fatima checkpoint so it feels like Ali actually reaches Fatima in the street, before showing dialogue — instead of a static UI panel only.

Implementation note (recorded after completion):
Fatima enters from the right with no harmful collision; cinematic dialogue advances by Space/click/tap; reward text appears; a 3-2-1 countdown resumes gameplay. Retry/Restart behavior from v0.66 is unchanged. See "Current Status" above.

Story flow:

1. Ali reaches score 15 by passing/jumping over the 15th obstacle.
2. New obstacles stop spawning.
3. Existing active obstacles are removed, hidden, or allowed to leave safely.
4. Fatima appears from outside the right side of the screen, like other world objects, but she is not an obstacle and has no harmful collision.
5. Fatima is seated safely near the curb/road edge — not standing, not jumping, not crawling.
6. Fatima moves into a visible story position.
7. Gameplay pauses.
8. The same Al-Mantarah background remains visible.
9. The scene becomes cinematic:
   * Soft dim overlay.
   * Focus on Ali and Fatima.
   * Fake zoom or UI close-up first, not a complex `Camera2D` system.
   * Real `Camera2D` zoom remains a later milestone (v1.15) unless safely isolated.
10. Fatima speaks first.
11. The player presses Space / click / tap / Next.
12. Ali replies.
13. The player presses Next again.
14. Reward text appears.
15. The player presses Continue.
16. Ali returns to his normal runner position.
17. Show a countdown: 3, 2, 1.
18. Gameplay resumes with obstacle speed 240.
19. Fatima checkpoint is marked completed.
20. Retry from checkpoint (v0.66) later resumes after this moment.

Dialogue sequence:

فاطمة:
"آآ… علي! ⭐"

علي:
"فاطمة… لقيتك. كنت عارف إن نورك قريب يا فاطمة."

System reward text:
"حصلت على نجمة الفرح."

Important narrative notes:

* Fatima is a newborn/baby.
* She does not jump, run, or speak full sentences.
* She gives the star through a gentle baby gesture.
* Ali understands her and responds emotionally.
* The scene should be warm, gentle, family-friendly — not sad or scary.

Technical design notes:

* Prefer extending the existing checkpoint panel/system instead of rewriting it.
* Avoid a full `Camera2D` implementation in v0.67 unless it can be done safely without breaking the fixed viewport layout.
* Prefer a safe "fake zoom" first: dim overlay, larger character portraits or a focused story panel, optional slight scale/tween. Keep the real `Camera2D` zoom milestone under v1.15.
* The player advances dialogue using Space, mouse click, or tap.
* The cinematic UI must keep processing input while the game is paused (same pattern as the existing Continue button).
* The countdown (3, 2, 1) must appear before gameplay resumes.
* The existing v0.66 Game Over retry system must remain stable.

Asset reminder:

* Real asset path: `res://assets/characters/fatima/fatima_helper.png`.
* Static PNG is enough for now — no animation required.
* Transparent PNG; Fatima seated, calm, holding/offering the glowing star.
* The placeholder remains acceptable until the owner provides the PNG.

Future reuse:
This cinematic checkpoint flow becomes the template for the Zainab checkpoint, the Jomana checkpoint, and the Father ending — but v0.67 implements only Fatima. Do not build Zainab/Jomana/Father into this step.

Do not add:

* Zainab, Jomana, or father ending content
* real `Camera2D` zoom (unless safely isolated and not breaking the fixed viewport)
* animation system
* audio
* parallax
* real power-up effects
* new obstacle types

See `docs/STORY_PLAN.md` ("Cinematic Checkpoint Presentation") for the full narrative framing and reuse plan.

---

### v0.68 — Asset Folder Scaffold and Replacement-Ready Structure — STATUS: COMPLETE

Goal:
Prepare the folder structure and documentation for future characters, rewards, obstacles, animation poses, and audio assets.

Scope:

* Create future asset folders.
* Add `README.md`/`.gitkeep` files so folders are tracked.
* Create `docs/ASSET_FOLDER_MAP.md`.
* Do not add real assets.
* Do not modify gameplay.

Acceptance criteria:

* All future asset folders exist.
* No invalid placeholder PNG/audio files are created.
* Documentation tells the owner exactly where to place future assets.
* Current game still runs unchanged.

Implementation note (recorded after completion):
Created `assets/characters/{zainab,jomana,father}/`, `assets/audio/` and its six subfolders (`ui/`, `player/`, `gameplay/`, `story/`, `ambience/`, `music/`), each with a `README.md`. Also added `README.md` to the existing `assets/ui/` (previously empty/untracked), `assets/characters/ali/`, and `assets/objects/` folders for owner guidance. Created `docs/ASSET_FOLDER_MAP.md` and cross-referenced it from `docs/ASSET_REQUIREMENTS.md`, `docs/ANIMATION_AND_ASSET_PLAN.md` (new Section 8, "Owner Asset Replacement Workflow"), and `docs/AUDIO_DESIGN_PLAN.md`. Discovered during this task: `assets/characters/fatima/fatima_helper.png` already exists on disk and is actively loaded by the game, but it is a real photo, not the documented transparent game asset — flagged in `docs/ASSET_FOLDER_MAP.md` and that folder's `README.md` for owner review.

---

### v0.7 — Remaining Story Checkpoints + Father Ending — SPLIT

This single milestone is split into three small, safe steps below (v0.70, v0.71, v0.72), so each checkpoint can be implemented and tested independently instead of all three landing in one large change. "v0.7" itself is no longer implemented directly — see v0.70/v0.71/v0.72.

---

### v0.70 — Zainab Cinematic Checkpoint — STATUS: COMPLETE

Goal:
Add Zainab only, reusing the v0.67 Fatima cinematic encounter pattern exactly.

Implementation note (recorded after completion):
Zainab enters from offscreen right (walk-in, like the original Fatima pattern); triggers at score 35; obstacle speed becomes 255 after Continue. See "Current Status" above.

Trigger:

* Score 35.

Story:
Zainab gives قلب الشجاعة (the heart of courage).

Dialogue:

زينب:
"علي، دير بالك… الطريق بدأ يصعب."

علي:
"ما نخافش يا زينب."

زينب:
"خذ قلب الشجاعة."

System reward text:
"حصلت على قلب الشجاعة."

Expected behavior:

* Stop spawning obstacles.
* Clear active obstacles safely.
* Zainab enters from offscreen right (or appears) using the same safe encounter flow as Fatima in v0.67.
* Zainab is not harmful and not an obstacle.
* Pause gameplay.
* Show the same cinematic fake-zoom presentation (dim overlay + focused dialogue panel) as v0.67 — no real `Camera2D` zoom.
* Dialogue advances step by step with Space/click/tap.
* Reward appears.
* Continue starts a 3-2-1 countdown.
* Gameplay resumes.
* Update last checkpoint to `ZAINAB`.
* Retry from last checkpoint resumes from score 35 at the correct post-Zainab difficulty (the next obstacle-speed step after the post-Fatima value).
* Restart from beginning still resets to score 0 and base difficulty.

Required asset:

* `res://assets/characters/zainab/zainab_helper.png`

Fallback:

* If missing, use a warm placeholder showing "زينب ❤️" or similar (same fallback pattern as Fatima's "فاطمة ⭐").

Do not add:

* Jomana
* father ending
* real shield effect (flavor text only — real effect is v0.9)
* audio
* animation
* coins
* parallax
* real `Camera2D` zoom
* new obstacle types

See `docs/STORY_PLAN.md` ("Cinematic Checkpoint Presentation") for the reused flow, and `docs/ANIMATION_AND_ASSET_PLAN.md` for the asset-request workflow once this asset is actually needed.

---

### v0.70P — Cinematic Encounter Polish Template — STATUS: COMPLETE (verified in code)

Goal:
Improve the reusable cinematic checkpoint presentation so every character encounter feels warm, polished, and story-driven, before reusing it for Jomana and Father.

Important design correction (implemented):
Fatima no longer appears to walk, run, crawl, or move like an active character — she is a newborn baby. She is revealed already in place near the curb/road edge with a gentle fade-in (`modulate:a` tween, 0.45s), not a walk-in. Father (added in v0.72) uses the same reveal-in-place treatment, since an adult shouldn't sprint down the road like a world object either. Zainab and Jomana still enter actively from offscreen right (the original walk-in pattern) — acceptable per "Zainab and Jomana may enter more actively if needed."

Cinematic panel design — implemented:

* Checkpoint card is now a rounded-corner `Panel` with a `StyleBoxFlat`: warm dark-brown/golden palette, thin golden border, soft drop shadow — not a plain flat-color rectangle.
* A `SpeakerName` label badge shows above the current line, naming whoever is currently speaking (فاطمة / زينب / جمانة / الأب / علي / النظام).
* One dialogue line at a time, large readable Arabic text, "Space / Click / Tap — التالي" hint — unchanged from v0.67.
* Panel fade-in + card scale-in tween on open (`_play_checkpoint_panel_intro`).
* Reward step pop: the reward label scales in with an ease-out "back" tween (`_pop_reward_text`) when it appears.
* Continue button appears only on the final step, exactly as before; for the Father ending specifically, its label changes to "العب من جديد / Play Again" (see v0.72).
* Countdown number pop: each digit change (3 → 2 → 1) scales in with the same ease-out tween (`_pop_countdown_number`).

Not implemented from the original wish list (optional, low-risk future refinements, not blocking anything):

* No fade-out transition before gameplay resumes — the countdown overlay currently hides instantly.
* No "gentle portrait bob" idle motion on the helper portrait.
* No separate glow effect around the reward text beyond the scale-pop tween.

Do not add (still correctly out of scope):

* real `Camera2D` zoom
* real character animation
* audio
* parallax
* coins
* new obstacles
* real reward effects
* new characters
* new assets

Clarification: this is UI/presentation polish only for the existing fake-zoom cinematic checkpoint system — it is not v0.8 (Ali animation) and not v1.15 (real camera zoom).

---

### v0.71 — Jomana Cinematic Checkpoint — STATUS: COMPLETE

Goal:
Add Jomana only, after Zainab (v0.70) is implemented and tested. Do not implement until v0.70 is tested.

Implementation note (recorded after completion):
Jomana enters from offscreen right (walk-in, same as Zainab); triggers at score 60; obstacle speed becomes 270 after Continue; reuses the v0.70P polished panel (rounded card, speaker badge, pop tweens). See "Current Status" above.

Trigger:

* Score 60.

Story:
Jomana gives مفتاح الطريق (the key to the path).

Dialogue:

جمانة:
"قريب وصلت يا علي… لكن لازم تختار الطريق الصح."

علي:
"وريني الطريق يا جمانة."

جمانة:
"خذ مفتاح الطريق… وكمل لبابا."

System reward text:
"حصلت على مفتاح الطريق."

Expected behavior:

* Same cinematic encounter pattern as v0.67/v0.70 (stop spawning, clear obstacles safely, Jomana enters from offscreen right with no harmful collision, pause, fake-zoom presentation, step-by-step dialogue, reward, 3-2-1 countdown, resume).
* Update last checkpoint to `JOMANA`.
* Retry from last checkpoint resumes from score 60 at the correct post-Jomana difficulty.
* Restart from beginning still resets to score 0 and base difficulty.

Required asset:

* `res://assets/characters/jomana/jomana_helper.png`

Fallback:

* If missing, use a warm placeholder (same pattern as Fatima/Zainab).

Do not add:

* father ending
* real boost effect (flavor text only — real effect is v0.9)
* audio
* animation
* coins
* parallax
* real `Camera2D` zoom
* new obstacle types

---

### v0.72 — Father Ending / Level Complete — STATUS: COMPLETE

Goal:
Add the father ending only after Fatima (v0.67), Zainab (v0.70), and Jomana (v0.71) are all stable. Do not implement until v0.71 is tested.

Implementation note (recorded after completion):
Father is revealed in place (fade-in, like Fatima, per v0.70P) rather than walking in; triggers at score 90; the final Continue button reads "العب من جديد / Play Again" and calls a full restart instead of a countdown-resume. See "Current Status" above.

Trigger:

* Score 90.

Dialogue:

الأب:
"أحسنت يا علي… وصلت وجبت النور معاك."

علي:
"النور طلع فينا نحنا."

الأب:
"بالضبط… البيت ينور بأهله."

Final success text:
"اكتملت الرحلة — المنطرحة، زليتن."

Expected behavior:

* Same cinematic encounter pattern, but this is a win state distinct from Game Over rather than a mid-run checkpoint — gameplay does not resume afterward, it shows the final success panel.
* No countdown/resume needed at the end, since this is the level-complete state, not a continuing checkpoint.

Required asset:

* `res://assets/characters/father/father_ending.png`

Father size rule:

* Father should appear about 2x Ali's height in the ending panel, since he is an adult (see `docs/STORY_PLAN.md` Section 6).

Fallback:

* If missing, use a warm placeholder so the ending still works.

Do not add:

* beach/desert level
* Android export
* real `Camera2D` zoom
* animation
* audio

See `docs/STORY_PLAN.md` for full dialogue and story details.

---

### v0.73 — In-World Cinematic Encounter Template + Story Architecture Cleanup — STATUS: PARTIALLY COMPLETE

Implementation note (recorded 2026-06-28, verified via in-game screenshots and `scripts/main.gd`/`scenes/Main.tscn` review):

* The in-world presentation is implemented: the dialogue panel now appears as a small panel positioned near whichever character is currently speaking (near Fatima for her line, near Ali for his reply), with the Al-Mantarah street fully visible underneath — not a large centered popup card.
* The story/checkpoint code duplication cleanup is **not yet done** — `scripts/main.gd` still hand-writes a separate dialogue constant and `match active_encounter:` branch per character (e.g. `ZAINAB_LINE`, `JOMANA_LINE`, `FATHER_LINE` are still individual constants, not entries in a shared config table). The scalable config-field list below remains the target design; it has not been migrated to yet.
* This is why v0.74 (below) includes a "Story Code Modularization" part — it is the natural next step on the unfinished half of v0.73, not a new idea unrelated to v0.73.

Goal:
Replace the large popup-card feeling (from v0.67/v0.70P) with a cleaner in-world cinematic encounter style — Ali and the character facing each other in the street, dialogue as a small bubble/panel near the speaker — and organize the story/checkpoint code so future characters and chapters are easy to add without duplicating a large code block per character.

Design direction:

* Do not use a large black/brown popup as the main storytelling method.
* Keep the same Al-Mantarah street visible at all times — no full-screen takeover.
* Characters appear in the world, facing or near each other.
* Dialogue appears as a clear speech bubble or small elegant dialogue panel above/near the current speaker — not a centered card covering most of the screen.
* A subtle dim overlay is allowed, but it must not hide the whole world.
* The player should feel that Ali reached the character, not that a menu appeared.

Fatima-specific correction (carried over from v0.70P, reinforced here):

* Fatima is a newborn baby — she must not walk, run, crawl, slide, or appear self-propelled like an active character.
* She is seated safely on the curb/sidewalk edge, not in the road lane.
* She may enter the screen only as a world object moving with the environment/scroll (e.g. offscreen right, already seated, the world scrolling her into view), or be revealed seated with a gentle fade-in after the road clears.
* The encounter should feel like Ali reached Fatima, not that Fatima approached him.

Preferred scene composition (Fatima example):

1. Ali stands slightly left of center.
2. Fatima sits to his right, on the curb.
3. Fatima offers the glowing star.
4. Fatima's line appears first, above/near Fatima: "آآ… علي! ⭐"
5. On Space/click/tap, Ali's line appears above/near Ali: "فاطمة… لقيتك. كنت عارف إن نورك قريب يا فاطمة."
6. On the next input, reward text appears in a small golden reward banner: "حصلت على نجمة الفرح."
7. Continue starts the 3-2-1 countdown.
8. Ali returns to his runner position.
9. Gameplay resumes.

Scalable architecture rules:

Future story encounters should be data-driven/configuration-driven as much as possible, instead of hand-writing a near-duplicate block of code per character (which is the current pattern across the four `match active_encounter:` blocks in `scripts/main.gd`). Recommended config fields per character:

* `character_id`
* `trigger_score`
* `asset_path`
* `placeholder_text`
* `speaker_name`
* `dialogue_steps`
* `reward_text`
* `retry_score`
* `post_checkpoint_speed`
* `encounter_position`
* `character_visual_mode` (e.g. reveal-in-place vs. enter-from-right)
* `checkpoint_state`
* `game_over_line`

Future characters that should reuse the same encounter system: Fatima, Zainab, Jomana, Father ending, and future Part 2 characters.

This does not need to happen as one large refactor — it can be migrated incrementally (e.g. move one character's existing logic into the config table at a time) as long as the end state removes the need to hand-write a near-identical block for every new character.

Do not move these forward yet:

* real `Camera2D` zoom
* full animation system
* audio
* parallax
* coins
* random obstacles
* real reward effects
* sprite sheets

See `docs/STORY_PLAN.md` ("Cinematic Checkpoint Presentation") for the updated presentation preference, and `docs/ANIMATION_AND_ASSET_PLAN.md` for the static-vs-animated character note.

---

### v0.74 — Dialogue Bubble Layout Fix and Story Code Modularization — STATUS: COMPLETE (verified in code)

Implementation note (recorded 2026-06-28, verified via `scripts/main.gd` and the new `scripts/story/encounter_data.gd`):

* Bubble face-avoidance is implemented: `_position_dialogue_bubble_for_speaker()` and `_clamp_bubble_position()` in `scripts/main.gd` position the dialogue card near the current speaker and keep it inside the viewport.
* The story-architecture cleanup is implemented: `scripts/story/encounter_data.gd` now holds a single `ENCOUNTERS` config table (Fatima/Zainab/Jomana/Father), each entry carrying `character_id`, `checkpoint_id`, `trigger_score`, `retry_score`, `post_speed`, `asset_path`, `placeholder_text`, `speaker_name`, `visual_height`, `story_position_role`, `arrival_mode`, `dialogue_steps`, `reward_text`, `game_over_line` — this is the config-field migration v0.73 described but didn't finish.
* `scripts/main.gd` is still large (886 lines as of this check) — it now reads encounter data from the shared table instead of hand-written per-character constants, but it remains a single large coordinator file. This is exactly why v0.74B (below) documents splitting it further for safe parallel AI work.

Goal:
Improve the in-world dialogue bubble placement introduced by v0.73 (the dialogue panel sometimes covers Ali's or the helper character's face), and lightly modularize the growing story/encounter logic in `scripts/main.gd` so future characters and chapters are easier and safer to add.

Current status this builds on: v0.73's in-world presentation works, but the panel is positioned without an explicit face-avoidance rule, and the per-character config cleanup described in v0.73 was never migrated to — `scripts/main.gd` still has one hand-written dialogue block per character.

#### Part 1 — Dialogue Bubble Layout Rules

* Dialogue bubbles must never cover Ali's face.
* Dialogue bubbles must never cover the helper character's face.
* For Ali speaking:
  * The bubble should appear above Ali if there is space.
  * Otherwise, to the side, or as a top subtitle.
* For the helper speaking:
  * The bubble should appear above/near the helper but offset upward enough to clear the face.
* For reward/system text:
  * Use a centered golden reward banner that does not cover either character's face.
* The bubble must have a max width and wrap Arabic text cleanly (no overflow past the bubble edge).
* The bubble must stay fully inside the viewport at all times.
* A small pointer/tail is allowed only if it stays simple (a single triangle, not a complex shape).
* Arabic text stays large and readable — no shrinking text to force a fit.

#### Part 2 — Code Organization (Light Modularization)

`scripts/main.gd` is growing and is becoming harder to safely extend with each new character. The fix is a light modularization, not a rewrite.

Preferred future structure:

* `scripts/main.gd` — keeps owning game lifecycle, input, score, spawn, and overall scene state.
* `scripts/story/encounter_data.gd` — holds the per-character data only: character IDs, trigger scores, dialogue lines, reward text, asset paths, placeholder text, post-checkpoint speeds, retry values, and Game Over lines. This is the natural home for the config-field list from v0.73 (`character_id`, `trigger_score`, `asset_path`, `placeholder_text`, `speaker_name`, `dialogue_steps`, `reward_text`, `retry_score`, `post_checkpoint_speed`, `encounter_position`, `character_visual_mode`, `checkpoint_state`, `game_over_line`).
* `scripts/story/encounter_presenter.gd` (optional, later) — would handle bubble placement and presentation logic once the data is centralized. Inline helper functions in `main.gd` are an acceptable first step instead of a new file.
* `scripts/story/checkpoint_state.gd` (optional, later only if actually needed) — would track last-reached checkpoint state separately if `main.gd` still feels crowded after the above.

Important:

* Keep the first refactor small — moving the existing per-character data into one shared table is enough for this milestone. Do not introduce a full dialogue framework or complex `Resource` hierarchy yet.
* Do not break current gameplay or change any dialogue/trigger/speed/retry behavior — this is a structure change, not a behavior change.
* The goal is to make future additions (a fifth character, a new chapter) easier to add without copy-pasting a whole match-block — not to rewrite the project.

#### Part 3 — Parallel AI Workflow

Documented so multiple AI agents/tools can work on this project without colliding:

* Codex modifies scripts and scenes (the actual Godot implementation).
* Sonnet (this assistant) modifies docs and asset folder maps — documentation/planning only, unless explicitly asked to write code directly.
* Antigravity (or any other review-oriented agent) reviews only after Codex has finished a step — not concurrently.
* Two coding agents must never edit `scripts/main.gd` or `scenes/Main.tscn` at the same time — these are the two files every story milestone touches, so concurrent edits risk silently overwriting each other's work.

#### Part 4 — Future Animation Reminder

Added as a forward-looking note only (see `docs/ANIMATION_AND_ASSET_PLAN.md` for the actual note) — when Ali's animation prompts are written later (v0.8), include:

* Running dust under feet.
* A small jump dust puff.
* A small landing dust puff.
* A grounded shadow under Ali.

These are visual polish for later (v0.8/v1.2), not needed now and not part of v0.74's scope.

Do not add in this step:

* real `Camera2D` zoom
* full animation system
* audio
* parallax
* coins
* random obstacles
* real reward effects
* sprite sheets
* a complex dialogue/resource framework

See `docs/STORY_PLAN.md` ("Cinematic Checkpoint Presentation") for the face-avoidance presentation note, and `docs/FUTURE_FEATURE_BACKLOG.md` for the backlog entries.

---

### v0.74B — Main Split for Parallel AI Work — STATUS: COMPLETE (verified in code)

Implementation note (recorded 2026-06-28, verified via the new module files): all four target modules from the original plan now exist —

* `scripts/story/encounter_controller.gd` (110 lines) — the story-encounter runtime flow.
* `scripts/gameplay/obstacle_spawner.gd` (123 lines) — obstacle spawning/clearing/stopping/resuming.
* `scripts/gameplay/difficulty_manager.gd` (25 lines) — speed/difficulty-chapter lookups, reading from `encounter_data.gd`.
* `scripts/ui/dialogue_bubble_helper.gd` (48 lines) — bubble placement/clamping (the part the original v0.74B plan called optional turned out worth its own file too).

`scripts/main.gd` shrank from ~886 lines to 709 lines as a result — it's thinner, though not yet a pure thin coordinator; further trimming is optional future cleanup, not blocking anything. The split is enough that gameplay work (obstacle variety, below) and story/UI work now live in genuinely separate files, which is what unblocks parallel AI assignment per the rules below.

Goal:
Reduce `scripts/main.gd`'s responsibility so future tasks can be assigned to separate AI coders safely, without two agents needing to touch the same file at the same time.

#### Target modules (now implemented — see implementation note above)

* `scripts/main.gd` — becomes a high-level coordinator only: wires up the other modules, owns top-level game state (current scene state, score), and delegates the rest.
* `scripts/story/encounter_data.gd` — already exists (v0.74): story/checkpoint data only.
* `scripts/story/encounter_controller.gd` — the story-encounter *runtime* flow (triggering an encounter, stepping through dialogue, resolving retry/restart), extracted from `main.gd` only if it can be done safely without behavior changes.
* `scripts/gameplay/obstacle_spawner.gd` — obstacle spawning, clearing, stopping, and resuming, separated from story and UI concerns.
* `scripts/gameplay/difficulty_manager.gd` — the simple speed/difficulty values (`POST_*_SPEED` constants and the active-speed state), if useful as its own small module.
* `scripts/ui/dialogue_bubble_helper.gd` — optional, later: the bubble-placement/clamping logic (`_position_dialogue_bubble_for_speaker`, `_clamp_bubble_position`) currently in `main.gd`, if it's ever worth its own file.

None of these modules are required to exist yet — this section documents the target shape so future Codex tasks can extract one module at a time, each as its own small, independently testable step.

#### Parallel AI rules

1. Never let two coding agents modify `scripts/main.gd` at the same time.
2. Never let two coding agents modify `scenes/Main.tscn` at the same time.
3. Sonnet (this assistant) can work on docs while Codex works on code — different files, no conflict.
4. Antigravity (or any other review-oriented agent) should review only after Codex finishes a step, not concurrently with it.
5. Codex A can work on gameplay (e.g. obstacle variety) only once the gameplay modules above actually exist as separate files — until then, gameplay changes still live in `main.gd` and must follow rule 1.
6. Codex B can work on audio/UI only if it touches files separate from whatever Codex A is editing at the same time.
7. Always run F6/manual test after each code task, regardless of which agent did it.
8. Commit/push after stable milestones, so each agent's safe checkpoint is recoverable.

#### Future parallel-work examples (after v0.74B)

* Coder A: v0.75 obstacle variety — touching `obstacle_spawner.gd` and obstacle data only, once that module exists.
* Coder B: v0.95 audio docs or an audio manager — not touching story code.
* Sonnet: asset-generation prompts and asset-folder docs.
* Antigravity: review, after Codex's step is complete.

Do not add in this step:

* real `Camera2D` zoom
* full animation system
* audio
* parallax
* coins
* random obstacles
* real reward effects
* sprite sheets

See `docs/FUTURE_FEATURE_BACKLOG.md` for the corresponding backlog entries.

---

### v0.75 — Obstacle Variety and Difficulty Chapters — STATUS: COMPLETE (verified in code)

Implementation note (recorded 2026-06-28, verified via `scripts/gameplay/obstacle_spawner.gd` and `scripts/gameplay/difficulty_manager.gd`):

* Random, weighted obstacle selection is implemented in `ObstacleSpawner._choose_weighted_definition()`, picking among the obstacle types unlocked for the current difficulty chapter.
* Difficulty chapter is derived from the current obstacle speed via `DifficultyManager.get_chapter_for_speed()` (chapter 1 below post-Fatima speed, 2 from post-Fatima, 3 from post-Zainab, 4 from post-Jomana onward).
* Final chapter/obstacle mapping: **block** — chapter 1+ (weight 8), **barrier** — chapter 2+ (weight 4), **cone** — chapter 3+ (weight 3), **crate** — chapter 4+ (weight 3), **sign** — chapter 4+ (weight 2). Lower weight = rarer; block stays the most common throughout.
* Correction to the original plan below: **real obstacle PNGs now exist on disk** for `obstacle_barrier.png`, `obstacle_cone.png`, `obstacle_crate.png`, and `obstacle_sign.png` (alongside the pre-existing `obstacle_block.png.png`) — these are no longer placeholder-only. The placeholder-color fallback (`placeholder_color` per definition in `obstacle_spawner.gd`) remains in the code for safety, but isn't currently being shown for obstacles since the real art is present.
* All obstacles still spawn offscreen right (`SPAWN_X = VIEW_W + SPAWN_MARGIN`), per v0.61, unchanged.

Goal:
Make gameplay change slightly after each story checkpoint.

Obstacle variety comes after the checkpoint/story systems (v0.61, v0.65, v0.66, v0.67, v0.70, v0.71, v0.72) are stable — not before.

Scope (as originally planned — see implementation note above for what actually shipped):

* Chapter 1: simple concrete obstacles (current baseline, before Fatima).
* Chapter 2, after Fatima: slightly faster obstacles.
* Chapter 3, after Zainab: one new safe obstacle type.
* Chapter 4, after Jomana: final challenge before father.

Obstacle variety (implemented):

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

See `docs/ANIMATION_AND_ASSET_PLAN.md` for the obstacle asset paths.

---

### v0.8A — Ali Animation Slot System

Goal:
Build the technical scaffolding for pose switching before any real pose art exists — a slot system that can hold a path per pose (idle, run, jump, fall, land, slide, hurt, victory) and swap `Sprite2D` textures accordingly, falling back to `ali_idle.png` for any pose whose file is missing.

This is infrastructure only, not the art itself. It comes before v0.8 (Ali Basic Animation) so the pose-swapping mechanism can be tested and trusted with placeholder/fallback behavior before any real pose PNGs are requested from the owner.

Scope:

* Add named pose-path constants/slots (one per pose listed in `docs/ANIMATION_AND_ASSET_PLAN.md` Section 1: idle, run, jump, fall, land, slide, hurt, victory), each pointing at its future `res://assets/characters/ali/ali_*.png` path.
* Add a single swap function that loads a pose's texture if it exists, and falls back to the current `ali_idle.png` if it doesn't — reusing the existing `ASSET_UTILS` fallback pattern, not a new loader.
* Do not wire this up to actual game-state transitions yet (jump start, landing, etc.) unless that can be done safely without changing collision or feel — the priority is the slot/fallback mechanism existing and being provably safe, not full behavioral animation.
* Do not require any new PNG to exist — the game must keep working exactly as today (Ali shown via `ali_idle.png`) if no other pose file is ever added.

Do not add in this step:

* real pose artwork (separate later step, once the owner generates it — see asset-request workflow)
* `AnimatedSprite2D` / `SpriteFrames` (that's Stage 2 in `docs/ANIMATION_AND_ASSET_PLAN.md`, after Stage 1 separate-PNG poses are proven)
* sprite sheets (Stage 3, later still)
* audio, parallax, coins, real Camera2D zoom

See `docs/ANIMATION_AND_ASSET_PLAN.md` ("Ali Animation Plan (Staged)") for the full staged plan this slot system is Stage 1 of, and `docs/ASSET_REQUIREMENTS.md` for the exact future pose paths.

---

### v0.8B — Ali 4-Frame Run Cycle — STATUS: COMPLETE

Goal:
Make Ali's running feel alive by cycling through four transparent PNG run frames, on top of the v0.8A pose-slot system.

Implemented (recorded 2026-06-28, per Codex report, verified against `scripts/player_visual.gd`):

* `ali_run_1.png`, `ali_run_2.png`, `ali_run_3.png`, `ali_run_4.png` — four cached run-frame textures, cycled while the requested pose is `run` and Ali is grounded/running.
* Missing-frame skip: any individual frame that doesn't exist is skipped without breaking the cycle.
* Fallback order: available `ali_run_1..4` frames → `ali_run.png` (single-pose fallback) → `ali_idle.png` → blue placeholder.
* Cycle runs at `10 FPS` (`RUN_ANIMATION_FPS`), with frame textures and their 100px-height/feet-aligned transforms cached — no per-frame disk loading.
* Leaving the `run` pose (jump, fall, land, hurt, idle, story states) resets the run timer and frame index back to frame 1.
* Compatibility note: one currently-imported frame is named `ali_run1.png` (no underscore before `1`) instead of the preferred `ali_run_1.png`. The loader checks this exact compatibility path only for frame 1 if `ali_run_1.png` is missing — this is a fallback, not the preferred naming convention. See `docs/ASSET_REQUIREMENTS.md` for the rename guidance.
* Physics/collision unchanged: gravity `1050`, jump velocity `-440`, max fall speed `700`, jump buffer `0.12s`, collision `32x48`.
* Story, obstacles, difficulty, UI, audio, camera, and parallax were not touched.

Acceptance criteria:

* Reported as passing by Codex; **owner should still verify with F6** — see "Owner Testing Checklist (v0.8B)" below.

Owner follow-up (not part of v0.8B's own scope, found while verifying this update against the asset folder): real PNG art now also exists on disk for every other pose slot from v0.8A (`ali_jump.png`, `ali_fall.png`, `ali_land.png`, `ali_slide.png`, `ali_hurt.png`, `ali_victory.png`) — each a distinct image, not a copy of `ali_idle.png`. These are not part of the v0.8B report and are not being marked as a completed milestone here (only v0.8B is marked complete in this update), but the owner should be aware the assets already exist — see `docs/ASSET_FOLDER_MAP.md` for the updated per-pose status.

See `docs/ANIMATION_AND_ASSET_PLAN.md` ("Ali Animation Plan (Staged)") for the updated Stage 1 status, and `docs/ASSET_REQUIREMENTS.md` for the run-frame asset requirements.

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

See `docs/ANIMATION_AND_ASSET_PLAN.md` for the full staged plan (separate PNG poses first, `AnimatedSprite2D`/`SpriteFrames` later, full sprite sheet only if clearly beneficial).

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

See `docs/ANIMATION_AND_ASSET_PLAN.md` for required asset paths and image-generation prompt requirements for all four helper portraits.

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

### v0.95B — Audio Asset Improvement: Better Hit Sound + Music/Ambience Sourcing

Goal:
Improve on v0.95A's placeholder SFX based on direct owner listening feedback, and continue sourcing the still-missing music/ambience loops. Planning only — not implemented yet.

Owner feedback (2026-06-28, after testing the v0.95A audio integration):

* **Collision/hit sound** currently feels like a weak "tick." Wants something more dramatic and emotionally clear, while staying strictly child-friendly: no violence, no explosion, no blood/injury feeling — soft but meaningful. Suggested future asset: `res://assets/audio/gameplay/hit_soft_impact.wav`, or replace `hit.wav` directly only if a better licensed CC0 candidate is found. Do not replace it with anything until a real candidate exists.
* **Background music**: none exists yet. Wants a soft adventure/suspense loop — warm, light adventure, slight suspense, not horror, not battle music, not sad, family-friendly, low volume, fitting Al-Mantarah/Zliten's atmosphere. Target path: `res://assets/audio/music/main_theme_soft_loop.ogg`.
* **Ambience** (optional, desired later): soft city ambience, birds, light wind. Paths: `res://assets/audio/ambience/city_soft_loop.ogg`, `res://assets/audio/ambience/birds_soft_loop.ogg`, `res://assets/audio/ambience/wind_soft_loop.ogg`.

Current status: music and all three ambience loops remain **BLOCKED_BY_AUDIO_ASSET** — no safe licensed candidate has been sourced yet for any of the four loop files. Do not fabricate or download blindly; only integrate once a real CC0/CC-BY (with documented attribution) file exists and is logged in `docs/AUDIO_CREDITS.md`, per `docs/ASSET_SOURCING_PLAN.md`.

Scope when unblocked:

* Source or replace the hit sound with a softer, more deliberate "impact" feel — not a click/tick, not violent.
* Source the main theme loop and the three ambience loops.
* Wire them in following the same `scripts/audio/audio_manager.gd` pattern already used for v0.95A's SFX (load once, fallback-safe, one player per sound/loop, missing files logged once and skipped without crashing).

Do not add:

* Voice acting.
* Dynamic mixer UI.
* Procedural audio generation.

See `docs/AUDIO_DESIGN_PLAN.md` for the updated tone/licensing guidance and `docs/AUTOPILOT_PROGRESS.md` (the "v0.95A" entry) for exactly what's already integrated and working today.

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

* Moving clouds, drifting slowly.
* Subtle parallax (background layers scroll slower than the road/gameplay layer, for visual depth).
* Dust particles at Ali's feet while running (`CPUParticles2D`).
* A small particle puff on jump and on landing.
* Birds occasionally crossing the sky (visual — separate from the audio "birds ambience loop" in `docs/AUDIO_DESIGN_PLAN.md` v0.97).
* Moving palm leaves later, via a simple sway shader.
* Optional: a soft drop shadow under Ali and under obstacles, anchored to the ground, so they read as grounded rather than floating.

Do not affect gameplay collision. Add one effect at a time and keep performance light — this is visual polish layered on top of an already-stable gameplay loop, not a rewrite.

---

### v1.25A-P — Menu Motion Smoothing and Title Polish

Goal:
Refine the hero-menu redesign (implemented on the autopilot branch as "v1.25A") based on direct owner feedback after testing. Planning only — not implemented yet.

Owner feedback (2026-06-28):

* The "ابدأ اللعب" Play button's pulse currently feels jerky/rattling. Wants: a slower pulse, a more subtle scale difference, sine/ease-in-out only (already used, just needs gentler numbers), no sharp grow/shrink, no distracting motion.
* The Arabic title "علي رنر" is not strong enough and is too narrowly tied to Ali alone — wants a more exciting, adventure-style name that can support future playable characters (Jomana, Zainab) without implying the game is only about Ali.

Candidate titles considered: مغامرة نور البيت / نور البيت / أبطال نور البيت / مغامرة علي والأخوات / رحلة نور البيت / أبطال المنطرحة / مغامرة البطل علي.

**Recommendation to document (not yet implemented):** adopt a general story-friendly title rather than a literal "Ali Runner" translation, since future levels/characters may expand beyond Ali. First title to try: **"مغامرة نور البيت"**, with subtitle **"رحلة في المنطرحة — زليتن"**. Keep "Ali Runner" as the internal/project/repository name only — it does not need to be the in-game title shown to the player.

Scope when implemented:

* Retune the existing pulse constants in `scripts/main.gd` (currently `PLAY_BUTTON_PULSE_TIME = 0.9s`, `PLAY_BUTTON_PULSE_SCALE = 1.05`) toward a slower duration and smaller scale delta, keeping the existing `Tween.TRANS_SINE`/`EASE_IN_OUT`.
* Replace the `TitleLabel`/`SubtitleLabel` text in `scenes/Main.tscn` with the new title/subtitle once the owner confirms the final choice.

Do not add:

* A new animation system — stays within the existing Tween-based approach already implemented.
* A title that invents new story meaning — must stay consistent with the documented "نور البيت" (light of home) framing already in `docs/STORY_PLAN.md`.

See `docs/AUTOPILOT_PROGRESS.md` (the "v1.2A-FIX + v1.25A" entry) for the current pulse/title implementation being refined here.

---

### v1.25B — Cinematic Intro Story Presentation

Goal:
Replace the current flat, centered-text "الراوي" narration intro with an in-world cinematic dialogue scene, matching the same "Visual Novel Lite / In-world Cinematic Dialogue" style already used for the checkpoint encounters (v0.73). Planning only — not implemented yet.

Owner feedback (2026-06-28): the current intro (static centered text, generic "الراوي" narrator label) doesn't feel alive or cinematic. Wants the opening to reuse the same in-world presentation already proven for Fatima/Zainab/Jomana/Father:

* Use the same Al-Mantarah street background already on screen.
* Show **Ali and Father** facing each other (not a narrator caption).
* Dialogue appears as a speech bubble near whichever character is speaking.
* The speaking character gets a slight scale/focus emphasis; the non-speaking character dims/shrinks slightly.
* Warm dim overlay, soft focus — no real `Camera2D` zoom (stays a "fake zoom," consistent with the rest of the project; real zoom remains deferred to v1.15).
* Advance via التالي / تخطي (Next/Skip) — already exists in the current intro and should be kept.
* Use only the existing documented intro lines (الراوي → الأب → علي, see `docs/STORY_PLAN.md` Section 9) — do not invent new Arabic story meaning. How the narrator line is re-attributed in-world (e.g. spoken as Father's opening line, or shown as plain on-screen text without a visible "narrator" character) is an implementation-time decision, not decided here.

**Important correction (explicit owner instruction):** do **not** add a new character named "Hamza" unless explicitly instructed later. The cinematic intro must use **Ali and Father** by default — no new characters.

Style reference — "Visual Novel Lite / In-world Cinematic Dialogue":

* Speaker badge (reuse the existing `SpeakerName` pattern from the checkpoint panel).
* Speech bubble near the speaker (reuse `scripts/ui/dialogue_bubble_helper.gd`'s placement logic).
* Character focus zoom via sprite scale tween (reuse the v1.25A hero-zoom pattern), not a real Camera2D.
* Smooth fade/slide transitions via `Tween` only.
* Optional typewriter text reveal — later, not part of this step.
* No full video trailer, no complex cutscene framework, no `Camera2D` unless isolated and proven safe (stays deferred to v1.15).

See `docs/STORY_PLAN.md` ("Cinematic Checkpoint Presentation") for the existing in-world pattern this intro redesign should reuse, and the "v1.1 — Cinematic Intro Prototype" section above for the current implementation being replaced.

---

### v1.3 — Character Animation Expansion

Goal:
Later animation expansion for Ali and family.

Do not start this before static story (v1.0) works.

---

### v1.35 — Complete Roadmap Refresh and Level 2 Planning

Goal:
After v1.25B (or after a full Level 1 "Gold" review, whichever comes first), reconcile this roadmap with everything actually implemented on the `autopilot/v1-level1-...` branch — v1.2A (background motion + the foreground opacity fix), v1.25A (hero menu redesign), v0.95A (SFX integration), and any v1.25A-P/v1.25B/v0.95B work — since these were tracked in `docs/AUTOPILOT_PROGRESS.md` during fast iteration but were never folded back into this master roadmap's "Current Status" section. Planning only — not implemented yet, and explicitly should not happen before v1.25B (or a Level 1 Gold review) is reached.

Scope:

* Update "Current Status" (top of this document) to reflect the real, current implemented state, not the stale earlier-milestone status currently shown there.
* Reconcile every autopilot-branch milestone (v1.2A, v1.25A, v1.25A-P, v1.25B, v0.95A, v0.95B) into this document's numbered milestone list with accurate STATUS tags.
* Begin Level 2 / Part 2 planning (see `docs/FUTURE_FEATURE_BACKLOG.md` "Dream Backlog" — Jomana at the beach, Zainab in a garden/new road, Fatima as a baby bonus character) only after Level 1 is confirmed stable end-to-end.

Do not implement yet.

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
* Collectibles should come after checkpoints (v0.61/v0.65/v0.66/v0.67/v0.70/v0.71/v0.72) are stable.

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
* Ali's cartoon style and the more photorealistic background buildings could be visually unified later with consistent directional lighting (e.g. a warm sunset-toned gradient) and grounded drop shadows under Ali/obstacles — see v1.2 scope above. This is cosmetic polish, not a gameplay change, and should wait until v1.2.

---

## Next Recommended Task

**v0.6 through v0.72 are all complete**, including the v0.70P cinematic polish template. Implementation details are recorded under "Current Status" above. The former single "v0.7" milestone (split into v0.70/v0.71/v0.72) is fully implemented — Fatima, Zainab, Jomana, and the Father ending all work end to end with placeholders.

**v0.73 through v0.8B are all now complete**, verified in code:

* The in-world presentation (v0.73) works — panel near the speaking character, street always visible.
* The dialogue bubble (v0.74) keeps itself clear of both faces and inside the viewport, and the per-character story data lives in `scripts/story/encounter_data.gd`.
* The main-split (v0.74B) is done — `scripts/story/encounter_controller.gd`, `scripts/gameplay/obstacle_spawner.gd`, `scripts/gameplay/difficulty_manager.gd`, and `scripts/ui/dialogue_bubble_helper.gd` all exist as separate files.
* Obstacle variety and difficulty chapters (v0.75) are done — weighted random obstacle selection across 5 types, all with real PNG art.
* The Ali pose-slot system (v0.8A) and the 4-frame run cycle (v0.8B) are done — see the v0.8B milestone section above for the full detail.

**Owner follow-up needed (not a Codex task):** `assets/characters/fatima/fatima_helper.png` already exists and is being actively used by the game, but it's a real photo rather than the documented transparent/cropped game asset (see `docs/ASSET_FOLDER_MAP.md`). Worth reviewing before relying on it as "done" — either keep it intentionally, or replace it later using the ready prompt in `docs/ANIMATION_AND_ASSET_PLAN.md` ("Fatima Helper Portrait — Ready Prompt").

**Next missing assets to flag (per the asset-request workflow):**

1. `res://assets/characters/fatima/fatima_helper.png` — exists, but is a real photo, not the documented transparent game asset (see note above) — owner decision needed, not blocking.
2. `res://assets/characters/zainab/zainab_helper.png` — missing, falls back to placeholder.
3. `res://assets/characters/jomana/jomana_helper.png` — missing, falls back to placeholder.
4. `res://assets/characters/father/father_ending.png` — missing, falls back to placeholder.
5. `res://assets/characters/ali/ali_run_1.png` — preferred name still missing; the currently-loaded frame 1 asset is named `ali_run1.png` (compatibility path, no underscore) — rename when convenient, not blocking.

None of these block further work — each falls back to its placeholder/compatibility path. No images are generated as part of documentation tasks.

### Next Recommended Steps (after v0.8B)

Only v0.8B is marked complete above — none of the following are implemented yet.

1. **v0.8B-R — Review and test Ali 4-frame run cycle.** Human test in Godot with F6: confirm run speed feels correct, confirm 10 FPS isn't too fast or too slow, confirm feet don't slide or jump between frames, confirm checkpoint-cinematic scaling still resets Ali's visual correctly afterward. See "Owner Testing Checklist (v0.8B)" below.
2. **v0.8C — Ali Pose Polish Pass.** Review idle/jump/fall/land/hurt poses for fit and feel. Do not add new systems — keep the same pose-slot architecture from v0.8A/v0.8B; improve art or pose-switching timing only if actually needed.
3. **v0.8D — Game Over Impact Moment.** Collision feedback polish: stop the obstacle spawner immediately on hit, switch Ali to the hurt pose, add a small child-friendly impact moment (dust puff / gentle stumble / tiny bounce-back / obstacle wobble / short hit-stop), then show Game Over after a brief delay (~0.35-0.6s). See `docs/FUTURE_FEATURE_BACKLOG.md` for the full design notes and rules.
4. **v0.85 — Static Helper Asset Quality Pass.** Fatima/Zainab/Jomana/Father transparent game portraits. Keep static for now — no helper animation yet.
5. **v0.9 — Real Reward Effects.** Fatima star bonus, Zainab shield, Jomana safer spacing/boost — one effect at a time.
6. **v0.95 — Audio Foundations.** Button click, jump, land, hit, checkpoint, reward — keep volume gentle, per `docs/AUDIO_DESIGN_PLAN.md`.
7. **v1.0 — Level 1 Complete.** Clean start-to-finish flow; all assets acceptable; all checkpoints and the Father ending stable.
8. **v1.1 — Opening Story Scene / Cinematic Intro.** Simple in-game story intro with Arabic narration text; static background and text progression first — no complex cutscene system, no trailer video.

The next implementation task is:

**v0.8B-R — Review and test Ali 4-frame run cycle**

This is a human/owner testing step, not a new Codex coding task — see the checklist immediately below. Once it passes, the next coding task is **v0.8C — Ali Pose Polish Pass**.

### Owner Testing Checklist (v0.8B)

* Start screen Ali appears correctly.
* Press Play.
* Ali cycles through four run frames while grounded.
* Jump switches away from the run animation.
* Landing returns to frame 1 cleanly.
* Hitting an obstacle switches to hurt/Game Over.
* Restart resets correctly.
* Retry from checkpoint works.
* Story checkpoint cinematic still scales Ali correctly.
* No visible feet floating.
* No visual size jumps between frames.

### Known Issue / Future Improvement Note

The current Game Over moment still needs polish: obstacles may continue visually after the hit, and the collision moment itself lacks strong feedback. This is planned for **v0.8D — Game Over Impact Moment** (see "Next Recommended Steps" above and `docs/FUTURE_FEATURE_BACKLOG.md`) and should not be mixed into v0.8B's scope.

---

## Final Instruction for AI Agents

This is a working project. Treat it carefully.

Make small changes.
Test often.
Preserve the current playable state.
