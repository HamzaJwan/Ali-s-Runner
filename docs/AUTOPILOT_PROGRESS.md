# Autopilot Progress Log — Ali Runner v1.0 Level 1 Completion

Mission: advance Ali Runner toward a polished Level 1 v1.0 release autonomously, in small verified milestones, on an isolated branch.

Branch: `autopilot/v1-level1-20260628-1842`
Backup folder: `D:\GODOT\test1\autopilot_backups\20260628-1842\` (git status/diff snapshot + pre-edit copies of docs/*.md)
Godot executable located at: `C:\Users\Administrator\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe`

---

## Preflight — 2026-06-28 18:42

* Repo: `https://github.com/HamzaJwan/Ali-s-Runner.git`, branch `main` was checked out, last pushed commit `df2e9e7` ("Add GitHub upload log for v0.61 snapshot"). All work since v0.65 (story checkpoints through v0.8B run cycle) was uncommitted/untracked on `main` before this mission.
* Created branch `autopilot/v1-level1-20260628-1842` from `main` (no destructive operations).
* Backed up git status/diff and pre-edit docs copies outside the repo.
* Godot 4.7 console executable confirmed available for headless validation.

Status: COMPLETE

---

## v0.8B-R — Automated Review of Ali 4-Frame Run Cycle — 2026-06-28 18:50

Status: COMPLETE

Findings (from baseline headless boot log, no code changed):

* `player_visual.gd` caches all 4 run frame textures and their layout transforms (`_texture_layouts` dictionary), no per-frame disk loading after `_ready()`.
* Frames load as: `ali_run_1.png` missing → falls back to compatibility path `ali_run1.png` (loaded, 441x588) → frames 2/3/4 load from their preferred underscore paths. All 4 frames present via the fallback chain; cycle runs at 10.0 FPS exactly as documented.
* `show_pose()` resets `run_anim_time`/`run_frame_index` whenever the requested pose isn't `RUN`, confirming the "leaving run resets timer/index" behavior.
* Other pose slots (jump/fall/land/slide/hurt/victory) unaffected — each loads its own real asset independently of the run-frame cache.
* 100px `VISUAL_HEIGHT` and feet alignment (`FEET_Y`) constants unchanged; layout recalculated per-texture and cached.
* Fallback chain (frames → `ali_run.png` → `ali_idle.png` → placeholder) confirmed structurally correct by code reading; not exercised end-to-end since real frames are present.

No bug found. No code changes made for this milestone. Visual quality/feel: HUMAN_TEST_REQUIRED (see owner checklist at end of this log).

---

## v0.8C — Ali Pose Fit and Timing Polish — 2026-06-28 18:52

Status: COMPLETE (reviewed, no changes required)

Findings:

* `RUN_ANIMATION_FPS = 10.0` (`player_visual.gd`) — already within the requested 8-12 range and the preferred default; left unchanged.
* `LAND_POSE_TIME = 0.10` (`player.gd`) — brief, and `_update_visual_pose()` correctly clears `_was_airborne`/resets the land timer on touchdown, returning to `RUN` cleanly once the land window expires.
* `kill()` sets the `HURT` pose and `_alive = false`; since `_gameplay_active` is also set false and nothing else calls `show_pose()` until `reset_player()`, the hurt pose correctly persists through the entire Game Over UI.
* Story-scaling reset verified by code reading: `_prepare_player_for_encounter()` resizes `player_story_sprite` to `ALI_STORY_VISUAL_HEIGHT` (160px) for the cinematic; `_finish_encounter_and_countdown()` calls `player.reset_player()` → `show_pose(IDLE, force_refresh=true)`, which recomputes the texture layout against the normal `VISUAL_HEIGHT` (100px) constant — so gameplay scale is correctly restored after every checkpoint/ending.

Conclusion: current values already satisfy the polish guidance. Making speculative tweaks with no identified problem would add risk without benefit, so no code was changed for this milestone, per the "low-risk improvements only" rule.

---

## v0.8D — Game Over Impact Moment — 2026-06-28 19:05

Status: COMPLETE

Files changed: `scripts/main.gd`

Implemented:

* New constants: `GAME_OVER_IMPACT_DELAY := 0.45`, `IMPACT_BOUNCE_DISTANCE := 10.0`, `IMPACT_BOUNCE_OUT_TIME := 0.08`, `IMPACT_BOUNCE_BACK_TIME := 0.18`.
* `_end_run()` now: sets `game_over = true` immediately (blocks jump input and re-entrant hits right away, unchanged guard behavior) → stops the spawner → **calls `obstacle_spawner.clear_obstacles()`** so already-spawned obstacles don't keep drifting across the screen during the delay → `player.kill()` (hurt pose, as before) → plays a new `_play_impact_bounce()` tween (Ali nudges back `10px` over `0.08s`, eases back over `0.18s` — a gentle stumble/bounce-back, no new assets) → `await get_tree().create_timer(0.45).timeout` → then shows the existing Game Over UI exactly as before.
* No dust-puff/particle node was added (kept the impact moment to the bounce-tween only, per "implement only if safe" — particles were judged unnecessary extra surface area for this pass).
* No obstacle wobble was added — the obstacle that caused the hit already frees itself in `obstacle.gd`'s own `_on_body_entered()` before `main.gd` ever sees the signal, so there's nothing left to wobble without changing `obstacle.gd` (left untouched, per the "avoid touching obstacle.gd unless necessary" guidance carried over from earlier project rules).
* No Engine.time_scale hit-stop was added (optional in the spec; judged higher-risk for a global engine value with no clear benefit over the bounce+delay already implemented).

Validation:

* `git diff --stat` → only `scripts/main.gd` touched.
* Headless boot (`--headless --path . --quit`) → exit code 0, no parser/runtime errors.
* Temporary smoke test (`tmp_autopilot_smoke_test.gd`, deleted after running) simulated: boot → Play → simulate obstacle hit → asserted `game_over` becomes `true` immediately while `game_over_label`/`restart_button` stay **invisible** until the delay elapses → asserted both become visible with the correct Game Over message after the delay → Restart → asserted score/speed/game_over reset to `0`/`225.0`/`false`. **All assertions passed, no FAIL lines.**

Immutable benchmark check (re-verified via grep after the edit):

* Gravity `1050.0`, Jump velocity `-440.0`, Max fall speed `700.0`, Jump buffer `0.12` — unchanged (`player.gd`).
* Road surface `510.0`, collision half-height `24.0` — unchanged (`main.gd`).
* Spawn interval `2.25`, spawn margin `140.0` — unchanged (`obstacle_spawner.gd`).
* Base/post-checkpoint speeds `225/240/255/270` — unchanged (`difficulty_manager.gd`).
* Checkpoint trigger scores `15/35/60/90` — unchanged (`encounter_data.gd`).

Remaining risk: the bounce tween moves `player.global_position.x` directly while `_alive = false` (so `_physics_process` is a no-op and won't fight the tween) — verified safe by code reading and the smoke test, but the *visual feel* of the bounce distance/timing is HUMAN_TEST_REQUIRED.

---

## v0.85 — Static Helper Asset Quality Integration — 2026-06-28 19:10

Status: COMPLETE (reviewed, no code changes — generating/replacing assets is forbidden)

Findings:

* Zainab/Jomana/Father missing-asset fallback already works cleanly (confirmed in the v0.9 smoke tests below and the original baseline boot log) — placeholders display, no crash.
* Fatima's existing `fatima_helper.png` (the real photo, previously flagged `HUMAN_ART_REVIEW_REQUIRED`) is presented via `TextureRect.stretch_mode = STRETCH_KEEP_ASPECT_CENTERED` in the panel and via visible-bounds-based fit/align in the in-world sprite — both already avoid stretching/distortion artifacts despite the asset being an opaque photo rather than the documented transparent game asset.
* No further safe code-level improvement identified. Per the mission's asset rules, the photo itself is not replaced, deleted, or regenerated — it remains `HUMAN_ART_REVIEW_REQUIRED`, same status as before this mission.

---

## v0.9A — Fatima Reward Effect — 2026-06-28 19:18

Status: COMPLETE

Files changed: `scripts/main.gd`, `scripts/story/encounter_data.gd`

Implemented: a one-time `+5` score bonus ("نجمة الفرح" joy bonus) applied exactly once when Fatima's reward dialogue step is shown live (`_apply_fatima_reward_bonus()`), guarded by `fatima_reward_applied` (reset each `_begin_run()` based on `checkpoint >= FATIMA`, so it won't re-apply on a retry-from-Fatima-or-later). Fatima's `retry_score` in `encounter_data.gd` was bumped from `15` to `15 + FATIMA_REWARD_BONUS (5) = 20`, so a future retry from the Fatima checkpoint starts already reflecting the bonus, consistent with "retry restores the post-Fatima reward state."

No new dialogue/text was invented — only the existing documented reward line is shown; the bonus is a silent score addition.

Validation: headless boot clean (exit 0, no errors). Smoke test: played to score 15 (triggers Fatima) → advanced dialogue to the reward step → asserted `score == 20` and `fatima_reward_applied == true` → asserted `encounter_data.get_checkpoint(FATIMA)["retry_score"] == 20` → pressed Continue → asserted `last_reached_checkpoint == FATIMA`, `current_obstacle_speed == 240.0` → asserted `_get_retry_state_config(FATIMA) == {score: 20, checkpoint: FATIMA, speed: 240.0}`. All assertions passed, no FAIL lines. Temp test file deleted after running.

Immutable benchmarks re-verified unchanged (gravity/jump/fall/buffer, road surface, spawn constants, base/post-checkpoint speeds, all four trigger scores 15/35/60/90).

---

## v0.9B — Zainab Reward Effect — 2026-06-28 19:30

Status: COMPLETE

Files changed: `scripts/main.gd`

Implemented: a one-hit shield ("قلب الشجاعة" courage), not an HP/lives counter. `zainab_shield_active` is granted live when Zainab's reward step is shown, and re-granted on every `_begin_run()` where `checkpoint >= ZAINAB` (carried forward through Jomana/Father retries too, consistent with the story's "he carries part of their gift even after a fall" framing in `docs/STORY_PLAN.md`). On the next obstacle hit while the shield is active, `_on_obstacle_hit()` intercepts before `_end_run()`: consumes the shield (one-time), stops/clears obstacles, plays a brief blue shield-flash tween on Ali (`_play_shield_flash()`, no new assets), and reuses the existing `_start_countdown()` 3-2-1 → resume flow instead of ending the run. A second hit with no shield remaining falls through to the normal v0.8D Game Over impact flow, unchanged.

Validation: headless boot clean. Smoke test: simulated `_begin_run(35, ZAINAB, 255.0)` → asserted shield active → first `_on_obstacle_hit()` → asserted `game_over == false`, shield now `false`, countdown running → waited out the countdown → asserted gameplay resumed (`game_over == false`, `started == true`) → second `_on_obstacle_hit()` (no shield left) → asserted normal Game Over triggers with the correct post-Zainab message. All assertions passed.

Immutable benchmarks re-verified unchanged.

---

## v0.9C — Jomana Reward Effect — 2026-06-28 19:42

Status: COMPLETE

Files changed: `scripts/main.gd`, `scripts/gameplay/obstacle_spawner.gd`

Implemented: a temporary safer-spacing window ("مفتاح الطريق" guidance), not a permanent difficulty change. `ObstacleSpawner` gained `safety_window_spawns_remaining` plus `grant_safety_window()`/`clear_safety_window()`. While the window is active, each spawn temporarily caps the obstacle pool to chapter ≤3 (suppressing the chapter-4-only `crate`/`sign` types) and decrements the counter; once it reaches zero, the full chapter pool (including chapter 4) resumes automatically — no permanent state change, no edit to `min_chapter` data, no change to `SPAWN_INTERVAL` or any speed constant. The window (`JOMANA_SAFETY_WINDOW_SPAWNS = 4`) is granted live after the post-checkpoint countdown finishes (`jomana_safety_window_pending` flag set in `_apply_checkpoint_state()`, consumed in `_finish_countdown()` — granting it only after `start_spawning()` runs, so it isn't lost), and re-granted fresh on every `_begin_run()` where `checkpoint >= JOMANA`.

Validation: headless boot clean. Smoke test: simulated `_begin_run(60, JOMANA, 270.0)` → asserted a fresh 4-spawn safety window and `current_obstacle_speed == 270.0` (unchanged) → manually drove 4 spawns → asserted the window reached `0` → drove 5 more spawns → asserted the spawner still produced exactly 5 obstacles with the window expired (no errors, pool returns to normal) → re-verified `SPAWN_INTERVAL == 2.25` and `BASE_SPEED == 225.0` unchanged. All assertions passed.

Immutable benchmarks re-verified unchanged across all of v0.9A/B/C (final grep pass after all three): gravity `1050.0`, jump `-440.0`, fall `700.0`, buffer `0.12`, spawn interval `2.25`, base/post-checkpoint speeds `225/240/255/270`, all four trigger scores `15/35/60/90`.

---

## v0.95 / v0.96 / v0.97 — Audio Foundations / Dialogue Blip / Ambience — 2026-06-28 19:44

Status: BLOCKED_BY_ASSET (all three)

Findings: `assets/audio/` contains only the README scaffolding from v0.68 — no `.wav`/`.ogg`/`.mp3` files exist anywhere in the project. `docs/AUDIO_CREDITS.md` does not exist (required before any audio file may be used, per `docs/AUDIO_DESIGN_PLAN.md`/`docs/ASSET_SOURCING_PLAN.md`).

Decision: per the mission rules (no downloading, no generating/fabricating audio), none of v0.95/v0.96/v0.97 can be implemented right now. The mission allows an *optional* lightweight audio-helper scaffold with silence fallback even without real files, but no such helper was added — there is no concrete integration point to wire it to yet (no `AudioStreamPlayer` nodes exist in `Main.tscn`, and adding speculative, never-exercised plumbing for a system with zero real assets would add surface area without a way to validate it). Continuing to v1.0 stabilization, which is independent of audio.

Required owner action to unblock: generate or source licensed audio per `docs/ASSET_SOURCING_PLAN.md` (CC0 preferred), place files at the paths listed in `docs/AUDIO_DESIGN_PLAN.md`, and create `docs/AUDIO_CREDITS.md` entries for each.

---

## v1.0 — Level 1 Stabilization and Full Verification — 2026-06-28 20:05

Status: COMPLETE (code/logic verified headlessly; visual/audio feel remains HUMAN_TEST_REQUIRED)

Files changed: none (verification-only milestone; no bugs found that required a fix).

Full end-to-end headless smoke test built and run, simulating a complete playthrough in one continuous session:

1. Start screen visible before Play; Play transitions to `started=true`, `score=0`, `speed=225.0`.
2. Jump call leaves the floor / sets upward velocity.
3. Fatima checkpoint at score 15: cinematic opens (waited for `checkpoint_cinematic_active`, not a fixed delay — robust to both reveal-in-place and walk-in arrival timing), dialogue advances through all steps, joy bonus applied (`score == 20`), Continue → countdown → `last_reached_checkpoint == FATIMA`, `speed == 240.0`.
4. Zainab checkpoint at score 35 (15 more passes): cinematic opens, dialogue completes, Continue → `last_reached_checkpoint == ZAINAB`, `speed == 255.0`, shield granted. A simulated hit immediately after is absorbed by the shield (`game_over` stays `false`, shield consumed), countdown runs, gameplay resumes normally.
5. Jomana checkpoint at score 60 (25 more passes): cinematic opens, dialogue completes, Continue → `last_reached_checkpoint == JOMANA`, `speed == 270.0`, safer-spacing window granted (4 spawns).
6. Father ending at score 90 (30 more passes): cinematic opens, dialogue completes, Continue → game restarts from beginning (`score == 0`, `speed == 225.0`), matching the documented win-state behavior (no countdown/resume, since the run ends here).
7. Independent retry/restart check from a fresh post-Fatima state (`_begin_run(15, FATIMA, 240.0)`, no carried shield): a hit triggers the real Game Over path (impact bounce → `GAME_OVER_IMPACT_DELAY` → Game Over UI visible with the correct story-aware message → Retry button visible) → Retry resumes at `score == 20` (Fatima's joy bonus baked into `retry_score`), `speed == 240.0` → Restart resets to `score == 0`, `speed == 225.0`, `game_over == false`.

**Result: 0 failed assertions** across the entire flow (one early test-harness bug was found and fixed along the way — see note below — it was in the *test*, not the game).

Note on a false alarm during this milestone: the first version of this end-to-end test used a fixed delay before driving dialogue for every checkpoint. Zainab and Jomana use the "enter from offscreen" arrival mode (slower than Fatima/Father's "reveal in place" fade), so the fixed delay was too short and the test advanced dialogue before the real cinematic UI had opened — something a real player physically cannot do, since `_input()` only accepts dialogue-advance events while `checkpoint_cinematic_active` is true. This produced several false failures (wrong checkpoint/speed values) that looked like game bugs at first. Fixed by polling for `checkpoint_cinematic_active` instead of guessing a fixed delay; after the fix, the full flow passed cleanly. No game code was changed because of this — it was purely a test-harness timing bug. Documented here so it isn't mistaken for a real regression later.

Quality gate checklist (code-verified items only; see "Human Test Checklist" in the final report for what still needs an in-engine pass):

* [x] Start screen loads, Play works.
* [x] Jump call produces upward motion.
* [x] Score increments and triggers checkpoints at the correct thresholds (15/35/60/90), unchanged.
* [x] Fatima/Zainab/Jomana/Father encounters all trigger, run dialogue, and apply the correct post-checkpoint state.
* [x] Dialogue advances correctly once the cinematic is open (matches real input gating).
* [x] Countdown completes and resumes gameplay (or restarts, for Father).
* [x] Reward effects: Fatima score bonus, Zainab one-hit shield (absorb then expire), Jomana temporary safer-spacing window — all verified.
* [x] Game Over impact delay + correct story-aware message + Retry/Restart buttons.
* [x] Retry from checkpoint resumes at the correct score/speed (including the Fatima bonus baked into retry state).
* [x] Restart from beginning resets all state (score, speed, game_over, shield, safety window).
* [x] No parser/runtime errors at any point (clean headless boot before and after every milestone in this log).
* [x] No immutable constant changed (re-verified by grep after every code milestone in this log).
* [ ] Visual feel (run-cycle FPS, bounce distance, shield flash, Arabic text rendering) — HUMAN_TEST_REQUIRED, cannot be verified headlessly.
* [ ] Audio — BLOCKED_BY_ASSET (no licensed audio files exist yet).

---

## v1.1 — Opening Story Scene / Cinematic Intro — 2026-06-28 20:25

Status: COMPLETE

Files changed: `scripts/main.gd`, `scenes/Main.tscn`

Implemented a simple static in-game opening scene using only the existing documented intro text (no new dialogue invented):

* الراوي: "في شارع المنطرحة بزليتن… بدأ نور البيت يضعف."
* الأب: "يا علي… لو تبي ترجع النور، اجمع فرحة فاطمة، وشجاعة زينب، وحكمة جمانة."
* علي: "حاضر يا بابا… بنوصل للنهاية."

Design choice (deliberately simpler than the checkpoint dialogue system, to minimize risk): rather than reusing the global click-anywhere `_input()` dialogue-advance pattern (which has a deliberate `is_final_step()` bypass so the Continue button can receive its own click — replicating that correctly for an always-available Skip button would have meant either touching the shared input path or adding fragile click-ownership logic), the intro uses two plain `Button` nodes with their own `pressed` signals: **النالي/Next** (advances one line, becomes **ابدأ/Start** on the final line) and **تخطي/Skip** (always available, finishes immediately). This avoids touching `_input()`/`_unhandled_input()` at all — zero risk to the existing checkpoint dialogue input handling.

* New scene nodes under `UI/IntroOverlay` (`scenes/Main.tscn`): `Dim` (background), `IntroSpeaker`, `IntroLine`, `NextButton`, `SkipButton`.
* New state: `intro_shown` (session-level — once true, never shows again), `intro_active`, `intro_step_index`.
* `_on_play_pressed()`: first Play press shows the intro instead of starting gameplay; once `intro_shown` is `true` (intro finished or skipped), subsequent Play presses go straight to `_start_run()` as before. **Restart and Retry are completely unaffected** — they call `_start_run()`/`_begin_run()` directly and never pass through `_on_play_pressed()`, so the intro never re-appears mid-game or on restart, matching "must not break Start/Play" and avoiding repeat-narration annoyance.

Validation: headless boot clean. Two smoke tests:

1. Intro-specific: first Play → intro active, gameplay not started, start screen hidden → Next x2 walks through all 3 lines (button label correctly changes to "ابدأ / Start" on the last line) → final Next finishes the intro → gameplay starts at the normal baseline (`score=0`, `speed=225.0`) → Restart does **not** re-show the intro → a second fresh instance confirmed the Skip button also finishes the intro and starts gameplay correctly. All assertions passed.
2. Full regression: re-ran the entire v1.0 end-to-end chain (Play → Skip intro → Fatima → Zainab shield-absorb → Jomana safety window → Father restart) — **0 failures**, confirming the intro addition didn't disturb any existing checkpoint/reward/retry behavior.

Immutable benchmarks re-verified unchanged (gravity/jump/fall/buffer, all four trigger scores 15/35/60/90).

Remaining risk: `Dim`/overlay layering and Arabic text readability against the existing UI theme is HUMAN_TEST_REQUIRED (cannot be judged headlessly).

---

## v1.15 / v1.2 / v1.3 / v1.4 / v1.5 — 2026-06-28 20:30

Status: NOT ATTEMPTED THIS SESSION (deliberate stop, not a crash/blocker)

* **v1.15 (Camera2D focus moments):** the project's own docs (`docs/STORY_PLAN.md`, `docs/FUTURE_FEATURE_BACKLOG.md`) have repeatedly deferred real `Camera2D` zoom across many prior milestones specifically because of fixed-viewport-layout risk, and the "fake zoom" (dim overlay + focused dialogue) it would improve on is already implemented and just got two more layers built on top of it (v0.9 rewards, v1.1 intro). Attempting a real camera change now, at the end of an already-large session, was judged higher-risk-for-benefit than stopping here with a clean, fully-tested checkpoint. Not blocked by missing tools — a judgment call to stop scope here.
* **v1.2/v1.3 (visual motion polish / animation expansion):** not attempted, same reasoning — lower priority than locking in a verified v1.0+v1.1 state.
* **v1.4 (Web export):** checked — `%APPDATA%\Godot\export_templates\` exists but is **empty** (no version subfolder), and no `export_presets.cfg` exists in the project. **BLOCKED_BY_EXPORT_TEMPLATES.**
* **v1.5 (Android preparation):** checked — `ANDROID_HOME`/`ANDROID_SDK_ROOT` are unset. **BLOCKED_BY_SDK.** Per the mission rules, no SDK/template installation was attempted (out of scope — that's an environment-setup action, not a Godot coding task).

---

## FINAL REPORT — 2026-06-28 20:32

**1. Branch:** `autopilot/v1-level1-20260628-1842`
**2. Latest commit:** `1b0f174` ("autopilot: v1.1 opening story scene / cinematic intro")
**3. Push status:** all 5 commits pushed to `origin/autopilot/v1-level1-20260628-1842`; branch is even with origin (no destructive operations, `main` untouched, no force-push).
**4. Highest milestone reached:** v1.1 — Opening Story Scene / Cinematic Intro (complete and regression-tested).

**5. Completed milestones:**
* Preflight safety (branch, backup, snapshot commit, push).
* v0.8B-R (automated review, no defects found).
* v0.8C (reviewed, no changes needed — values already within guidance).
* v0.8D (Game Over Impact Moment — spawner stop+clear, hurt pose, bounce-back tween, 0.45s delay before Game Over UI).
* v0.85 (reviewed — existing fallback/scaling already solid; asset quality itself remains owner's call, untouched).
* v0.9A (Fatima +5 score bonus, baked into retry state).
* v0.9B (Zainab one-hit shield, absorbs one hit then expires, carried through later checkpoints).
* v0.9C (Jomana temporary 4-spawn safer-spacing window, chapter-4 obstacles suppressed temporarily).
* v1.0 (full end-to-end stabilization pass — 0 failed assertions across the entire Start→Fatima→Zainab→Jomana→Father→Retry→Restart flow).
* v1.1 (static 3-line Arabic intro with Next/Skip, shown once per session before first Play).

**6. Partial milestones:** none — every attempted milestone reached a clean COMPLETE state with passing validation.

**7. Blocked milestones and why:**
* v0.95 / v0.96 / v0.97 (audio) — **BLOCKED_BY_ASSET**: no audio files exist anywhere in `assets/audio/`, no `docs/AUDIO_CREDITS.md`. Cannot implement without downloading/fabricating audio, which is forbidden.
* v1.4 (Web export) — **BLOCKED_BY_EXPORT_TEMPLATES**: none installed.
* v1.5 (Android) — **BLOCKED_BY_SDK**: no Android SDK configured.
* v1.15/v1.2/v1.3 — not blocked, but deliberately not attempted this session (see judgment-call note above) to end on a verified, low-risk checkpoint rather than open new camera/animation-system risk late in a long session.

**8. Files changed (cumulative, this mission only):** `scripts/main.gd`, `scripts/gameplay/obstacle_spawner.gd`, `scripts/story/encounter_data.gd`, `scenes/Main.tscn`, `docs/AUTOPILOT_PROGRESS.md`. No other scripts/scenes/assets/`project.godot` were touched. (All temporary `tmp_autopilot_smoke_test.gd` files were deleted after each use, per the mission's cleanup rule.)

**9. Validation commands and results:** every milestone was validated with `--headless --path . --quit` (always exit 0, zero parser/runtime errors) plus a milestone-specific `-s tmp_autopilot_smoke_test.gd` scripted run driving real gameplay function calls and asserting outcomes. One false alarm occurred (a test-harness timing bug during the v1.0 comprehensive test, documented above) and was fixed in the test, not the game — full details logged in the v1.0 section above for future reference so it isn't mistaken for a regression.

**10. Immutable benchmark results:** re-checked by `grep` after every single code-changing milestone — gravity `1050.0`, jump velocity `-440.0`, max fall speed `700.0`, jump buffer `0.12`, road surface `510.0`, collision half-height `24.0`, spawn interval `2.25`, spawn margin `140.0`, base/post-checkpoint speeds `225/240/255/270`, all four checkpoint trigger scores `15/35/60/90`. **None were ever changed.**

**11. Human test checklist for the owner:**
* Open `res://scenes/Main.tscn`, press F6.
* Confirm the new intro (3 Arabic lines) appears once on first Play, with working Next/Skip buttons; confirm it does NOT reappear on Restart.
* Test jump (tap/click/Space).
* Reach Fatima (score 15) — confirm the joy bonus feels right (score jumps to 20).
* Reach Zainab (35) — deliberately hit an obstacle once: confirm the shield-flash + brief pause + resume (no Game Over) feels good, not confusing.
* Hit a second obstacle after the shield is used: confirm the new impact bounce + brief pause before Game Over feels right (not too fast/slow — currently 0.45s).
* Reach Jomana (60): obstacles should feel slightly easier for a few seconds (no crates/signs) right after.
* Reach Father (90): confirm "Play Again" restarts cleanly.
* Test Retry from Last Checkpoint and Restart from Beginning from a Game Over screen.
* Confirm Arabic text renders right-to-left and is readable throughout (intro, dialogue, Game Over messages).
* Audio: none present yet — silence is expected and correct for now.

**12. Known risks:**
* All new visual/feel tuning (bounce distance, shield flash color/duration, intro overlay layering, run-cycle FPS) was verified functionally correct headlessly but never seen rendered — genuine HUMAN_TEST_REQUIRED items, not assumptions of success.
* `fatima_helper.png` is still a real photo, not the documented transparent asset — unchanged, still owner's call (see `docs/ASSET_FOLDER_MAP.md`).
* Zainab/Jomana/Father helper portraits are still missing (placeholders shown) — unchanged, owner needs to generate/provide them.

**13. Exact next manual action for the owner:**
1. Open the project in Godot, press F6, and run through the Human Test Checklist above.
2. If everything feels right, merge `autopilot/v1-level1-20260628-1842` into `main` (or open the PR link GitHub printed when the branch was first pushed) and push to `main` — this autopilot session never touched `main` directly, by design.
3. When ready to unblock audio, provide licensed CC0/CC-BY audio files per `docs/ASSET_SOURCING_PLAN.md` and `docs/AUDIO_DESIGN_PLAN.md`, with `docs/AUDIO_CREDITS.md` entries, to enable v0.95/96/97.
4. When ready for web export, install Godot 4.7 export templates (Editor → Manage Export Templates) to unblock v1.4.

---

## v1.2A — Background Motion / Lightweight Parallax — 2026-06-28 (continued session)

Status: COMPLETE

Files changed: `scripts/main.gd`, new `scripts/visual/background_motion.gd`.

Helper script added (Option A): `BackgroundMotion` (`RefCounted`, instantiated once in `main.gd` exactly like `encounter_controller`/other helpers — not a tree node, no scene wiring needed beyond the existing `@onready` sprite refs). `add_layer(sprite, speed_factor)` skips and logs once if the sprite has no texture (no crash); otherwise it duplicates the sprite (same texture/scale/centered/modulate/z_index) and places the duplicate exactly one viewport-width to the right in **global** coordinates — using `global_position` rather than local `position` makes the wrap math correct regardless of each sprite's parent offset (`BG` at world origin for buildings/foreground vs. `Ground` at world `(576, 545)` for the ground strip — confirmed by reading `_apply_scenery_layer`/`_apply_ground_texture` before writing this). `update(delta, obstacle_speed)` moves both sprites in a pair left by `obstacle_speed * speed_factor * delta`, then recycles whichever one has scrolled fully past world `x=0` by teleporting it to `other.global_position.x + view_width` — a self-correcting two-sprite loop with no extra state to drift out of sync.

Wired into `main.gd`: `_setup_background_motion()` (called once in `_ready()`, after `_apply_optional_backgrounds()` so textures are already fitted) adds three layers — `buildings_sprite` (factor `0.05`), `foreground_sprite` (factor `0.15`), `ground_sprite` (factor `0.65`), per the suggested multipliers. Sky is left fully static (per the design direction — "mostly static"). `_process()` calls `background_motion.update(delta, current_obstacle_speed)` only when `_is_background_motion_active()` is true (`started && !game_over && !checkpoint_cinematic_active && !checkpoint_encounter_started && !countdown_active && !intro_active`) — motion fully stops (not just slows) during intro, checkpoint cinematics, countdown, and Game Over, satisfying "stop or become very slow." No `Camera2D`, no audio, no new image assets, no shaders, no changes to any physics/spawn/checkpoint/dialogue/retry/restart logic.

Validation:

* Headless boot (`--quit`) clean, exit 0. Log confirms all three layers initialized: `[parallax] layer BuildingsSprite ready, speed_factor=0.05`, `ForegroundSprite ... 0.15`, `GroundSprite ... 0.65` (all three background PNGs exist on disk via the `.png.png` fallback path, so this is real exercised motion, not a placeholder no-op).
* Smoke test (deleted after running): confirmed `background_motion.has_layers()` true; confirmed buildings sprite does **not** move during the intro; confirmed ground **and** buildings sprites both move once gameplay starts, with the ground moving roughly 13x faster than buildings over the same 0.5s window (`-74.14px` vs `-5.70px`, matching the `0.65`/`0.05` ratio exactly: `225 * 0.65 * 0.5 ≈ 73.1`, `225 * 0.05 * 0.5 ≈ 5.6`); confirmed motion stops the instant the Fatima cinematic opens; confirmed motion resumes after the post-checkpoint countdown finishes; confirmed motion stops again after Game Over. **0 failed assertions.**
* `git diff --stat`: only `scripts/main.gd` (27 insertions) plus the new `scripts/visual/` file — no unrelated files touched.

Immutable benchmarks re-verified unchanged: gravity `1050.0`, jump `-440.0`, fall `700.0`, buffer `0.12`, road surface `510.0`, collision half-height `24.0`, spawn interval `2.25`, spawn X (`VIEW_W + SPAWN_MARGIN`), base/post-checkpoint speeds `225/240/255/270`, all four trigger scores `15/35/60/90`.

Note found during this milestone (not part of v1.2A's own work, just observed): `docs/AUDIO_CREDITS.md` and `docs/AUDIO_ASSET_SOURCING_REPORT.md` now exist in the working tree (created by a separate agent/process, not this task). The sourcing report states **0 of 15 audio files were safely sourced** — every slot is `BLOCKED_BY_LICENSE_OR_ASSET` because automated sourcing couldn't verify license + emotional tone safely. **Audio remains blocked** — confirmed no real `.wav`/`.ogg` files exist anywhere in `assets/audio/`. This directly answers "v0.95 if Gemini has provided audio": it has not yet.

Known visual risks (HUMAN_VISUAL_REVIEW_REQUIRED, cannot be judged headlessly):

* Seam quality at the loop point for each of the three layers — `bg_buildings.png.png`/`bg_foreground.png.png`/`ground_mantarha.png.png` were not authored as seamlessly tileable textures, so a visible seam/repeat may be noticeable when two copies meet, especially for the ground strip (fastest-moving layer, most likely to show a seam).
* Whether the three speed multipliers (`0.05`/`0.15`/`0.65`) actually read as "subtle" in motion, or whether the ground in particular feels too fast/slow at each difficulty speed (225 through 270).
* Whether the buildings/foreground duplicate sprites' z-ordering still looks correct relative to the player/obstacles once two copies of each exist (each duplicate copies the original's `z_index`, so this should match, but only a visual pass can confirm there's no flicker/overlap artifact).

Owner F6 test checklist (v1.2A):

* Start the game and confirm the street background subtly scrolls while running (ground fastest, foreground a bit slower, buildings barely moving, sky still).
* Watch one full loop cycle of the ground strip — confirm no jarring seam/flash at the wrap point.
* Confirm the background freezes during: the opening intro, every checkpoint dialogue (Fatima/Zainab/Jomana/Father), the countdown, and the Game Over screen.
* Confirm background motion resumes immediately after a countdown finishes or after Restart/Retry.
* Confirm obstacles, Ali, and collision all still feel exactly as before — this task should be invisible to gameplay feel, only the backdrop should look more alive.

Commit: `git add -A && git commit -m "autopilot: v1.2A background motion lightweight parallax" && git push` — see git log for the resulting hash.

---

## UI Arabic Translation Pass (owner request) — 2026-06-28 (continued session)

Status: COMPLETE

Files changed: `scenes/Main.tscn`, `scripts/main.gd`.

Owner reported the Game Over screen still showed English ("Score: 0", "Game Over", "Restart from Beginning") and asked to translate Score/Restart and review the rest of the UI for Arabic. Found and translated every remaining English-only UI string, matching the bilingual button style already used elsewhere in the game (`متابعة / Continue`, `تخطي / Skip`, `التالي / Next`, `العب من جديد / Play Again`) and the RTL label pattern already used on `GameOverMessage` (`text_direction = 3`, `language = "ar"`):

* `InstructionLabel`: "Tap / Click / Space to jump" → "اضغط / انقر / المسافة — للقفز" (+ RTL props).
* `PlayButton`: "Play" → "ابدأ / Play" (bilingual, matching the other buttons' style).
* `ScoreLabel`: "Score: %d" → "النقاط: %d" (scene default text + all 3 runtime assignments in `main.gd`; + RTL props).
* `GameOverLabel`: "Game Over" → "انتهت المحاولة" (softer than a literal "Game Over", matching the documented "try again, not failure" emotional tone from `docs/STORY_PLAN.md` Section 12; + RTL props).
* `RetryButton`: "Retry from Last Checkpoint" → "إعادة المحاولة من آخر نقطة".
* `RestartButton`: "Restart from Beginning" → "إعادة البدء من البداية".

Deliberately left unchanged: `TitleLabel` ("Ali Runner") — treated as the app/brand name rather than translatable UI copy, consistent with the project being referred to as "Ali Runner" throughout every doc, the GitHub repo name, and the branch name. Flagged to the owner in the response rather than silently assumed.

Validation: headless boot clean. Smoke test: confirmed `PlayButton.text == "ابدأ / Play"`; confirmed `ScoreLabel.text` reads `"النقاط: 0"` then `"النقاط: 15"` after 15 obstacle passes; confirmed `GameOverLabel.text == "انتهت المحاولة"` and `RestartButton.text == "إعادة البدء من البداية"` after a Game Over. **0 failed assertions.** Immutable benchmarks re-verified unchanged (gravity/jump/fall, all four trigger scores) — this was a text-only change.

---

## v1.2A-FIX + v1.25A — Foreground Fix, Hero Menu Redesign, Ali Idle Menu Presentation — 2026-06-28 (continued session)

Status: COMPLETE

Files changed: `scenes/Main.tscn`, `scripts/main.gd`.

### Task A — Foreground transparency: root cause and fix

**Diagnosis (before touching anything):** ran a pixel-level alpha analysis on all four background PNGs (`python -c "from PIL import Image..."`):

| Asset | avg alpha | fully opaque | fully transparent |
|---|---|---|---|
| `bg_foreground.png.png` | 48.7/255 | 18.8% | 80.2% |
| `bg_buildings.png.png` | 143.2/255 | 55.9% | 43.0% |
| `bg_sky.png.png` | 255/255 | 100% | 0% |
| `ground_mantarha.png.png` | 217.2/255 | 84.9% | 14.5% |

The foreground asset is mostly empty canvas by design (only ~19% of pixels are the actual wall/detail art — normal for a sparse foreground decoration layer). That alone isn't a bug. Then checked `git log -p -- scripts/main.gd` for the `_apply_scenery_layer(foreground_sprite, ...)` call history — **the `0.82` opacity value has never changed since it was first added**, ruling out a recent regression there. Then read `scripts/visual/background_motion.gd`'s `add_layer()` to confirm the v1.2A duplicate sprite correctly copies `modulate`, `z_index`, and `z_as_relative` from the original (it does) — ruling out a parallax-introduced bug.

**Conclusion:** no code-side bug was introduced by v1.2A. The actual cause is that `foreground_sprite` was the *only* background layer with a deliberate opacity fade (`0.82`) while sky/buildings/ground all render at full `1.0` — so the foreground's already-sparse art looked visibly "weaker"/wrong sitting next to fully-opaque neighbors. **Fix:** changed `_apply_scenery_layer(foreground_sprite, FOREGROUND_TEXTURE_PATH, 0.82)` → `1.0` (one line, `scripts/main.gd`). This is a legitimate code-side fix (an arbitrary stylistic value, not asset corruption), so no `HUMAN_ART_REVIEW_REQUIRED` flag was needed for this part — though the foreground/buildings' overall photographic "haze" look (present since these assets were first added, visible in screenshots from much earlier in this project) is a separate, pre-existing characteristic of the real-photo assets themselves, unrelated to this fix.

### Task B — Ali positioning

* **Gameplay:** Ali was already structurally fixed at a constant X during gameplay (`player.gd`'s `_physics_process` never sets `velocity.x` — he only moves vertically; the world scrolls via obstacles, not Ali). Tuned `PLAYER_START_X` from `140.0` → `220.0` (≈19.1% of `VIEW_W=1152`, inside the requested 18%-22% band; was previously ≈12.2%, below it).
* **Menu/start screen:** Added `_show_menu_hero_presentation()` — repositions Ali to `MENU_ALI_X = 320.0` (≈27.8%, left-center) and resizes him to `MENU_ALI_VISUAL_HEIGHT = 190px` (up from the normal ~100px gameplay height) using the exact same `ASSET_UTILS.fit_sprite_visible_to_height`/`align_sprite_visible_bottom` pattern already used for checkpoint cinematics (`_prepare_player_for_encounter`) — no new positioning mechanism invented. `_leave_menu_to_runner_framing()` (called from both `_on_play_pressed()` and the new `_on_skip_intro_button_pressed()`) calls `player.reset_player(START_PLAYER_POSITION)`, which restores the normal 100px scale via `player_visual.gd`'s own fixed `VISUAL_HEIGHT` constant during its `force_refresh` — so Ali correctly shrinks back to runner size before the intro or gameplay ever shows him, exactly mirroring how checkpoint cinematics already revert afterward.

### Task C — Menu redesign

* Title is now Arabic-first: **"علي رنر"** (52pt), with a smaller English subtitle **"Ali Runner"** beneath it (kept as a subtitle, not removed — gives both languages a place without ambiguity).
* Primary CTA renamed to **"ابدأ اللعب"**, restyled with two new `StyleBoxFlat` resources (golden fill, rounded 14px corners, soft shadow — normal/hover/pressed/focus) reusing the same warm gold/dark-brown palette already established by the checkpoint dialogue card, so the menu now visually matches the rest of the game instead of using default gray Godot buttons.
* Added one secondary button, **"تخطي المقدمة"** (skip the intro entirely, go straight to gameplay) — reuses the existing dark-brown bordered `StyleBoxFlat` (`id=2`, the same one the checkpoint card uses) so no new resource was needed for it.
* **Deliberately skipped** "القصة" (story) and "خروج" (quit) buttons, per the task's own fallback instruction ("if secondary buttons increase scope too much, keep only one strong primary button") — "القصة" would need new summary content/UI I haven't designed, and adding both would start cluttering a screen the task also asked to keep clean. Flagging this trim explicitly rather than silently dropping it.
* Re-spaced the whole column (title → subtitle → instructions → primary button → secondary button) with clearer vertical rhythm than the previous cramped layout.

### Task D — Hero menu presentation (Tweens only, no shaders/Camera2D/AnimationPlayer)

* **Fake zoom/emphasis:** `_play_menu_hero_zoom_in()` — Ali scales in from 85% to 100% of his menu size with a fade-in (`Tween.TRANS_BACK`/`EASE_OUT`, 0.5s) the moment the start screen appears.
* **Idle motion:** `_start_menu_idle_motion()` — a looping (`set_loops()`) gentle scale breathing tween (±4%, 1.2s each way, sine ease) on Ali's sprite while he stands on the menu — a "tiny body bob" via scale rather than a position bob, since scale breathing reads as alive without risking him drifting off his floor alignment.
* **Play button soft pulse:** `_start_play_button_pulse()` — a similar looping ±5% scale pulse on the primary CTA so it visibly invites a tap.
* **Title/UI fade-in:** `_play_menu_intro_fade()` — title, subtitle, instructions, and both buttons fade in with a small staggered delay (0/0.08/0.12/0.18s) for a cleaner reveal instead of everything popping in at once.
* **Critical safety detail:** all of the above are stored in `_menu_idle_tween`/`_play_button_pulse_tween` and explicitly `.kill()`ed by `_stop_menu_idle_motion()` the instant the player leaves the menu (`_leave_menu_to_runner_framing()`). Without this, the looping scale tween would keep fighting `player_visual.gd`'s pose-driven scale during actual gameplay, corrupting Ali's run-cycle visuals — confirmed this is handled correctly via the smoke test (menu tween is non-null and valid while on the menu, then `null` immediately after `_on_play_pressed()`).

### Task E — Intro transition polish (logic untouched)

* `_start_intro()` now fades `intro_overlay.modulate.a` from `0.0` to `1.0` over `0.3s` instead of an instant cut. No change to intro text, step order, or the Next/Skip logic itself — purely the visual entry transition.

### Validation

* Headless boot (`--quit`) clean, exit 0, no parser/runtime errors.
* Pixel-level PIL analysis of all 4 background PNGs (see Task A table above) — diagnostic, not a runtime check, but recorded here for traceability.
* `git log -p` history check on the foreground opacity line — confirmed no prior regression.
* Comprehensive smoke test (deleted after running): confirmed `foreground_sprite.modulate.a == 1.0`; confirmed Ali stands at `MENU_ALI_X` on the start screen and the menu idle tween is running; confirmed title/subtitle/button text match the new Arabic copy; confirmed the title fades in; confirmed Ali returns to `PLAYER_START_X` and the menu tween stops the instant `_on_play_pressed()` fires; confirmed `PLAYER_START_X / VIEW_W` falls inside `0.18-0.22`; confirmed background-motion parallax still moves the ground during gameplay; confirmed a full Fatima-checkpoint regression (trigger → dialogue → continue → speed 240.0) still passes; confirmed Game Over still shows the Arabic label, and Retry/Restart still resume/reset state correctly. **0 failed assertions.**
* `git diff --stat`: only `scenes/Main.tscn` (87 changed lines) and `scripts/main.gd` (130 changed lines) — exactly the allowed files, nothing else touched.

Immutable benchmarks re-verified unchanged: gravity `1050.0`, jump `-440.0`, fall `700.0`, buffer `0.12`, road surface `510.0`, collision half-height `24.0`, spawn interval `2.25`, spawn X, base/post-checkpoint speeds `225/240/255/270`, all four trigger scores `15/35/60/90`.

### Known visual risks (HUMAN_VISUAL_REVIEW_REQUIRED)

* The foreground/buildings' photographic "haze" look is unchanged by this fix and may still read as slightly washed-out to the eye — that's the real-photo asset's inherent lighting, not something further code can correct without replacing the asset (out of scope, not attempted).
* Whether Ali at `190px`/`x=320` on the menu actually reads as "heroic" rather than just "bigger" is a feel judgment only a human can make.
* The golden button restyle's contrast/legibility (dark text on golden fill) should be checked against the bright sky background behind it.
* The menu idle "breathing" scale bob and the play button pulse are both intentionally subtle (±4%/±5%) — confirm they don't read as distracting or buggy-looking (e.g. juddery) at actual frame rate.

### Owner F6 test checklist

* Open the project, confirm the foreground wall/details now look solid, not washed-out, next to the buildings.
* Confirm Ali appears larger and more centered ("hero") on the start screen, gently breathing/bobbing, with the title/subtitle/buttons fading in.
* Confirm the primary "ابدأ اللعب" button has a visible gold style and a subtle pulse.
* Press "تخطي المقدمة" — confirm it skips straight to gameplay with Ali correctly back to normal runner size/position.
* Press "ابدأ اللعب" instead — confirm the intro now fades in smoothly rather than cutting instantly, and Ali is back to normal runner framing during the intro (not still huge).
* Play through to a checkpoint, a Game Over, Retry, and Restart — confirm all still work exactly as before.

Commit: `git add -A && git commit -m "autopilot: v1.2A-fix foreground and v1.25A hero menu redesign" && git push`.

---

## v0.95A — Safe Audio Integration for Existing CC0 SFX Candidates — 2026-06-28 (continued session)

Status: **PARTIAL_COMPLETE** — SFX integrated, human listening review required, music/ambience missing and correctly left disabled.

Files changed: new `scripts/audio/audio_manager.gd`, `scripts/main.gd`, `scripts/player.gd`. `scenes/Main.tscn` was not touched — `AudioStreamPlayer` nodes are created dynamically at runtime (mirroring `scripts/visual/background_motion.gd`'s established pattern of creating nodes in code rather than editing the scene file), so no scene wiring was needed.

### Implementation

`AudioManager` (`RefCounted`, instantiated once in `main.gd` exactly like `encounter_controller`/`background_motion`) holds a `SOUND_PATHS` dictionary (11 entries) and a `VOLUME_DB` dictionary matching the requested levels exactly (UI/checkpoint/reward/victory −8dB, hit/game_over −10dB, jump/land −12dB, dialogue blip −18dB). `setup(parent_node)` runs once in `main.gd`'s `_ready()`: for each sound, it checks `ResourceLoader.exists(path, &"AudioStream")`, loads the stream once, creates one `AudioStreamPlayer` child under `parent_node` (`Main` itself) with the correct `volume_db`, and caches the player in a dictionary — no per-frame loading anywhere. Missing/failed sounds are logged exactly once via a `_missing_logged` guard dictionary and simply skipped (`play_*()` on an unloaded sound is a silent no-op, confirmed safe by the smoke test). Exposed exactly the 11 requested methods: `play_button_click()`, `play_dialogue_blip()`, `play_jump()`, `play_land()`, `play_hit()`, `play_checkpoint()`, `play_reward_star()`, `play_reward_heart()`, `play_reward_key()`, `play_game_over()`, `play_victory()`.

One small addition to `player.gd`: a new `signal landed`, emitted at the exact point `_update_visual_pose()` already detects the airborne→grounded transition (`_was_airborne` clearing). This was the cleanest way to detect "landing" from `main.gd` without duplicating ground-state logic — `main.gd` connects to it once in `_ready()` and calls `audio_manager.play_land()`.

### Audio wiring (where each sound plays)

* **button_click** — Play button, Skip-Intro button, intro Next button, intro Skip button, checkpoint Continue button (all `_on_*_pressed()` handlers).
* **dialogue_blip** — every successful `_advance_encounter_dialogue()` call (i.e. every time the player advances a checkpoint dialogue line) — not on the first line's initial display, only on advance, per the task's literal wording.
* **jump** — every `player.jump()` call site in `_unhandled_input()` (ui_accept / mouse / touch) — fires on the input attempt itself, same as the existing jump-input handling; not gated on whether the jump buffer actually triggered a real jump (kept simple, no change to `player.gd`'s jump logic).
* **land** — via the new `player.landed` signal, the instant Ali's airborne→grounded transition is detected.
* **hit** — in both `_end_run()` (a real Game Over) and `_consume_zainab_shield()` (a hit that gets absorbed by the shield) — both are genuinely a "hit" event; the shield path skips `game_over` audio entirely since the run doesn't end there.
* **game_over** — in `_end_run()`, after the existing `GAME_OVER_IMPACT_DELAY` (0.45s) elapses, right before the Game Over UI becomes visible — so the sound and the visual land together.
* **checkpoint** — in `_open_checkpoint_cinematic()`, the moment any of the four encounters (Fatima/Zainab/Jomana/Father) actually opens its dialogue panel.
* **reward_star** — Fatima's reward dialogue step (alongside the existing `_apply_fatima_reward_bonus()` call).
* **reward_heart** — Zainab's reward dialogue step (alongside `_apply_zainab_shield_grant()`).
* **reward_key** — Jomana's reward dialogue step (new branch added to the same `match`).
* **victory** — Father's reward/final-success dialogue step (new branch, same location).

Explicitly **not** integrated: city/birds/wind ambience loops and the main theme music — confirmed via `docs/AUDIO_CREDITS.md` that all four remain `Missing (No safe CC0 candidate found yet)`. No playback code references them at all (not even disabled/commented-out hooks), so there's nothing that could accidentally try to load them later.

### A real import gap found and fixed (not part of the original task, but blocking it)

The 11 `.wav` files existed on disk but had **no `.import` files yet** — they were dropped into the project by another process but never opened in the Godot editor, so `ResourceLoader.exists(path, &"AudioStream")` returned `false` for all 11 on the first headless boot (logged as "missing" even though the files were physically present). Ran `Godot ... --headless --path . --import` (the dedicated CLI import-and-quit flag) to generate all 11 `.import` files; confirmed via a second headless boot that all 11 sounds then loaded correctly with their assigned `volume_db`. This wasn't a code bug — it's a one-time housekeeping step needed any time new raw assets are dropped into the project outside the editor.

### Validation

* Headless boot clean before and after the fix (exit 0 both times); audio log lines confirm all 11 sounds loaded post-import.
* Smoke test (deleted after running): confirmed exactly 11 sound players exist; **simulated a missing sound** by removing `"jump"` from the manager's internal player dictionary and calling `play_jump()` — confirmed no crash, no error, silent no-op as designed; confirmed gameplay starts normally after skip-intro; confirmed the jump input path executes without error; confirmed a full Fatima-checkpoint regression (reward bonus, speed bump) still passes with the new audio hooks in place; confirmed Game Over still triggers correctly with the new `hit`/`game_over` sound calls inline; confirmed Restart still resets to baseline. **0 failed assertions.**
* `git diff --stat`: only `scripts/main.gd` (28 lines) and `scripts/player.gd` (2 lines) changed, plus the new `scripts/audio/audio_manager.gd` file — `scenes/Main.tscn` untouched.

Immutable benchmarks re-verified unchanged: gravity `1050.0`, jump `-440.0`, fall `700.0`, buffer `0.12`, road surface `510.0`, collision half-height `24.0`, spawn interval `2.25`, spawn X, base/post-checkpoint speeds `225/240/255/270`, all four trigger scores `15/35/60/90`. Story text, reward logic, retry/restart logic, and menu layout were not touched by this task.

### HUMAN_AUDIO_REVIEW_REQUIRED checklist

All 11 sounds are Kenney CC0 placeholders, not yet quality-checked by ear for this specific game's tone:

* Confirm none of the 11 sounds feel jarring, too loud, or too quiet relative to each other at the assigned `volume_db` levels.
* Confirm `dialogue_blip` (−18dB) doesn't get lost under the other sounds or feel mistimed against the Arabic dialogue advancing.
* Confirm `hit`/`game_over` don't feel scary or violent for a child-friendly game (the source pack is generic UI clicks/switches, not impact/violence sounds, but verify in context).
* Confirm `reward_star`/`reward_heart`/`reward_key`/`victory` feel emotionally appropriate for each character's gift, even though they're currently 4 different generic "switch" sounds rather than custom-composed stingers.
* Confirm `jump`/`land` don't feel out of sync with the actual animation timing.
* Confirm `button_click` doesn't feel repetitive when rapidly advancing dialogue (every Next/Continue press triggers it).
* Music/ambience are silent by design — confirm that absence doesn't feel like a bug to a first-time player (it's expected at this stage, not a regression).

---

## v1.36 Planning — Owner Polish Feedback for Audio, Menu, Title, and Cinematic Intro — 2026-06-28 (continued session)

Status: DOCUMENTATION ONLY — no code, scenes, or assets changed.

This entry records owner feedback gathered after testing the build that included the Arabic UI pass, hero menu redesign, v1.2A background motion/parallax, v0.95A SFX integration, the intro scene, and full Level 1 gameplay/rewards/checkpoints. Nothing here was implemented — it was captured as four new planned roadmap milestones.

**Owner feedback captured:**

1. **Hit sound** feels like a weak "tick" — wants more dramatic but still soft/child-friendly (no violence/explosion/blood). Suggested `hit_soft_impact.wav` or a direct `hit.wav` replacement if a better CC0 candidate turns up.
2. **Background music** — none exists; wants warm/light-adventure/slight-suspense (not horror, not battle, not sad), low volume, fitting Al-Mantarah/Zliten. Target: `main_theme_soft_loop.ogg`. Still `BLOCKED_BY_AUDIO_ASSET`.
3. **Ambience** (city/birds/wind) — desired later, optional, still `BLOCKED_BY_AUDIO_ASSET`.
4. **Play button pulse** feels jerky/rattling — wants slower, more subtle, smooth sine ease, no sharp grow/shrink.
5. **Arabic title** "علي رنر" judged too narrow/weak — wants a more adventure-style title that supports future playable sisters (Jomana/Zainab). First title to try: **"مغامرة نور البيت"**, subtitle **"رحلة في المنطرحة — زليتن"**. "Ali Runner" stays as the internal/repo name only.
6. **Opening intro presentation** — current flat centered-text "الراوي" narration should become an in-world cinematic dialogue scene (Ali and Father facing each other, speech bubbles, speaker focus/dim), reusing the same style as the v0.73 checkpoint encounters. **Explicit correction: do not add a new "Hamza" character — Ali and Father only**, unless the owner says otherwise later.
7. **Presentation style reference**: "Visual Novel Lite / In-world Cinematic Dialogue" — speaker badge, speech bubble near speaker, character focus zoom via Tween (not Camera2D), smooth fade/slide, optional typewriter later, no video trailer, no cutscene framework.

**New roadmap milestones added (all PLANNED, none marked complete):**

* `docs/AI_GAME_ROADMAP.md` — **v0.95B** (Audio Asset Improvement: Better Hit Sound + Music/Ambience Sourcing), inserted after v0.97. **v1.25A-P** (Menu Motion Smoothing and Title Polish) and **v1.25B** (Cinematic Intro Story Presentation), inserted after v1.2. **v1.35** (Complete Roadmap Refresh and Level 2 Planning), inserted after v1.3 — kept in correct ascending numeric order relative to v1.4 (verified via `grep -n "^### v"` after editing).
* `docs/FUTURE_FEATURE_BACKLOG.md` — four new bullets under "Medium-Risk Features" cross-referencing the same four roadmap entries, plus a cross-reference from the existing "Part 2 — Sisters Adventure" Dream Backlog bullet to v1.35.
* `docs/AUDIO_DESIGN_PLAN.md` — new "Owner Tone Feedback (2026-06-28)" section with the hit-sound/music/ambience tone requirements verbatim, plus a `v0.95B` status line added next to the existing `v0.95A` status line in the Implementation Order list.
* `docs/STORY_PLAN.md` — new "Cinematic intro update (v1.25B planning)" paragraph added to Section 13 (Cinematic Checkpoint Presentation), immediately following the existing v0.73/v0.74 presentation-direction history, including the explicit "no new Hamza character" correction.

**Current blockers (unchanged by this task, just re-confirmed):** music and all three ambience loops remain `BLOCKED_BY_AUDIO_ASSET` — no safe licensed candidates sourced yet for any of the four loop files.

**Confirmed:** no scripts, scenes, or assets were modified — this was a pure documentation/planning pass. `git diff --stat` should show only the four `docs/*.md` files listed above.

---

## v1.25A-P + v0.95A-FIX — Stabilization Fix Pass After Codex PARTIAL Review — 2026-06-28 (continued session)

Status: COMPLETE (code fixes for Tasks A/B/C; Task D/E are status/documentation corrections, not implementation — by design, since human listening approval cannot be satisfied by code).

Files changed: `scripts/main.gd`, `scripts/player.gd`, `scenes/Main.tscn`, `docs/AUDIO_DESIGN_PLAN.md`, `docs/AUTOPILOT_PROGRESS.md`.

Context: Codex reviewed the branch (`docs/CODEX_LATEST_BRANCH_REVIEW.md`) and returned **PARTIAL** with one High, two Medium, and two Low findings. This pass addresses the High and both Medium findings, plus the bilingual-controls Low finding.

### Task A — Menu tween leak (High, FIXED)

Root cause confirmed exactly as Codex described: `_play_menu_hero_zoom_in()` created its zoom tween as a **local variable**, never stored anywhere, so `_stop_menu_idle_motion()` (which only killed the idle-bob and Play-button-pulse tweens) could never kill it. The zoom tween kept running in the background and could write the 190px menu scale back onto `player_story_sprite` during/after the intro→gameplay transition.

Fix:

* Added two new tracked tween vars: `_menu_zoom_tween`, `_menu_fade_tween` (alongside the pre-existing `_menu_idle_tween`, `_play_button_pulse_tween`).
* `_play_menu_hero_zoom_in()` and `_play_menu_intro_fade()` now store their tweens in these vars instead of local variables.
* New `_stop_menu_presentation()` kills **all four** menu tweens (zoom, fade, idle, pulse) in one place.
* New `_reset_ali_for_gameplay()` wraps `player.reset_player(START_PLAYER_POSITION)` — the existing call already force-refreshes Ali's pose/scale/position back to the normal 100px gameplay transform; it just didn't help before because the leaked tween kept overwriting it afterward.
* `_leave_menu_to_runner_framing()` (called from `_on_play_pressed()` and `_on_skip_intro_button_pressed()`, i.e. the moment the player leaves the menu) now calls `_stop_menu_presentation()` then `_reset_ali_for_gameplay()`.
* **Defensive belt-and-suspenders fix:** `_stop_menu_presentation()` is also called at the very top of `_begin_run()` — the single shared function every gameplay-start path funnels through (`_start_run()` for Play/Skip/intro-completion/Restart/Father-Play-Again, and `_on_retry_pressed()` calling `_begin_run()` directly for Retry). This guarantees the fix covers every listed exit path (Play, Skip intro, intro completed, Restart, Retry, Father Play Again) from one location, not six separate patches.

Validation: a same-lifecycle-point comparison (see "A real bug found while testing this fix" below for why a naive comparison doesn't work) between a "clean" slow Play→Skip and a "fast" immediate Play→Skip showed **identical scale** (`(0.21097, 0.21097)` both, at `run_frame_index=0` both — i.e. both readings captured at the exact same point in Ali's pose lifecycle, before either menu tweens or run-cycle animation could have diverged them). Confirmed `_menu_zoom_tween`/`_menu_idle_tween`/`_play_button_pulse_tween` are all `null` immediately after Play, after the fast exit, 0.65s later, after a full checkpoint cycle, after Retry, and after Restart. Confirmed Ali's X position returns to `PLAYER_START_X` (gameplay X) — never lingers at `MENU_ALI_X` (320) — at every one of those points.

**A real bug found while testing this fix (separate, out of scope, documented honestly rather than hidden):** while building the verification test, raw scale readings of `player_story_sprite` taken at different moments during active gameplay swung between ~`0.102` and ~`0.195` — almost exactly a 1.9x ratio. This is **not** the menu tween leak (confirmed: no menu tween was alive during these readings) — it's that the four `ali_run_1..4` PNG frames have inconsistent visible-rect (cropped) heights, so `player_visual.gd`'s `_calculate_texture_layout()` (which always targets the fixed `VISUAL_HEIGHT = 100.0`) computes a different `uniform_scale` per frame, causing a visible size pulse as the run cycle advances through its 4 frames. This is a real, pre-existing visual-quality issue (likely belongs under `v0.8C — Ali Pose Polish Pass`), but **was not fixed in this task** — fixing it would mean re-cropping/recalibrating the run-frame assets, which is out of scope for a "fix these blockers only" pass and isn't one of the four findings this task was scoped to address. Flagging it here so it isn't lost, and so nobody mistakes it for evidence that the tween-leak fix failed.

### Task B — Jump SFX (Medium, FIXED)

Root cause confirmed exactly as Codex described: `_unhandled_input()` called `audio_manager.play_jump()` unconditionally right after `player.jump()`, but `player.jump()` can merely *buffer* the input while airborne without actually changing velocity — so rapid taps while airborne played the sound every time with no corresponding real jump.

Fix:

* Added `signal jumped` to `player.gd`, emitted at the **exact two points** `velocity.y` is actually set to `JUMP_VELOCITY`: the immediate on-floor branch in `jump()`, and the buffered-jump branch in `_physics_process()` (when a previously-buffered jump finally executes on landing).
* `main.gd` connects to `player.jumped` once in `_ready()` (same pattern as the existing `player.landed` → `play_land()` wiring) via a new `_on_player_jumped()` → `audio_manager.play_jump()`.
* Removed the three direct `audio_manager.play_jump()` calls from `_unhandled_input()` — jump input no longer triggers audio directly at all; only a real velocity change does.

Validation: pressed `player.jump()` once on the ground → exactly 1 `jumped` signal (confirmed via a connected counter, not the audio manager directly, to test the signal contract precisely) → confirmed airborne (`is_on_floor() == false`) 0.15s later → spammed `jump()` 5 more times while airborne (0.05s apart, enough real time for physics frames to actually elapse, unlike an earlier draft of this test that used single render-frame awaits and produced a false positive) → signal count stayed at 1, confirmed no extra emissions while airborne.

### Task C — Arabic-only story controls (Low, FIXED)

Per Codex's exact line references, replaced every remaining bilingual control:

| Control | Before | After |
|---|---|---|
| Intro Next button | `التالي / Next` (+ runtime `"التالي / Next"`/`"ابدأ / Start"`) | `التالي` / `ابدأ` |
| Intro Skip button | `تخطي / Skip` | `تخطي` |
| Checkpoint "next" hint | `Space / Click / Tap — التالي` | `اضغط / انقر / المسافة — للتقدم` |
| Checkpoint Continue button | `متابعة / Continue` (+ runtime `"العب من جديد / Play Again"`) | `متابعة` / `العب من جديد` |

Fixed both the static `scenes/Main.tscn` defaults and the dynamic runtime assignments in `scripts/main.gd` (`_show_intro_step()`, `_show_encounter_dialogue_step()`'s final-step branch) — the scene defaults are what's visible before any dynamic text overwrites them, so both needed the same fix. Also added `text_direction = 3`/`language = "ar"` to the intro's `NextButton`/`SkipButton`, which hadn't had them set previously (a minor RTL-correctness gap, not just a translation one). Confirmed via `grep` across `scenes/Main.tscn` that no remaining `text = "..."` value mixes Arabic and Latin letters in the same string, except the intentional `SubtitleLabel` ("Ali Runner") and the three single-emoji character placeholder labels (فاطمة/زينب/جمانة + emoji, not English text).

Not touched (already Arabic-only from earlier work, re-verified, not part of this fix): `ابدأ اللعب` (Play), `تخطي المقدمة` (Skip Intro), `إعادة المحاولة من آخر نقطة` (Retry), `إعادة البدء من البداية` (Restart), `النقاط` (Score), `انتهت المحاولة` (Game Over).

### Task D — Audio review status (documentation correction)

No code removed, no SFX deleted, no claim of final quality made. Updated `docs/AUDIO_DESIGN_PLAN.md` with a new "v0.95A Review Status" section stating: v0.95A is `PARTIAL_COMPLETE` / `AUDIO_CANDIDATES_INTEGRATED_FOR_REVIEW`; all 11 SFX remain `HUMAN_AUDIO_REVIEW_REQUIRED`; the owner must listen and approve before any merge to `main`; music/ambience remain missing. Checked for an existing audio settings/mute flag (`grep` across `audio_manager.gd`/`main.gd`) — **none exists**, so there is nothing to document there; no settings menu was added (none was requested).

### Task E — New audio file safety (documentation correction, no integration)

Confirmed via `grep` across `scripts/` that neither `hit_soft_impact.wav` nor `main_theme_soft_loop.ogg` is referenced, loaded, or played by any code — they are not in `AudioManager.SOUND_PATHS` and nothing else touches `assets/audio/gameplay/hit_soft_impact.wav` or `assets/audio/music/main_theme_soft_loop.ogg`. Documented both as **UNVERIFIED_AUDIO_CANDIDATE** in `docs/AUDIO_DESIGN_PLAN.md` since neither has a logged source/license entry in `docs/AUDIO_CREDITS.md` yet (that file was intentionally left untouched — it's outside this task's allowed-files list).

### Validation

* Headless boot (`--quit`) clean, exit 0, no parser/runtime errors, both before and after all fixes.
* Smoke test (deleted after running, along with its `.uid`): covered the same-lifecycle-point scale comparison (Task A), the jumped-signal-count test with real elapsed time (Task B), all Arabic control text values (Task C), and a full regression — intro, Fatima checkpoint trigger/dialogue/reward/countdown, Game Over, Retry, Restart, audio manager player count. **0 failed assertions** in the final run (after fixing two test-only bugs along the way — a flawed "runner_scale" baseline captured mid-tween, and single-render-frame awaits that didn't reliably let physics frames elapse — both documented so they aren't mistaken for product regressions later).
* `git diff --stat` confirmed only the listed files changed.

Immutable benchmarks re-verified unchanged: gravity `1050.0`, jump `-440.0`, fall `700.0`, buffer `0.12`, road surface `510.0`, collision half-height `24.0`, spawn interval `2.25`, spawn X, base/post-checkpoint speeds `225/240/255/270`, all four trigger scores `15/35/60/90`.

### Remaining blockers (unchanged by this task, explicitly not addressed per scope)

* Human listening review for the 11 integrated SFX — required before merge to `main`.
* `hit_soft_impact.wav` — license/source unverified, not integrated.
* `main_theme_soft_loop.ogg` — license/source unverified, not integrated.
* Ambience loops (city/birds/wind) — still missing entirely.

### Recommended next task

Codex review of this fix pass — to confirm the menu-tween-leak repro no longer reproduces, the jump-SFX behavior matches the acceptance criteria, and the Arabic-control policy is now consistently applied, before deciding whether v0.95A can be considered "approved" (still pending the separate human-listening step) and before picking up the newly-found run-cycle frame-scale inconsistency as its own task.

---

## Level 1 Completion Sprint — Implementation Track — 2026-06-28 (continued session)

This entry begins the implementation half of the work the parallel documentation track planned in its "v1.36 Planning" and "Parallel Documentation Track" entries above. Milestones are implemented and committed one at a time, in order.

## v1.26A — Ali Visual Calibration — STATUS: COMPLETE

Files changed: `scripts/player_visual.gd`.

Measured every pose/run-frame texture's actual visible (non-transparent) bounding-box height with a one-off Python/PIL script (diagnostic only, not committed) to get real numbers instead of guessing:

| Texture | Visible height (px) | Auto-computed scale (100/height) |
|---|---:|---:|
| `ali_idle.png` (reference) | 474 | 0.211 |
| `ali_land.png` | 241 | **0.415** (≈1.97x idle — the reported "giant landing pose") |
| `ali_run_1.png`/`ali_run1.png` | 517 | 0.193 |
| `ali_run_2.png` | 981 | **0.102** (≈half of frames 1/3/4 — the run-cycle "pulse") |
| `ali_run_3.png` | 513 | 0.195 |
| `ali_run_4.png` | 513 | 0.195 |
| `ali_jump.png` | 376 | 0.266 |
| `ali_fall.png` | 416 | 0.240 |
| `ali_hurt.png` | 447 | 0.224 |
| `ali_victory.png` | 426 | 0.235 |

Implemented exactly the suggested structure: `POSE_SCALE_OVERRIDES` (currently just `LAND: 0.224`, bringing it in line with the hurt/victory/idle band instead of nearly doubling it) and `RUN_FRAME_SCALE_OVERRIDES` (all four frame indices → `0.194`, matching frames 1/3/4's natural value and correcting frame 2's outlier). `_apply_texture()`/`_calculate_texture_layout()` now accept an optional `scale_override` float; when provided (and `> 0.0`) it replaces the auto-computed `VISUAL_HEIGHT / visible_rect.size.y` value, but the position/feet-alignment math is unchanged — it's derived from whichever scale value is in effect, so overriding the scale doesn't break feet alignment. `show_pose()` and `update_visual()`'s frame-cycling loop look up the override for the pose/frame index being shown and pass it through. No PNGs were touched; this is purely a code-side calibration step, per the explicit owner direction.

**Deliberately not touched:** `ali_slide.png` shows a similarly suspicious ratio (visible height 308 → auto scale 0.325, ≈1.94x idle) but `SLIDE` is never actually requested by `player.gd` anywhere in the current gameplay loop (confirmed via `grep` — only IDLE/RUN/JUMP/FALL/LAND/HURT/VICTORY are ever shown). Since it's not currently visible to a player, it was left uncalibrated rather than guessed at — flagging it here so it isn't forgotten if `SLIDE` is ever wired up later.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running): confirmed `LAND` pose scale (`0.224`) is now within ~6% of idle's scale, not ~97% larger; confirmed all 8 simulated run-cycle steps produce the exact same scale (`0.194`, ratio `1.0`) instead of swinging between `0.102` and `0.194`; confirmed JUMP/FALL/HURT/VICTORY/IDLE still render with their original (unmodified, already-reasonable) auto-computed scales; confirmed `FEET_Y` constant unchanged; confirmed the menu hero presentation's separate scaling path (`main.gd`'s `_show_menu_hero_presentation()` → `ASSET_UTILS.fit_sprite_visible_to_height`) still produces a larger-than-gameplay scale, i.e. is unaffected by this change. **0 failed assertions.**

Immutable benchmarks re-verified unchanged (gravity/jump/fall/buffer, road surface, collision, spawn interval/X, all speeds, all four checkpoints).

Commit: `autopilot: v1.26A Ali visual calibration`.

## v1.25B — Cinematic Intro Presentation — STATUS: COMPLETE

Files changed: `scripts/main.gd`.

Replaced the flat, centered-text "الراوي" narration with an in-world scene reusing the same patterns already proven for the checkpoint encounters, rather than inventing a new presentation system:

* **Positioning:** reused the existing `_prepare_player_for_encounter()` (Ali at `ALI_STORY_X`, resized via `ALI_STORY_VISUAL_HEIGHT`) for Ali, and positioned `father_npc` at `ENCOUNTER_TARGET_X`/`_get_encounter_world_y(FATHER)` — the exact same spot Father already stands at for the real ending. No new world-position constants were needed.
* **Speech bubble placement:** added `_position_intro_bubble_for_speaker()`, which reuses `scripts/ui/dialogue_bubble_helper.gd`'s existing `get_position()` (the same helper the checkpoint dialogue already uses) by mapping each intro line's new `speaker_visual` field (`"narrator" | "father" | "ali"`) onto the existing `DialogueRole` enum (`REWARD` for narrator → centered top banner; `HELPER` for Father → bubble near Father; `ALI` for Ali → bubble near Ali). No new placement math was written.
* **Speaker focus/dim:** added `_update_intro_speaker_focus()` — the speaking character's sprite scales up by `INTRO_FOCUS_SCALE` (1.08x) relative to its own captured base scale and stays at full alpha; the non-speaking character dims to `INTRO_DIM_ALPHA` (0.55) at its normal scale. Both properties animate via one shared, explicitly-tracked `_intro_focus_tween` (killed and replaced on every line change) — applying the same "track every tween, kill before replacing" discipline the v1.25A-P menu-tween-leak fix established, specifically to avoid repeating that exact class of bug here.
* **Warm overlay:** the existing `IntroOverlay/Dim` `ColorRect` (`Color(0.04, 0.03, 0.02, 0.6)`, already warm dark-brown) was reused as-is — already satisfied this requirement, no change needed.
* **Buttons:** `التالي`/`تخطي` were already Arabic-only from the earlier stabilization pass — no change needed here either.
* **Story text:** the three documented lines (الراوي/الأب/علي) are byte-for-byte unchanged — only a new `speaker_visual` tag was added per line, no wording changed. No "Hamza" or any new character was added — only Ali and Father appear, per the explicit instruction.
* **Teardown:** new `_setup_intro_scene()`/`_teardown_intro_scene()` pair brackets the whole intro. Teardown kills the focus tween, hides `father_npc`, and resets its `modulate`/`scale` back to neutral — called from `_finish_intro()`, which runs on both the natural last-line "ابدأ" press and the "تخطي" skip button, so both exit paths clean up identically. Also added `father_npc.scale = Vector2.ONE` to the existing `_reset_checkpoint_encounter_state()` (defense-in-depth, since that function already resets every NPC's visibility/alpha on every gameplay-start path) and `player.modulate = Color.WHITE` to `_reset_ali_for_gameplay()` (same defense-in-depth reasoning, so a future feature that dims Ali can't leak past intro either).

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running): confirmed Ali is positioned at `ALI_STORY_X` and `father_npc` becomes visible the moment intro starts; confirmed both stay neutral during the narrator line; confirmed Father visibly brightens/scales up and Ali dims while Father speaks, and vice versa for Ali's line; confirmed that after the final "ابدأ" press, intro ends, gameplay starts, `father_npc` is hidden again with alpha/scale fully reset, `player`/`player_story_sprite` modulate are back to `1.0`, Ali is back at `PLAYER_START_X`, `_intro_focus_tween` is `null`, and none of the v1.25A-P menu tweens leaked through this new code path either; confirmed the real Father checkpoint ending (triggered independently via `_begin_run(89, JOMANA, 270.0)` + one obstacle pass) still triggers normally afterward, proving the intro's reuse of `father_npc` doesn't interfere with its later checkpoint use. **0 failed assertions.**

Immutable benchmarks re-verified unchanged.

Known visual risk (HUMAN_VISUAL_REVIEW_REQUIRED): the intro's speech-bubble labels (`IntroSpeaker`/`IntroLine`) are sized 500x30 / 700x90, while `DIALOGUE_BUBBLE_HELPER`'s clamping logic assumes a single 480x160 `BUBBLE_SIZE` box. The position is still computed correctly (near the right character, clamped to the viewport), but the exact box dimensions used for that clamping don't precisely match the actual label sizes — worth a follow-up visual pass to confirm the text never clips off-screen at the extremes, rather than a code-level bug.

Commit: `autopilot: v1.25B cinematic intro presentation`.

## v1.26 — Family Companion Journey UI — STATUS: COMPLETE

Files changed: `scenes/Main.tscn`, `scripts/main.gd`.

Added a small `CompanionRibbon` Control under `UI`, top-right (clear of `ScoreLabel` top-left and the centered checkpoint/intro dialogue) with a small "رفاق الرحلة" label and three 36x36 icon slots (Fatima/Zainab/Jomana), each with a `TextureRect` (for when a real/helper portrait exists) plus a `ColorRect`+emoji `Label` placeholder fallback, reusing the exact placeholder colors already established for each sister (golden/red/green) for visual consistency. The ribbon container itself stays hidden until at least one companion has joined.

State: three new bools (`companion_fatima_joined`, `companion_zainab_joined`, `companion_jomana_joined`) plus `_update_companion_ribbon()`/`_update_companion_slot()`. Wired at exactly the same point each sister's existing reward effect is already granted (Fatima's `_apply_fatima_reward_bonus()` call site, Zainab's `_apply_zainab_shield_grant()` call site, Jomana's `audio_manager.play_reward_key()` call site) — no new trigger points invented. `_begin_run()` sets all three from the `checkpoint` parameter using the exact same `checkpoint >= StoryCheckpoint.X` pattern already used for `fatima_reward_applied`/`zainab_shield_active`, so Retry naturally restores the right companion set and a fresh Restart/Play naturally clears it — this is the same mechanism, not a second state system. `_show_start_screen()` also explicitly clears all three and updates the ribbon, defensively covering the start-screen path too.

Icon source: each slot first tries the same `Texture2D` already loaded for that sister's checkpoint-panel portrait (`fatima_texture.texture` etc., set by the existing `encounter_controller.apply_optional_character_texture()` call in `_apply_optional_story_textures()`) — no new texture loading was added. If that's `null` (the common case today, since Zainab/Jomana have no real art yet and Fatima's is the real-photo placeholder), the slot falls back to its small colored placeholder instead.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running): confirmed the ribbon is hidden at boot; confirmed it becomes visible and Fatima's icon appears the moment her reward step fires, while Zainab's icon stays hidden until hers does; confirmed all three icons accumulate correctly through Fatima → Zainab → Jomana; confirmed a Game Over + Retry from the Jomana checkpoint restores all three companions and keeps the ribbon visible; confirmed Restart from Beginning clears all three and hides the ribbon again. **0 failed assertions.**

Immutable benchmarks re-verified unchanged. No collision, physics, checkpoint-score, or reward-logic changes — this is UI/state only, exactly as scoped.

Commit: `autopilot: v1.26 family companion journey UI`.

## v1.27 — Father Ending Family Group Scene — STATUS: COMPLETE

Files changed: `scripts/main.gd`.

When the Father encounter's cinematic opens (`_open_checkpoint_cinematic()`, gated to `character_id == FATHER` only), `_show_father_ending_family_group()` now repositions and reveals the existing `fatima_npc`/`zainab_npc`/`jomana_npc` nodes as a small reunion cluster between Ali and Father — reusing the exact same nodes, sprites, and fallback placeholders each sister already uses for her own checkpoint, not new assets or a second NPC system. Each is only shown if `companion_fatima_joined`/`companion_zainab_joined`/`companion_jomana_joined` is true (in practice always true by the time score reaches 90, but checked defensively rather than assumed). Each sister keeps her own established Y-position role via the existing `_get_encounter_world_y()` — Fatima stays at curb level (never standing on the road, per her established newborn character rule), Zainab/Jomana stand at road level like Father — only the X position (`FAMILY_GROUP_FATIMA_X`/`_ZAINAB_X`/`_JOMANA_X` = 380/450/520, spaced between Ali at 300 and Father at 610) and a uniform `FAMILY_GROUP_SCALE` (0.65, shrinking them down so they read as a background/midground group rather than competing with Ali and Father for focus) are new.

No new story dialogue was added — the existing Father ending lines (already fixed/documented) are unchanged; this is a visual composition change only.

**Reset correctness (the same lesson from the v1.25A-P tween-leak and v1.25B intro work, applied again here):** `_reset_checkpoint_encounter_state()` — already the single place every gameplay-start path resets all four NPCs' visibility/alpha — now also resets `fatima_npc.scale`/`zainab_npc.scale`/`jomana_npc.scale` to `Vector2.ONE` (previously only `father_npc.scale` was reset, added during v1.25B). Without this, a sister's NPC would stay shrunk at `0.65` scale during her own next individual checkpoint encounter after a Father ending + "Play Again" restart — confirmed this exact regression doesn't happen via the smoke test below.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running): jumped straight to a near-Father state (`_begin_run(89, JOMANA, 270.0)`) with all three companions already joined (the realistic case, since reaching score 90 requires having passed all three checkpoints) → triggered the Father encounter → confirmed all three sisters become visible at the family-group scale, at distinct non-overlapping X positions, with Fatima specifically still at curb-level Y while Zainab/Jomana/Father share road-level Y → advanced dialogue to the end → pressed "Play Again" → confirmed the full restart hides all four NPCs again, resets all three sisters' scale back to `1.0` (not stuck at `0.65`), and clears all three companion flags → confirmed a fresh, independent Fatima encounter afterward renders her at full `1.0` scale again, not the family-group shrink. **0 failed assertions.**

Immutable benchmarks re-verified unchanged. No collision, no gameplay changes — purely a visual composition + defensive reset addition.

Commit: `autopilot: v1.27 father family ending scene`.

## v1.2B — Dust/Shadow Polish — STATUS: COMPLETE

Files changed: `scripts/player.gd`.

Implemented all four pieces using only procedural nodes (`Polygon2D`, `CPUParticles2D`) created at runtime in `_setup_ground_polish()` — no textures, no downloaded assets, no scene file changes:

* **Grounded shadow:** a small flat dark `Polygon2D` ellipse-ish quad, anchored at `ali_sprite.FEET_Y` (reusing the existing constant rather than a new magic number), `z_index = -5` relative so it always draws behind Ali's sprite.
* **Running dust:** a 6-particle `CPUParticles2D`, continuous (`one_shot = false`), toggled on/off every frame in `_update_visual_pose()` — emitting only while the `RUN` pose is actually showing (not during jump/fall/land, not while gameplay is inactive).
* **Jump dust puff:** triggered at both points `jumped` is emitted (the immediate on-floor branch in `jump()` and the buffered branch in `_physics_process()`), via a shared `_play_impact_dust()` helper that calls `restart()` then sets `emitting = true` on a one-shot 10-particle burst.
* **Landing dust puff:** the same `_play_impact_dust()` call added right where `landed` is already emitted (the airborne→grounded transition).
* **Game Over impact dust:** the same call added to `kill()`.

Reused one burst effect (`_impact_dust`) for jump/land/Game Over rather than three separate particle systems — kept this lightweight per the "no heavy particles" rule, and a single well-tuned burst reads fine for all three "something just happened at Ali's feet" moments.

**Safety/cleanup additions:** `_run_dust.emitting` is explicitly forced `false` in `kill()` and `reset_player()` (with `null` guards in case either is ever called unusually early), so dust can't keep emitting after death or visibly linger across a Restart/Retry — this follows the same "don't leave a per-frame effect running past its owning state" discipline already applied to the menu tweens and intro focus tween earlier in this sprint.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running): confirmed all three new nodes exist after `_ready()`; confirmed jumping fires the impact-dust burst and stops the run-dust immediately; confirmed run-dust resumes once Ali lands and the land-pose window passes; confirmed a Game Over hit fires the impact-dust burst again and stops run-dust; confirmed Restart leaves run-dust stopped (not mid-emit) right away. **0 failed assertions.**

Immutable benchmarks re-verified unchanged — purely a visual addition, no physics/collision touched (the new nodes are plain `Polygon2D`/`CPUParticles2D`, neither of which participates in `CharacterBody2D` collision).

Commit: `autopilot: v1.2B dust shadow polish`.

## v0.95B — Hit Sound and Background Music Polish — STATUS: PARTIAL_COMPLETE

Files changed: `scripts/audio/audio_manager.gd`, `scripts/main.gd`.

**Checked the documentation gate before touching anything, exactly as instructed:** `docs/AUDIO_CREDITS.md` has a full, verified entry for `main_theme_soft_loop.ogg` (OpenGameArt "Icy Heights," author Écrivain, CC0 1.0 Universal, logged 2026-06-28) — integrated. `hit_soft_impact.wav` has **no entry at all** in `docs/AUDIO_CREDITS.md` — **not integrated**, per the task's own explicit rule ("integrate it as preferred hit sound only ... if documented"). `level1_exciting_loop.ogg` is also undocumented and was left alone entirely. `hit.wav` remains the only active hit sound; nothing about it was changed.

### Music integration

* `AudioManager` gained a dedicated, separate-from-SFX music path: `_load_music()` (called once from `setup()`), `start_music()`, `stop_music()`, `duck_music()`, `unduck_music()`, all guarded by a single `_music_player`/`_music_loaded` pair — there is exactly one `AudioStreamPlayer` for music, created once, never duplicated, so calling `start_music()` again later (e.g. defensively) is a safe no-op rather than a second player or a restart-from-zero.
* Looping is set directly on the loaded `AudioStreamOggVorbis` resource (`stream.loop = true`) at runtime rather than depending on the `.import` file's `loop` setting (which defaulted to `false`) — confirmed this is the correct Godot 4 API surface for this stream type before relying on it.
* Volume: `MUSIC_VOLUME_DB = -22.0`, inside the requested -20dB to -24dB range. Ducking uses `MUSIC_DUCK_DB = -32.0` with a `0.6s` tween (`duck_music()`/`unduck_music()`), not an instant cut — reads as "softening," not a hard mute.
* **Where it starts/stops/ducks:** `audio_manager.start_music()` is called once, from `_show_start_screen()` (the safest, simplest point — runs exactly once at boot; every later Restart/Retry/Play-Again reuses the same already-playing player, never restarting it). It ducks on `_start_intro()` (intro dialogue), on `_open_checkpoint_cinematic()` (every checkpoint's dialogue, including Father's), and inside `_end_run()` (Game Over). It unducks inside `_finish_encounter_and_countdown()` (when a mid-run checkpoint's Continue is pressed, before the resume countdown) and at the very top of `_begin_run()` — the single shared funnel for every gameplay-start path (Restart, Retry, Father's "Play Again," and the post-intro `_start_run()`), so every path that could leave music ducked gets it unducked from one place rather than four separate patches.
* Missing-file safety: `_load_music()` follows the exact same `ResourceLoader.exists()` → `load()` → null-check pattern as every SFX, logs once via the existing `_log_missing_once()` helper, and every public method (`start_music`/`stop_music`/`duck_music`/`unduck_music`) early-returns if `_music_loaded` is false — confirmed safe by temporarily simulating a missing sound during testing (this session and earlier ones).
* `main_theme_soft_loop.ogg` stays marked `HUMAN_AUDIO_REVIEW_REQUIRED` in both the code's own log line and the design docs — license is verified, tone/loudness/fit is not.

### Validation

* Headless boot clean, exit 0. (One pre-existing, unrelated benign shutdown warning — "2 resources still in use at exit" for the music stream resource — appears with `--verbose`; this is normal Godot behavior for any `AudioStreamPlayer`-held resource still attached at an abrupt `--quit` shutdown, not a functional defect; the actual smoke test below passed with 0 failures regardless.)
* Smoke test (deleted after running): confirmed music auto-starts on the start screen at exactly `-22.0dB`; confirmed calling `start_music()` again doesn't create a second player; confirmed music ducks to `-32.0dB` during the intro and unducks back to `-22.0dB` the instant gameplay starts; confirmed the same duck/unduck cycle around a full Fatima checkpoint (ducks on cinematic open, unducks on Continue, before the countdown even finishes); confirmed ducking during Game Over and restoration after Restart; confirmed a simulated missing SFX still doesn't crash; confirmed `hit_soft_impact.wav` is genuinely not wired into `SOUND_PATHS` and `hit.wav` remains the active hit sound. **0 failed assertions.**

Immutable benchmarks re-verified unchanged.

**Why this is PARTIAL_COMPLETE, not COMPLETE:** the "Hit Sound" half of this milestone's title was not done, because its prerequisite (a documented, licensed `hit_soft_impact.wav`) doesn't exist yet. Music is fully integrated; the hit-sound improvement remains blocked exactly where `docs/AI_GAME_ROADMAP.md` ("v0.95B") already said it would be.

Commit: `autopilot: v0.95B hit sound and background music polish`.

## v1.34 — Level 1 Gold Candidate — STATUS: NOT YET GOLD (AUTOMATED PASS)

Files changed: `scripts/player_visual.gd`, `docs/LEVEL_1_GOLD_CHECKLIST.md`, `docs/AUTOPILOT_PROGRESS.md`, and the v1.34 status tag in `docs/AI_GAME_ROADMAP.md`.

### Ali run-size regression fixed

The owner reported that Ali visibly grew and shrank while running. The v1.26A calibration had forced all four run textures to the same numeric scale (`0.194`) even though their source-image visible heights differ substantially (about 517/981/513/513 px). That made frame 2 render around 190 px tall while the other frames rendered around 100 px — exactly the reported pulse.

Removed `RUN_FRAME_SCALE_OVERRIDES`, `POSE_SCALE_OVERRIDES`, and their override plumbing. `AliPlayerVisual` now consistently computes `VISUAL_HEIGHT / visible_rect.size.y` for every texture. Numeric scale is expected to differ by source resolution; the resulting visible character height is now the stable quantity.

Focused validation against the current worktree (including the owner's modified `ali_land.png`): eight consecutive run-frame steps each measured `100 px` visible height and `feet_y = 24`; LAND also measured `100 px` and `feet_y = 24`. No asset file was changed by this fix.

### Full continuous regression

Headless boot completed with exit code 0 and no parser/runtime errors. One temporary smoke script then drove one `Main.tscn` instance through:

* Start screen and Play.
* In-world Ali/Father intro and music duck/restore.
* Gameplay with all four run frames normalized to 100 px.
* Fatima at 15, +5 reward, ribbon update, Continue/countdown, speed 240.
* Zainab at 35, companion update, shield grant, one absorbed hit, speed 255.
* Jomana at 60, all companions joined, four-spawn safety window, speed 270.
* Father at 90, all three sisters visible at family-group scale, Play Again reset.
* Verified companion flags/ribbon clear and all sister NPC scales return to `Vector2.ONE`.
* Separate Game Over, Retry from Jomana (score 60/speed 270/all companions), then Restart from Beginning (score 0/speed 225/no companions).
* Dust/shadow runtime nodes present and background music loaded/playing.

Result: `GOLD_SMOKE_RESULT=PASS`. The temporary script was deleted and no temporary `.gd.uid` remained. Abrupt harness shutdown reported ObjectDB/resource cleanup warnings from active tweens/music; the normal required `--headless --path . --quit` run also exited 0. These are recorded as shutdown-test noise, not parser/runtime failures.

### Immutable constants

Reconfirmed unchanged: gravity `1050`, jump `-440`, max fall `700`, jump buffer `0.12`, road surface `510`, player collision `32x48`, spawn interval `2.25`, spawn X `1152 + 140 = 1292`, speeds `225/240/255/270`, and checkpoint scores `15/35/60/90`.

### Verdict and blockers

**NOT YET GOLD — automated Gold-candidate validation passed.** No remaining automated/code blocker was found after correcting Ali's run-frame normalization. Gold still requires owner-only decisions/checks:

* Listen to and approve/remap/reject the integrated SFX and `main_theme_soft_loop.ogg` (`HUMAN_AUDIO_REVIEW_REQUIRED`).
* Check Arabic RTL rendering, clipping, and readability in F6.
* Check visual feel in F6: stable Ali size, run/land transitions, menu motion, parallax seams, dust/shadow, companion ribbon, and Father composition.
* Explicitly accept shipping without city/birds/wind ambience and without the undocumented better-hit candidate, or provide verified licensed replacements.

Do not start v1.35 or Level 2 until the owner completes these human-required reviews and accepts the remaining audio limitations.

## Post-v1.34 — Real Character Art Integration (Father, Fatima, Zainab, Jomana) — STATUS: COMPLETE

Files changed: `scripts/story/encounter_data.gd` only.

The owner dropped four new character PNGs onto the branch: `assets/characters/father/father_left.png`, `assets/characters/fatima/fatima_companion.png`, `assets/characters/zainab/zainab_companion.png`, `assets/characters/jomana/jomana_companion.png`. All four are pre-drawn facing left (toward Ali, who is always positioned to the left of these nodes in every context — gameplay encounter X `610` vs Ali, cinematic intro, and the Father-ending family group at X `380/450/520` vs Father at `610`), so no `flip_h` change was needed anywhere.

These four nodes (`fatima_npc`/`zainab_npc`/`jomana_npc`/`father_npc` and their `*_sprite`/checkpoint-panel textures) were already fully wired by v1.25B/v1.26/v1.27 to a single data-driven source: `EncounterData.ENCOUNTERS[...]["asset_path"]` and `["visual_height"]`, consumed once at boot by `EncounterController.apply_optional_character_texture()` (called from `_apply_optional_story_textures()` in `_ready()`). That one call already drives the checkpoint-panel icon, the companion-ribbon icon (via `fatima_texture.texture` etc.), the in-world encounter sprite, the cinematic intro sprite, and the Father-ending family-group sprite — so the only safe, smallest change was updating the data, not the code:

* `asset_path` updated from the missing/placeholder filenames (`fatima_helper.png`, `zainab_helper.png`, `jomana_helper.png`, `father_ending.png` — none of which had ever existed on disk this whole sprint) to the four real files above.
* `visual_height` for Fatima only: `100.0 -> 60.0`. This is the one value that violated the owner's requested relative-size rule once a real baseline (`ALI_STORY_VISUAL_HEIGHT = 160.0`, the height Ali renders at in every context these NPCs share the screen with him) was checked: Zainab (`84`) was already `<` Jomana (`92`), and Father (`200`) was already `>` Ali (`160`), but Fatima (`100`) was larger than both sisters, not the smallest. Lowering only Fatima to `60` satisfies the full requested chain — `Father(200) > Ali(160) > Jomana(92) > Zainab(84) > Fatima(60)` — without touching the other three already-compliant values.
* No PNGs were edited. All sizing is the existing code-side `ASSET_UTILS.fit_sprite_visible_to_height()` / `align_sprite_visible_bottom()` pipeline (alpha-trimmed visible-bounds based, not raw pixel dimensions), so the four new images do not need matching canvas sizes or padding.
* Missing-asset fallback is untouched and still safe: `apply_optional_character_texture()`'s `texture == null` branch (placeholder polygon + Arabic label) is unchanged code, only now unreachable for these four characters because the files genuinely exist.

Validation:

* `Godot --headless --path . --import` run once to generate `.import` metadata for the four new PNGs.
* `Godot --headless --path . --quit` → exit `0`, no parser/runtime errors. Boot log confirms all four loaded and scaled exactly as intended: `FatimaSprite ... target_height=60.0`, `ZainabSprite ... target_height=84.0`, `JomanaSprite ... target_height=92.0`, `FatherSprite ... target_height=200.0`, each preceded by `exists=true` and `helper texture loaded`.
* No temporary smoke script was needed — the boot log itself exercises the exact single code path (`_apply_optional_story_textures()`) shared by every consuming context (panel icon, ribbon icon, in-world sprite); intro/family-ending only reposition/rescale the same already-textured nodes and were not touched.

Immutable benchmarks unaffected — no physics/collision/spawn/speed/checkpoint constant exists in this file.

No commit made yet; left for the owner to review the four new assets in-engine (F6) before this is committed alongside their own concurrent uncommitted changes (`ali_land.png`, audio docs) already present on the branch.

## Level 1 Polish Autopilot — Milestone 1: Character Scale and Father Heroic Presentation — STATUS: COMPLETE

Files changed: `scripts/story/encounter_data.gd`, `scripts/main.gd`.

**Owner feedback addressed:** Fatima looked too small/distant in story scenes; Father should feel more heroic.

* Checked the real on-screen baseline before touching any number: in every context these NPCs share the screen with Ali (intro, checkpoint cinematic, family ending), Ali renders at `ALI_STORY_VISUAL_HEIGHT = 160`, not the gameplay `100`. Against that baseline, Zainab (`84`) was already `<` Jomana (`92`), and Father (`200`) was already `>` Ali (`160`) — only Fatima (`72` after the previous asset-integration pass) needed to move, and only enough to stop reading as "tiny" while staying the smallest.
* `encounter_data.gd`: Fatima `visual_height` `60 -> 72` (the `60` value was a previous pass's placeholder fix that turned out too conservative once seen in motion); Father `visual_height` `200 -> 215` for a touch more stature. Final chain: **Father(215) > Ali(160) > Jomana(92) > Zainab(84) > Fatima(72)**.
* `main.gd` — Father heroic treatment in the cinematic intro (`_update_intro_speaker_focus()`): previously both non-speaking characters dimmed to the same `INTRO_DIM_ALPHA = 0.55`. Father now gets his own, much lighter dim (`FATHER_NON_SPEAKER_DIM_ALPHA = 0.78`) when Ali is speaking, so he stays a clearly visible, important presence instead of fading into the background like a generic NPC. When Father himself speaks, he also gets a subtle warm brighten (`FATHER_SPEAKING_TINT = Color(1.06, 1.04, 0.96, 1)`) layered onto the existing scale-up focus, instead of plain white — a small, child-friendly "glow," not an exaggerated effect. Implemented by widening the existing tracked `_intro_focus_tween` (already `tween_property`-based and already killed/replaced safely) to animate `father_npc`'s full `modulate` Color instead of only `modulate:a`, so this reuses the same safe tween-tracking pattern rather than adding a second competing tween.
* All three reset points that zero out `father_npc`'s modulate (`_teardown_intro_scene()`, `_reset_checkpoint_encounter_state()`, and the equivalent sister resets) were updated from `modulate.a = 1.0` to `modulate = Color.WHITE` so the new rgb tinting can never leak past its owning intro step into gameplay, a later encounter, or Retry/Restart.
* Father's heroic treatment during the ending family scene (not just the intro) is intentionally deferred to Milestone 4, where a general speaker-emphasis system is added for checkpoint cinematics (today's heroic tint only existed for the intro's existing per-step focus system; the ending currently has no per-step in-world focus system at all to extend).

Validation:

* Headless boot clean, exit 0. Boot log confirms `FatherSprite ... target_height=215.0` applied correctly.
* Smoke test (deleted after running, `tmp_m1_smoke_test.gd` + its `.uid`): confirmed the full size chain `father(215) > ali(160) > jomana(92) > zainab(84) > fatima(72)`; confirmed the narrator line keeps both Ali and Father at full visibility; confirmed Father's speaking step brightens him (`modulate.r > 1.0`) while Ali dims to `INTRO_DIM_ALPHA`; confirmed Ali's speaking step dims Father only to `FATHER_NON_SPEAKER_DIM_ALPHA` (not the deeper `INTRO_DIM_ALPHA`) while Ali stays fully visible; confirmed teardown resets Father's modulate to pure `Color.WHITE`. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, spawn interval/X, all four speeds) — this milestone only touched story-presentation data and a cinematic-only tween.

Commit: `autopilot: polish character scales and father presentation`.

## Level 1 Polish Autopilot — Milestone 2: Remove Black Rectangle Under Ali — STATUS: COMPLETE

Files changed: `scripts/player.gd`.

**Root cause:** the v1.2B dust/shadow polish added `_ground_shadow`, a `Polygon2D` literally built from 4 hard corner points (`Vector2(-14,-3), (14,-3), (14,3), (-14,3)`) — a flat-sided rectangle, not an oval — filled with a near-black, fairly opaque color (`Color(0.05, 0.03, 0.02, 0.32)`). It is always visible (never toggled off, unlike the dust particles), so it reads exactly as reported: a black rectangle sitting under Ali's feet at all times during gameplay.

**Fix:** added a small `_build_oval_polygon(radius)` helper that generates a smooth 16-point ellipse outline, and rebuilt the shadow as two layered ovals instead of one rectangle — a slightly smaller, slightly darker core oval (`SHADOW_COLOR = Color(0.08, 0.06, 0.05, 0.28)`, radius `14x4`) plus a larger, much more transparent halo oval beneath it (`SHADOW_SOFT_COLOR = Color(0.08, 0.06, 0.05, 0.12)`, radius `20x6`) for a soft falloff look. Both are still plain `Polygon2D` nodes (no textures, no particles, no new draw calls beyond one extra cheap polygon) — same z-index/positioning/anchor approach as before, so it still tracks Ali's feet (`ali_sprite.FEET_Y`) exactly as it did.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running, `tmp_m2_smoke_test.gd` + its `.uid`): confirmed a dark-toned shadow polygon still exists under the player; confirmed no remaining shadow polygon has 4 or fewer points (i.e. the rectangle shape is gone); confirmed normal gameplay (start run, jump, land) is unaffected by the shape swap. **0 failed assertions.**

Immutable benchmarks unaffected — purely cosmetic geometry/color change to a non-collidable visual node.

Commit: `autopilot: remove ali foot artifact and clean shadow`.

## Level 1 Polish Autopilot — Milestone 3: Run Smoothness Polish — STATUS: COMPLETE

Files changed: `scripts/player_visual.gd`.

Reviewed the run-frame switching logic (`update_visual()`'s `while run_anim_time >= frame_duration` accumulator loop in `player_visual.gd`) before changing anything: it is already correct and jerk-free at the data level — the v1.34 fix already normalizes every run frame to the same visible height (`100px`) and the same `feet_y` (`24`), so there is no per-frame size/position pop. The only remaining lever for "run smoothness" without touching physics or adding frames is cadence: `RUN_ANIMATION_FPS` was `10.0`, giving a `400ms` full 4-frame cycle, which reads as a slow, choppy step rate for a runner.

Raised `RUN_ANIMATION_FPS` from `10.0` to `13.0` (a `~308ms` cycle) — still the same 4 frames, same reset behavior (`_reset_run_animation()` still zeroes `run_anim_time`/`run_frame_index` on every pose change), same feet alignment, just a brisker, more natural-feeling step cadence.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running, `tmp_m3_smoke_test.gd` + its `.uid`): confirmed `RUN_ANIMATION_FPS >= 12`; confirmed the run frame index actually cycles at the new rate during a live run; confirmed visible height stays within `1px` and feet `Y` stays within `1px` across 40 sampled frames over 2 seconds (no size/position jerk introduced by the faster cadence). **0 failed assertions.**

Immutable benchmarks unaffected — this is a pure animation-timing constant in the visual layer; `Player`'s physics (`_physics_process`, `GRAVITY`, `JUMP_VELOCITY`, etc.) was not touched.

Commit: `autopilot: polish ali run smoothness`.

## Level 1 Polish Autopilot — Milestone 4: Living Idle Motion for Story Characters — STATUS: COMPLETE

Files changed: `scripts/main.gd`.

**Design constraint that shaped this:** Ali's in-world story sprite (`player_story_sprite`) and the NPC containers (`father_npc`, `fatima_npc`, etc.) already have other systems writing to their `scale`/`modulate`/`position` (feet-alignment on texture change, the intro focus-tween, family-group positioning/scaling). Adding a second, independent continuous tween on any of those same properties on the same node risks exactly the "untracked tween fights another tween" bug class this project hit earlier (the menu hero-zoom leak). To avoid that entirely, idle breathing is applied to a **bob in `position.y` only**, and only ever on nodes/properties nothing else currently touches continuously: the existing in-world `*_npc_sprite` child nodes (`fatima_npc_sprite`, `zainab_npc_sprite`, `jomana_npc_sprite`, `father_npc_sprite` — each has its `position`/`scale` set exactly once, at boot, by `apply_optional_character_texture()`, and never again until now) and `player_story_sprite` (whose `position` is only ever set once per pose-change, and stays IDLE/unchanging throughout any story scene).

**Idle breathing:** `_start_idle_breath(sprite)` / `_stop_idle_breath(sprite)` / `_stop_all_idle_breaths()` — a small tracked-tween system (`_idle_breath_tweens`/`_idle_breath_bases` dictionaries keyed by node, following the same kill-before-replace discipline as every other tween in this codebase) that ping-pongs `position.y` by `IDLE_BREATH_BOB = 2.0px` over `IDLE_BREATH_TIME = 1.6s`, `TRANS_SINE`/`EASE_IN_OUT`, looped forever. Started: on `player_story_sprite` + `father_npc_sprite` when the intro begins (`_setup_intro_scene()`); on `player_story_sprite` + whichever helper sprite is active when any checkpoint cinematic opens (`_open_checkpoint_cinematic()`); on each sister's sprite individually inside `_position_family_companion()` only when that sister actually joined (so an unjoined sister's never-visible sprite never gets a pointless background tween). Stopped: intro teardown stops Ali/Father; the master `_reset_checkpoint_encounter_state()` funnel calls `_stop_all_idle_breaths()` unconditionally, so no story scene can ever leave a breathing tween running into gameplay or a later encounter.

**Talking emphasis for checkpoint dialogues:** the intro already had per-step speaker emphasis (`_update_intro_speaker_focus`); checkpoint dialogues (Fatima/Zainab/Jomana/Father reward scenes) had none. Added `_update_checkpoint_speaker_emphasis(role)`, called from `_show_encounter_dialogue_step()` on every dialogue step: the active helper's sprite scales up (`INTRO_FOCUS_SCALE`) and Ali's sprite dims (`INTRO_DIM_ALPHA`) on a `HELPER` line; the reverse on an `ALI` line; both return to neutral on the closing `REWARD` line. Father gets the same heroic asymmetry already built in Milestone 1 for the intro — a warm `FATHER_SPEAKING_TINT` while he speaks, and only the light `FATHER_NON_SPEAKER_DIM_ALPHA` (not the full dim) while Ali speaks — so this milestone is also what extends Father's heroic presence into the ending scene, which Milestone 1 had explicitly deferred. Each sprite's pre-pulse scale is captured lazily into `_checkpoint_speaker_bases` the first time it's needed (these sprites' base scale never changes elsewhere, so the cache never goes stale across Retry/Restart) and that exact tween is killed/replaced on every step via a single tracked `_checkpoint_speaker_tween`.

**Pause correctness:** checkpoint dialogue runs with `get_tree().paused = true` (the intro does not). A tween created with Godot's default pause mode would silently freeze the instant the dialogue opens — exactly the moment this feature needs to be visible. Both new tween types explicitly call `set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)` so they animate regardless of the pause state; this was specifically verified by the smoke test below (which observes a real scale/dim change while `checkpoint_panel` is open and the tree is paused).

**Cleanup:** `_reset_checkpoint_encounter_state()` now also kills `_checkpoint_speaker_tween` and resets every story sprite's `modulate` to `Color.WHITE` and `scale` back to its cached base — so neither a pulsed scale nor a dimmed/tinted modulate can ever leak from one encounter into the next, into Retry/Restart, or into the family-ending scene.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running, `tmp_m4_smoke_test.gd` + its `.uid`): confirmed idle breath starts on Ali+Father at intro start and Ali visibly moves (`>0.5px` position delta) within one breath cycle; confirmed intro teardown stops the tween and resets Father's modulate to pure white; confirmed a live Fatima checkpoint starts idle breath on both Ali and Fatima's sprites; confirmed Fatima's sprite scales up and Ali dims on Fatima's line, then Ali returns to full visibility and Fatima drops out of focus on Ali's own line — **while the tree was paused**, proving the pause-mode fix works; confirmed the full `_reset_checkpoint_encounter_state()` funnel stops every tracked idle-breath tween and restores Fatima's sprite to pure white modulate and its exact cached base scale. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, spawn interval/X, all four speeds) — this milestone is entirely cinematic-presentation code; no physics or `Player._physics_process` logic was touched.

Commit: `autopilot: add subtle idle life to story characters`.

## Level 1 Polish Autopilot — Milestone 5: Cinematic Intro Layout Polish — STATUS: COMPLETE

Files changed: `scenes/Main.tscn`.

**Root cause of the reported overlap:** there is no `Camera2D` in this project (by explicit design — world coordinates map 1:1 to screen pixels), so `father_npc`'s world X (`ENCOUNTER_TARGET_X = 610`) lands directly under the static `NextButton`, which was placed at screen X `516-636`. Vertically, the button sat at Y `420-458`, and Father (now `215px` tall, standing with his feet anchored to `ROAD_SURFACE_Y = 510`) occupies roughly Y `295-510` — the button was squarely inside his torso/chest region the entire time he's on screen, exactly matching the report.

**Fix:** moved `NextButton` down to Y `556-594` (same X `516-636`, same size), placing it well below every character's feet (`ROAD_SURFACE_Y = 510`) on the ground strip in front of them, clear of both Father's and Ali's silhouettes and clear of every dialogue-bubble position the narrator/Ali/Father lines can occupy (`DialogueBubbleHelper` never places a bubble bottom below Y `~318` in this scene, so there is a wide, intentional gap between the lowest bubble and the relocated button). `SkipButton` (top-right, `1016-1136 / 14-50`) was never reported as overlapping anything and was left untouched.

**Composition (Ali on one side, Father as a heroic destination):** left `ALI_STORY_X` (`300`) and `ENCOUNTER_TARGET_X` (`610`) untouched rather than widening the gap further — both constants are shared with every checkpoint encounter (Fatima/Zainab/Jomana/Father all reuse `ENCOUNTER_TARGET_X`, and `_prepare_player_for_encounter()` reuses `ALI_STORY_X` for every cinematic, not just the intro), so changing either would have been a broad, higher-risk change touching code paths well outside "fix the button." The existing `~310px` separation already reads as two distinct sides of the screen with the dialogue centered between them, and Milestones 1 and 4 already added the requested heroic weight (Father's larger `visual_height`, the asymmetric dim/brighten tint, and his idle breathing) without needing to also move him.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running, `tmp_m5_smoke_test.gd` + its `.uid`): computed Father's actual on-screen bounding box from his live `visual_height` and position and confirmed the relocated `NextButton`'s rect no longer intersects it and sits clearly below his feet; confirmed `Next`/`Skip` still drive the intro correctly (Next still advances `intro_step_index`, Skip still ends `intro_active` and reaches gameplay). **0 failed assertions.**

Immutable benchmarks unaffected — this milestone only moved one `Control` node's static offsets in `Main.tscn`; no script logic, physics, or shared world-position constant was touched.

Commit: `autopilot: polish cinematic intro layout and controls`.

## Level 1 Polish Autopilot — Milestone 6: Companion Ribbon Polish — STATUS: COMPLETE

Files changed: `scenes/Main.tscn`.

Enlarged the top-right "رفاق الرحلة" ribbon for readability: label font size `14 -> 17`; each companion icon/placeholder slot `36x36 -> 44x44`; placeholder emoji font size `16 -> 20` to match. The container grew from `200x54` to `220x74` to fit the bigger label/icons with the same internal spacing proportions, but its **right edge stayed pinned at screen X `1136`** (same `16px` margin from the `1152`-wide viewport's right edge as before) — it only grew leftward/downward, so it stays anchored to the same top-right corner and the right margin everyone already expects is unchanged. The three icon slots keep their original right-to-left order (Fatima rightmost, Jomana leftmost) and 8px gaps, just scaled up.

No script logic was touched — `_update_companion_ribbon()` / `_update_companion_slot()` in `main.gd` already drive visibility/texture purely by node reference, so resizing the `.tscn` nodes needed no code changes; retry/restart/checkpoint companion-state logic is completely unaffected.

Validation:

* Headless boot clean, exit 0.
* Smoke test (deleted after running, `tmp_m6_smoke_test.gd` + its `.uid`): confirmed the label's effective font size is now `>14`; confirmed the ribbon's full rect stays inside the `1152x648` viewport (no right/top/left overflow); confirmed all three icon slots grew to at least `40x40` and stay within the ribbon's own bounds; confirmed the existing `_update_companion_ribbon()` flow still toggles the ribbon visible and shows a texture-or-placeholder for each joined companion after the resize. **0 failed assertions.**

Immutable benchmarks unaffected — purely a `.tscn` UI-sizing change with no script/physics involvement.

Commit: `autopilot: polish companion ribbon readability`.

## Level 1 Polish Autopilot — Milestone 7: Audio Structure Polish — STATUS: COMPLETE

Files changed: `scripts/audio/audio_manager.gd`, `docs/AUDIO_CREDITS.md`.

**Why jump/hit sounded like clicks:** their current files (`jump.wav`, `hit.wav`) are both sourced from the **Kenney UI Audio** pack — `switch7.wav` and `click5.wav` respectively, literally generic UI-click sounds, never intended for a runner's jump or an obstacle hit. A separate, already-running sourcing pass (visible in `docs/AUDIO_CREDITS.md`'s "Sourced Candidates Pass 2" section, present before this milestone started) had already found and fully documented two better-fitting CC0 candidates — `jump_option_1` (from "jump-and-run-and-stand" by dklon) and `hit_option_1.wav` (from "jump-landing-sound" by Iwan Gabovitch) — with complete source/author/license metadata, satisfying this project's own established "documented" bar (the same bar every currently-active sound, including `main_theme_soft_loop.ogg`, already meets while still flagged `HUMAN_AUDIO_REVIEW_REQUIRED` for tone).

**Format blocker found and fixed:** `jump_option_1.flac` failed to load (`ResourceLoader.exists` returned `false`, confirmed live via the headless boot log) because **Godot 4 has no built-in FLAC importer** — `.flac` simply cannot become an `AudioStream` in this engine, independent of licensing. Re-encoded it losslessly to PCM16 WAV (`jump_option_1.wav`, via Python's `soundfile`, no audio editing/processing — same bytes, different container) so it can actually load. `hit_option_1.wav` was already a native WAV and needed no conversion. Documented this exact engine limitation and the new `.wav` twin directly in `docs/AUDIO_CREDITS.md` next to the original candidate entry, carrying over the same source/author/license/status.

**Wired cleanly with a swap-ready safety net:** `SOUND_PATHS["jump"]` and `["hit"]` now point at the two candidates. Added `SOUND_FALLBACK_PATHS` (currently `jump -> jump.wav`, `hit -> hit.wav`) and a new `_resolve_sound_path(sound_name)` that tries the preferred path first and only falls back to the documented original if the preferred one genuinely fails to resolve — this is the exact mechanism that caught the `.flac` problem above safely (logged once, no crash, game kept working with the old click sound) before the fix, and is now the standing safety net for any future swap. Swapping any sound later is now just editing one dictionary entry; no other code changes are needed, satisfying "future drop-in replacements are easy."

**Music untouched, on purpose:** a `level1_music_option_1.ogg` candidate also exists, but `docs/AUDIO_CREDITS.md` explicitly marks it `BLOCKED_BY_ASSET` ("download repeatedly timed out... owner must download manually") — not a clean "documented and ready" state like jump/hit. Per this milestone's own instruction ("otherwise keep current behavior"), `main_theme_soft_loop.ogg` stays the active track exactly as v0.95B left it; `AudioManager`'s music path (`_load_music`/`start_music`/`stop_music`/`duck_music`/`unduck_music`, single tracked `_music_player`, no duplicate-player risk) was not touched at all.

Validation:

* Ran `--headless --path . --import` to generate `.import` metadata for the new candidate files, then `--headless --path . --quit` → exit `0`. Boot log directly proves both the bug and the fix: before the WAV conversion it printed `preferred sound missing for jump; using documented fallback -> .../jump.wav` (graceful, no crash); after the conversion it prints `loaded: jump -> .../jump_option_1.wav` and `loaded: hit -> .../hit_option_1.wav`.
* Smoke test (deleted after running, `tmp_m7_smoke_test.gd` + its `.uid`): confirmed `_resolve_sound_path()` returns the preferred candidate for both `jump` and `hit`; confirmed every entry in `SOUND_FALLBACK_PATHS` independently resolves to a real, loadable `AudioStream` (Godot's import cache makes deleting a file post-import an unreliable way to re-trigger the fallback path in a test, so this checks the fallback *targets* are themselves always healthy, while the actual fallback *trigger* was already proven for real by the `.flac` incident above); confirmed `start_music()` called twice still produces exactly one music `AudioStreamPlayer` (no duplicate-player regression); confirmed a live jump and a live hit both play without error during gameplay. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep — this milestone only touched audio loading/credits; no physics, spawn, speed, or checkpoint constant exists in the changed files.

Commit: `autopilot: polish audio structure and replacement readiness`.

## Level 1 Polish Autopilot — Milestone 8: Final Polish Pass and Report — STATUS: COMPLETE

Files changed: `docs/AUTOPILOT_PROGRESS.md` only.

Final headless boot: clean, exit `0`, no parser/runtime errors.

Final comprehensive smoke test (deleted after running, `tmp_m8_final_smoke_test.gd` + its `.uid`) drove one continuous `Main.tscn` instance through every system touched by this sprint, in order: start screen visible at boot → Play opens the intro → Skip ends it and reaches gameplay → player lands on the floor and runs → a real Fatima checkpoint triggered the same way gameplay triggers it (`score = 14` then `_on_obstacle_passed()`, not a direct internal call) → checkpoint panel opens, dialogue advances to its final reward step, Fatima's `+5` bonus applies correctly (`score 15 -> 20`), the companion ribbon becomes visible → Continue resumes gameplay through the countdown at the correct post-Fatima speed → a real Game Over via `_end_run()` (not a raw `player.kill()`, which only kills the sprite and does not set the game's own `game_over` state) sets `game_over` and shows the Game Over label → Retry restores score `20` and Fatima's companion flag → Restart from Beginning resets score to `0`, clears every companion flag, and hides the ribbon again → a Father ending triggered with all three sisters flagged as joined shows all three sister NPCs and Father himself visible together in the family group. **0 failed assertions** after two test-only bugs were found and fixed (first attempt mistakenly bypassed the real score-trigger and real game-over state-machine entry points and was correctly diagnosed as a test flaw, not a regression, before being fixed).

Immutable constants reconfirmed via grep across every script touched this sprint (`player.gd`, `player_visual.gd`, `obstacle_spawner.gd`, `difficulty_manager.gd`, `encounter_data.gd`, `main.gd`): gravity `1050`, jump velocity `-440`, max fall speed `700`, jump buffer `0.12`, road surface Y `510`, spawn interval `2.25`, spawn X `1292`, speeds `225/240/255/270`, checkpoint trigger scores `15/35/60/90` — all unchanged across all eight milestones.

No temporary smoke-test scripts or `.gd.uid` files remain in the working tree from this sprint.

### Sprint summary (all 8 milestones complete)

1. Character scale + Father heroic presentation (`autopilot: polish character scales and father presentation`)
2. Black-rectangle shadow fix (`autopilot: remove ali foot artifact and clean shadow`)
3. Run smoothness (`autopilot: polish ali run smoothness`)
4. Living idle motion (`autopilot: add subtle idle life to story characters`)
5. Cinematic intro layout (`autopilot: polish cinematic intro layout and controls`)
6. Companion ribbon polish (`autopilot: polish companion ribbon readability`)
7. Audio structure polish (`autopilot: polish audio structure and replacement readiness`)
8. Final polish pass and report (this entry)

### Remaining human-only items (unchanged scope from before this sprint)

* Listen to and approve/remap/reject every integrated SFX, `main_theme_soft_loop.ogg`, and the two newly-active jump/hit candidates (all still `HUMAN_AUDIO_REVIEW_REQUIRED` for tone/loudness, even though all are now license-documented and code-safe).
* `level1_music_option_1.ogg` remains `BLOCKED_BY_ASSET` per `docs/AUDIO_CREDITS.md` — needs a manual re-download before it can even be considered.
* `hit_soft_impact.wav` and ambience (city/birds/wind) remain undocumented/missing and were correctly left untouched.
* Check Arabic RTL rendering/readability and overall visual feel in a real F6 session — nothing in this sprint can substitute for an owner's eyes on the actual running game.

Recommended next task: **v1.35 — Roadmap Refresh and Level 2 Planning**, once the owner has completed the human-only audio/visual review above.

## Post-Sprint Hotfix: Ali Floating After Checkpoints + Oversized Land Pose

Files changed: `scripts/main.gd`, `scripts/player_visual.gd`.

The owner reported, with screenshots, that Ali visibly rose up off the road after meeting Fatima, and again after Zainab. Separately, the owner reported `ali_land.png`'s landing pose looked oversized and "messed up."

### Root cause 1: leaked idle-breath tween after a checkpoint's Continue

The idle-breath tween added in this same sprint (Milestone 4) is started on `player_story_sprite` when a checkpoint cinematic opens (`_open_checkpoint_cinematic()`), and its cleanup was only wired into `_reset_checkpoint_encounter_state()` — the function used by a full Retry/Restart. The normal "Continue → countdown → resume running" path (`_finish_encounter_and_countdown()`) never called it, so the tween kept running into live gameplay, periodically rewriting `player_story_sprite.position` from a stale story-scene baseline while `player.gd`'s own per-frame run-pose layout was simultaneously writing the correct gameplay-scene position to the same property — the two fought, and the visible symptom was Ali snapping to/from an incorrect vertical offset while running. This exactly matches the owner's own diagnostic observation: Retry "fixed" it because Retry happens to go through the one path that already stopped the tween; Continue did not.

Fixed by extracting the existing cleanup block (`_stop_all_idle_breaths()`, killing `_checkpoint_speaker_tween`, resetting modulate/scale on every story sprite) out of `_reset_checkpoint_encounter_state()` into a new shared `_cleanup_checkpoint_speaker_state()`, and calling it from **both** `_reset_checkpoint_encounter_state()` and `_finish_encounter_and_countdown()` — the same "shared funnel" discipline this project has used for every other piece of cinematic state all sprint, applied correctly this time to cover the path that was missed.

Validation: a smoke test drove a real Fatima checkpoint (`REVEAL` arrival) and a real Zainab checkpoint (`ENTER` arrival, which needs real travel time before its cinematic opens — the first test attempt under-waited and was corrected) end to end and read `player.global_position.y` (the actual world Y, not the sprite's local layout offset that an earlier, less precise test attempt was mistakenly checking) immediately after Continue and across several seconds of subsequent running. Result: `486.0` (= `START_PLAYER_POSITION.y`, the correct gameplay road height) every time, after both checkpoints. **0 failed assertions.**

### Root cause 2: ali_land.png's aspect ratio breaks pure height-normalization

Measured the actual current file with PIL: `ali_land.png`'s visible character art is `239x241px` — nearly square — while every other Ali pose is tall/thin (idle `189x474`, run frames `~385-426x513`). The shared height-only normalization formula (`VISUAL_HEIGHT / visible_rect.size.y`) scales every pose to the same `100px` height regardless of its native proportions; for a nearly-square source, that forces the on-screen width out to nearly `100px` too — about 30-35% wider than every running/idle frame — reading exactly as the reported "oversized, messed up" landing crouch.

This is the same bug class v1.26A diagnosed and fixed earlier in the sprint (for the old `ali_land.png` and a run-frame issue) before v1.34 removed all overrides to fix a *different*, real bug (inconsistent numeric overrides forced onto run frames, causing a run-cycle size pulse). v1.34's fix was correct for the run-frames; removing the LAND override along with it was not, and the owner has since re-edited `ali_land.png`, so even if the old override value had been kept it would no longer have been correct for the new art.

Re-added a minimal, single-entry `POSE_SCALE_OVERRIDES := {LAND: 0.33}` (freshly measured for the *current* file, not reused from before), threaded through `_apply_texture()`/`_calculate_texture_layout()`'s existing optional-override parameter (the same plumbing v1.26A originally added and v1.34 removed), applied **only** via `show_pose()` for named poses — explicitly not touched in the run-frame-cycling path in `update_visual()`, so the run-frame pulsing bug v1.34 fixed cannot regress.

Validation: a smoke test forced `show_pose(LAND, true)`, confirmed the texture actually in use is the real LAND texture (not a fallback), and measured its final on-screen size directly: `w=78.87px, h=79.53px` — comfortably inside a 50-90px sanity band, no longer ballooning toward `100x100`. Confirmed via the same test that LAND's feet still align with idle's feet baseline (no new floating from this change).

Immutable constants unaffected — both fixes are cinematic-tween cleanup and a per-pose visual scale constant; no physics/collision/spawn/speed/checkpoint value was touched. Reconfirmed via grep.

Commit: `autopilot: fix ali floating after checkpoints and oversized land pose`.

## v1.36A + v0.95C — Dynamic Music, Arabic Dialogue Layout, RTL Polish, Checkpoint Retest — STATUS: COMPLETE

Files changed: `scripts/audio/audio_manager.gd`, `scripts/main.gd`, `scripts/ui/dialogue_bubble_helper.gd`, `scripts/story/encounter_data.gd`, `scenes/Main.tscn`.

### Task A — Dynamic music state machine

**`level1_exciting_loop.ogg` was NOT integrated — BLOCKED_BY_AUDIO_DOCUMENTATION.** Checked both `docs/AUDIO_CREDITS.md` and `docs/AUDIO_ASSET_SOURCING_REPORT.md` first, as instructed: neither has a source/license entry for it. `docs/AUDIO_DESIGN_PLAN.md` already explicitly flags it `UNVERIFIED_AUDIO_CANDIDATE` and says not to integrate until license-verified and owner-approved by ear. Per this task's own gate, the code does not load this file at all and logs `BLOCKED_BY_AUDIO_DOCUMENTATION` once if anything ever asks for it.

`AudioManager` now owns a small named-track music state machine instead of one hardcoded path: `MUSIC_TRACK_PATHS := {"calm": main_theme_soft_loop.ogg}` (only `calm` registered, since `gameplay` is blocked). `main.gd` only calls high-level state methods, exactly as required: `play_calm_music()`, `play_gameplay_music()`, plus the existing `duck_music()`/`unduck_music()`/`stop_music()` kept available. `play_gameplay_music()` checks whether a `"gameplay"` track is registered; since it isn't, it logs the block once and falls back to `play_calm_music()` — the exact same missing-file-safety pattern already used for SFX, just applied to music tracks. The moment `level1_exciting_loop.ogg` is properly documented, integrating it is a one-line addition to `MUSIC_TRACK_PATHS` — no other code changes needed.

`_switch_music(key)` is a single shared function: if the target track isn't already playing, it starts immediately at `MUSIC_VOLUME_DB`; if a different track is already playing, it crossfades (fade to `MUSIC_DUCK_DB` over `0.35s`, swap stream, fade back to `MUSIC_VOLUME_DB` over `0.35s`) using one tracked `_music_volume_tween` (killed/replaced every call, same discipline as every other tween in this project). There is still exactly one `AudioStreamPlayer` for music — switching tracks reassigns its `.stream`, never creates a second player.

Call sites replaced in `main.gd` (one line each, no control-flow changes): `_show_start_screen()` (menu) and `_start_intro()` (intro) → `play_calm_music()`; `_open_checkpoint_cinematic()` (any checkpoint dialogue, including Father's) → `play_calm_music()`; `_finish_encounter_and_countdown()` (the 3-2-1 countdown itself, still not running) → `play_calm_music()`; `_finish_countdown()` (the exact moment `obstacle_spawner.start_spawning()` is called and the player actually starts running again) → new `play_gameplay_music()` call added; `_begin_run()` (the shared funnel for Restart/Retry/post-intro start, all of which resume running immediately with no countdown gate) → `play_gameplay_music()`; `_end_run()` (Game Over) → `play_calm_music()`.

### Task B — Jomana dialogue overflow fixed

Root cause: `checkpoint_card`'s actual runtime size/position is reassigned on every dialogue step by `_position_dialogue_bubble_for_speaker()` from `DialogueBubbleHelper.BUBBLE_SIZE` — the `.tscn`'s static `Card` offsets are cosmetic only and get overwritten before any text is ever shown. Separately, `CharacterLine` and `RewardLabel` (unlike `AliLine`) never had `autowrap_mode` set at all, so Jomana's unusually long HELPER line ("قريب وصلت يا علي… لكن لازم تختار الطريق الصح.") rendered as one un-wrapped line wider than the card.

Fixed both: `BUBBLE_SIZE` in `dialogue_bubble_helper.gd` grew from `(480, 160)` to `(480, 182)` (the actual runtime-controlling value), and `CharacterLine`/`RewardLabel` gained `autowrap_mode = 2` (matching `AliLine`'s existing setting) plus `clip_text = true` on all three as a hard guarantee against any future overflow. `NextHint`/`ContinueButton` were shifted down to match the taller card. The static `.tscn` `Card` offsets were also bumped to match for editor-preview accuracy, even though they're not load-bearing at runtime.

### Task C — RTL/BiDi punctuation fix

Added `EncounterData.rtl_safe(text)`, wrapping a sentence in Unicode RLM marks (`‏`) so trailing/leading neutral characters (periods, em dashes, the already-correct Arabic ellipsis "…") are anchored to a strong RTL context instead of an ambiguous bidi guess — applied only at the four actual dialogue-display assignment points (`_show_encounter_dialogue_step()`'s `text` read, `_show_intro_step()`'s `intro_line.text`, both `game_over_message.text` assignments in `_show_game_over_options()`), never to the source dialogue data itself, never to `score_label`, speaker names, or button text. All dialogue strings already used the Arabic ellipsis "…" (no ASCII `"..."` anywhere) — nothing to change there.

**Real bug found and fixed mid-task:** the first attempt used the literal RLM character directly in the GDScript string literal, which Godot's parser explicitly rejects as a Trojan-Source-style safety check ("Invisible text direction control character present in the string, escape it"). This broke every script that depends on `encounter_data.gd` (cascading parse failures across the whole project) — caught immediately by the required headless boot check, not shipped. Fixed by using the escaped `‏` form instead of the literal character.

### Task D — Retested Ali land + post-checkpoint height

Re-confirmed the previous hotfix is still solid, now also covering Jomana (the third checkpoint, not just Fatima/Zainab tested before): `ali_land`'s `POSE_SCALE_OVERRIDES` calibration is still active and renders at `~79x80px` (not the broken `~100x100`); `player.global_position.y` returns to exactly `START_PLAYER_POSITION.y` (`486.0`) after Jomana's checkpoint and stays stable across several seconds of subsequent running; the idle-breath/speaker-emphasis cleanup (`_cleanup_checkpoint_speaker_state()`) is confirmed still wired into both `_finish_encounter_and_countdown()` and `_reset_checkpoint_encounter_state()`. No regression found; no further lifecycle changes were needed.

### Validation

* Headless boot clean, exit `0`, no parser/runtime errors (after fixing the RLM literal-character parse error above).
* One comprehensive smoke test (deleted after running, `tmp_v136a_smoke_test.gd` + its `.uid`) covering, in one continuous run: menu calm music; intro stays calm; gameplay-start correctly falls back to calm with the blocked-track log line printed; a real Jomana checkpoint (driven via `_on_obstacle_passed()`, not a direct internal call) opens with calm music, its dialogue text exactly matches the expected RLM-wrapped string, has `autowrap_mode` enabled, and its rendered label width fits inside the card width; `score_label` confirmed NOT RLM-wrapped; post-Jomana world Y returns to and stays at `486.0`; `ali_land` still renders at the calibrated small size; Game Over switches to calm with the single music player still playing (not stopped/duplicated); Retry correctly falls back to calm (since gameplay track is blocked); exactly one music-stream `AudioStreamPlayer` exists in the whole scene throughout. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, spawn interval/X, all four speeds, all four checkpoint trigger scores). Father's ending phrase, reward logic, retry/restart logic, obstacle behavior, and companion state rules are byte-for-byte unchanged in `encounter_data.gd` (confirmed via diff — the only change to that file is the addition of the `rtl_safe()` helper itself).

### Remaining human review items (unchanged)

* Listen to and approve/remap/reject every integrated SFX and `main_theme_soft_loop.ogg` (still `HUMAN_AUDIO_REVIEW_REQUIRED`).
* `level1_exciting_loop.ogg` remains `BLOCKED_BY_AUDIO_DOCUMENTATION` — needs a source/license entry in `docs/AUDIO_CREDITS.md` before it can even be considered for `play_gameplay_music()`.
* F6 visual check of the wider checkpoint card and the RTL punctuation fix is still recommended, even though both are validated structurally/mechanically here.

Commit: `autopilot: v1.36A dialogue RTL polish and v0.95C dynamic music`.

## v1.36B — Smooth Ali Run Animation System and 8-Frame Prep — STATUS: COMPLETE

Files changed: `scripts/player_visual.gd`, `scripts/player.gd`.

### Task A — Inspection findings

`RUN_ANIMATION_FPS` was `13.0`. Run frames were discovered via a **fixed 4-entry array** (`RUN_FRAME_PATHS`, exactly `ali_run_1.png`..`ali_run_4.png`, with a legacy `ali_run1.png`-no-underscore fallback for frame 1 only), loaded once in `_load_run_frames()` at `_ready()` — no per-frame loading. Texture layout (scale + position) is computed once per unique `Texture2D` and cached in `_texture_layouts`, normalizing every pose to the same visible-bbox height (`VISUAL_HEIGHT = 100`) with feet pinned to a fixed local `FEET_Y = 24`, plus an optional per-pose `scale_override` (used today only for `LAND`). The system could **not** already support 6 or 8 frames — the array length was hardcoded at 4.

### Task B — Variable frame count (1-8) with safe fallback

Replaced the fixed array with `RUN_FRAME_PATH_TEMPLATE` + `RUN_FRAME_COUNT_MAX = 8`. `_load_run_frames()` now scans `ali_run_1.png` upward; the very first missing index **stops** the scan (one log line, not a skip-and-continue), so `4` frames today yields exactly `4` in order, and adding `ali_run_5..8.png` later is picked up automatically with zero code changes. Still loaded exactly once at `_ready()`. The existing fallback chain beneath the numbered frames (`ali_run.png` → `ali_idle.png` → blue placeholder) was already correct and untouched.

### Task C — Smoothing the current 4-frame run

* `RUN_ANIMATION_FPS`: `13.0 -> 14.0` (top of the suggested 12-14 range).
* Confirmed (did not need to change) that the frame timer/index already does **not** reset during continuous grounded running: `show_pose()` only calls `_reset_run_animation()` when the *requested* pose is not `RUN`, and while continuously running every `show_pose(RUN)` call hits the `pose == current_pose` early-return before reaching any frame-changing code. The timer only resets while airborne/landing (every frame, since those poses aren't `RUN`), so the run cycle always restarts cleanly at frame 0 after a jump/land — confirmed this is the appropriate behavior, not a bug, and left it alone.
* Added `RUN_FRAME_Y_OFFSETS` (currently `{0: 0.0, 1: -1.5, 2: 0.0, 3: -1.5}`px) — a tiny per-frame vertical bob applied as an *additive* nudge on top of `_apply_texture()`'s normal feet-aligned `scale`/`position`, via a new `_apply_run_frame(frame_index)` helper now used by both the run-entry path and the per-frame cycling loop. Because this only ever adds a small fixed offset to an already-correct base position - never touches `scale` - it cannot reintroduce the size-pulse or feet-baseline bugs fixed earlier (those were caused by *scale* varying per frame/pose, not a position nudge).
* Added `RUN_FRAME_ROTATION` (empty dict, all frames default to `0.0`) - the plumbing exists, but no frame was given a non-zero lean: rotating a centered sprite pivots around its center, not its feet, so turning this on needs an owner-reviewed visual pass first to confirm feet don't appear to lift/slide. Left at the safe default rather than guessing.

### Task D — 8-frame readiness

Code-ready: `RUN_FRAME_COUNT_MAX = 8`, the scan loop, and `RUN_FRAME_Y_OFFSETS`/`RUN_FRAME_ROTATION`'s `.get(frame_index, default)` lookups all already generalize past frame 4 with no further changes. Added explicit comments in `player_visual.gd` stating: 4-frame run is fully supported today; 8-frame run is the preferred target for the smoothest final feel; any new frames must share the same canvas size and feet-baseline (alpha-trim bottom-edge) convention as the existing four, since that consistency is exactly what the visible-bbox normalization in `_calculate_texture_layout()` depends on.

### Task E — Dust contact timing

Added `AliPlayerVisual.contact_frame_indices(frame_count)` (static): a real running stride has exactly two ground-contact events per cycle regardless of frame count, so this always returns `[0, frame_count/2]` — `[0, 2]` for today's 4 frames, `[0, 4]` once 8 exist. `player.gd` gained `_play_run_contact_dust()`, called once per frame-index-change while running, which fires the existing one-shot `_impact_dust` burst (already used for jump/land/Game Over - no new particle system) only when the new frame index is a contact frame. This is **additive** on top of the existing continuous `_run_dust` trail from v1.2B, not a replacement, so the already-shipped/validated dust look is unchanged; it just gets a small extra accent on footfall. `_last_run_contact_frame` resets to `-1` whenever airborne/landing so a stale frame-index comparison can never carry over incorrectly between runs.

### Validation

* Headless boot clean, exit `0`. Boot log confirms the new scan behavior precisely: frames 1-4 load, frame 5 is reported missing exactly once (`"frame 5 missing; using 4 frame(s) for the run cycle"`), then `"using 4 cached run frames at 14.0 FPS"` — no per-frame spam.
* Smoke test (deleted after running, `tmp_v136b_smoke_test.gd` + its `.uid`): confirmed exactly 4 frames detected; confirmed the run-frame index advances past 0 during continuous running and the player never leaves the floor while doing so (no spurious reset/airborne flicker); confirmed feet Y stays within 4px across 20 sampled run frames despite the new bob offsets (i.e. the bob is additive and bounded, not destabilizing); confirmed jump/fall/land still transition correctly; confirmed `ali_land` still renders at the calibrated small size (not the old oversized ~100x100); confirmed a real Zainab checkpoint still returns `player.global_position.y` to exactly `START_PLAYER_POSITION.y` and holds it across several seconds of subsequent running (no floating regression). **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four speeds, all four checkpoint trigger scores). `Player`'s `CharacterBody2D` position/collision shape was never touched - only the child `AliSprite`'s cosmetic `position.y`/`rotation` gained the new tiny per-frame nudges.

### Owner F6 visual checklist

1. Watch a sustained run (no jumping) and judge whether the 14 FPS + 2px bob reads as noticeably smoother than before, or still choppy enough to prioritize commissioning real 8th-frame art.
2. Confirm the small extra dust puffs on footfall read as a nice accent, not as "too much" dust.
3. Confirm landing still looks correct (small crouch, not oversized) immediately after a jump.
4. If/when `ali_run_5.png`..`ali_run_8.png` are produced: use the **same canvas size and feet-baseline convention** as the current 4 frames (see the comments added in `player_visual.gd`) so they drop in with zero code changes.

Commit: `autopilot: v1.36B smooth Ali run animation system`.

## Roadmap Sync + Owner-Authorized Exciting Music — 2026-06-29

Roadmap/documentation status was synchronized with the completed Level 1 polish sprint, v1.36A, and v1.36B. Level 1 remains `AUTOMATED GOLD CANDIDATE / OWNER VISUAL AND AUDIO REVIEW REQUIRED`, not Final Gold.

Documented as `IMPLEMENTED / OWNER F6 RETEST REQUIRED`:

* Fatima scale `72`, Father height `215` and heroic emphasis.
* Soft oval shadow cleanup.
* Current `14 FPS` run smoothing and 1-8 frame readiness.
* Living story-character idle motion and cleanup.
* Intro `التالي` layout fix.
* Enlarged companion ribbon.
* Safe documented jump/hit replacement paths.
* v1.36A Jomana wrapping and RTL punctuation handling.
* LAND calibration and post-checkpoint-height cleanup.

Owner decision recorded: `OWNER_DECISION_KEEP_CURRENT_FATHER_LINE`.

### Exciting music authorization and activation

The owner explicitly approved using `res://assets/audio/music/level1_exciting_loop.ogg` in the project. Added it as the `gameplay` entry in `AudioManager.MUSIC_TRACK_PATHS`; all existing state call sites remain unchanged. Calm music owns menu/story/checkpoint/Game Over/countdown states, while the exciting track now owns active running gameplay. Missing/failed gameplay-track loading still falls back to calm music.

Godot 4.7 headless boot exited successfully and logged both tracks as loaded:

* `calm -> res://assets/audio/music/main_theme_soft_loop.ogg`
* `gameplay -> res://assets/audio/music/level1_exciting_loop.ogg`

No parser/runtime loading error occurred. Abrupt headless shutdown printed the existing audio-resource cleanup warnings; these do not indicate a failed load.

Review status:

* `HUMAN_AUDIO_REVIEW_REQUIRED` for both tracks and their crossfade/volume/mood.
* `OWNER_AUTHORIZED_LOCAL_USE / LICENSE_VERIFICATION_REQUIRED_BEFORE_PUBLIC_RELEASE` for `level1_exciting_loop.ogg`, because its exact external source/license is still not recorded.
* No gameplay, physics, collision, scene, checkpoint, obstacle, reward, or story-text behavior changed.

## v1.36C — Diagnose and Fix Ali 8-Frame Run Jitter — STATUS: COMPLETE

Files changed: `scripts/player_visual.gd`.

The owner added real `ali_run_1`(as `ali_run1.png`)..`ali_run_8.png` art since v1.36B. All 8 are now detected and used. This task measured the *actual* runtime numbers (not a guess) to find the real cause of the reported shake.

### Task A — Measured diagnostics (Godot-side, via a temporary diagnostic script, deleted after use)

| frame | canvas | visible bbox (x,y,w,h) | scale | base pos.x | base pos.y | feet world Y |
|---|---|---|---:|---:|---:|---:|
| 1 | 289x451 | 15,12,252,420 | 0.2381 | +0.83 | -25.17 | 24.0000 |
| 2 | 238x411 | 27,6,203,402 | 0.2488 | -2.36 | -26.37 | 24.0000 |
| 3 | 255x411 | 4,2,248,403 | 0.2481 | -0.12 | -25.50 | 24.0000 |
| 4 | 275x414 | 11,8,248,400 | 0.2500 | +0.62 | -26.25 | 24.0000 |
| 5 | 281x432 | 10,10,261,411 | 0.2433 | +0.00 | -25.88 | 24.0000 |
| 6 | 222x423 | 26,41,183,379 | 0.2639 | -1.72 | -31.01 | 24.0000 |
| 7 | 234x436 | 21,31,213,392 | 0.2551 | -2.68 | -28.30 | 24.0000 |
| 8 | 208x425 | 3,10,197,398 | 0.2513 | +0.63 | -25.12 | 24.0000 |

**Answers to the required diagnostic questions:**

1. **All 8 frames detected?** Yes, confirmed live in the boot log (`"using 8 cached run frames at 14.0 FPS"`).
2. **Consistent canvas size?** No — ranges from `208x425` to `289x451`. Already known/expected (every pose in this project has a different native canvas) and exactly what the height-normalization system was built to handle.
3. **Consistent visible feet baseline?** Yes, mathematically — `_calculate_texture_layout()`'s feet-pinning formula lands every single frame's feet at exactly `FEET_Y = 24.0`, verified to 4 decimal places for all 8 frames. Feet/vertical alignment was **not** the source of the shake.
4. **Different scale per run frame?** Yes — `0.2381` to `0.2639` (~10.8% spread). This is the intended, correct behavior of per-frame height normalization, not a bug.
5. **Is the fake Y bob causing/amplifying jitter?** **Yes - confirmed, and this was a real bug.** `RUN_FRAME_Y_OFFSETS` (`{0:0, 1:-1.5, 2:0, 3:-1.5}`) was written for the old 4-frame cycle and kept applying to frame indices 0-3 of the *new* 8-frame cycle (since nothing in v1.36B gated it by frame count), while indices 4-7 got no offset at all (default `0.0`). That produced an asymmetric, art-uncorrelated bob pattern stacked on top of an already-perfectly-pinned feet baseline.
6. **Any frame visually too high/low/wide/narrow vs the rest?** **Yes — frame 6 is a clear outlier.** Its visible height (`379px`) is the smallest of all 8 (others range `392-421`), its top-crop margin (`41px`) is far larger than any other frame (others range `2-31px`), and its width-to-height ratio (`0.483`) is noticeably narrower than its neighbors (frame 5: `0.635`, frame 7: `0.544`).

**The real, measured, separate cause of horizontal shake:** each frame's *own* alpha-bbox horizontal center (`base pos.x` column above) varies by up to **3.31px** frame-to-frame. At `14 FPS` that's a visible left-right alternation every ~70ms — the classic feel of "shaking," independent of the Y-bob bug.

### Task B — Fixes applied (code only, no asset edits)

1. **Y-bob gated off for 8-frame mode.** Added `RUN_FRAME_Y_OFFSET_MAX_FRAME_COUNT = 4` and `_run_frame_y_offset(frame_index)`: returns `0.0` whenever `run_frame_textures.size() > 4`. The legacy 4-frame fallback keeps its bob unchanged; the real 8-frame cycle now relies entirely on the already-correct feet-pinning math.
2. **Horizontal jitter fixed with a shared X anchor.** Added `_compute_run_frame_x_anchor()`, called once after all run frames load: averages every frame's own natural `position.x` (via the existing, unmodified `_calculate_texture_layout()`) into one `_run_frame_x_anchor`. `_apply_run_frame()` now sets `position.x` to this single anchor for every run frame instead of each frame recomputing its own noisy bbox-center `x`. Vertical/feet math is untouched.
3. Confirmed (no change needed): the run-frame timer/index still does not reset during continuous grounded running, and jump/fall/land still reset it cleanly only on an actual pose change.
4. `ali_land`'s `POSE_SCALE_OVERRIDES` calibration is separate code and was not touched.

### Task C — Visual size: OWNER_VISUAL_DECISION_REQUIRED

`VISUAL_HEIGHT` (`100px`) was left unchanged — "does Ali feel too small" is a subjective readability call only the owner can make by eye, and this task explicitly allows deferring it. Testing `105-110px` later is a single-constant change in `player_visual.gd`; it does not touch collision or the feet-pinning math.

### Task D — Debug isolation: which factor was actually responsible

* **Asset frame alignment:** Yes, contributing — frame 6 is a measured outlier, and all 8 frames' bbox centers vary enough to need the X-anchor fix.
* **Code Y offsets:** Yes, confirmed as a real bug — fixed (Task B.1).
* **Scale recalculation:** Working as designed — per-frame scale variation is intended height-normalization; feet land at exactly `24.0` regardless.
* **Dust/shadow illusion:** Ruled out — `_run_dust`/`_ground_shadow` are anchored to `Player`'s local origin, independent of the run sprite's per-frame transform.
* **FPS/cadence:** Not the root cause, only a multiplier of how perceptible the positional noise is; left at `14 FPS` since the real fix is removing the noise (Task B), not slowing its display.
* **Visual size in scene:** No evidence connecting `100px` to the shake; deferred separately (Task C).

### Task E — Asset guidance

**ASSET_REWORK_RECOMMENDED: `ali_run_6.png`** — its visible height (`379px`) and top-crop margin (`41px`) are clear outliers vs. its 7 siblings; recrop/regenerate with the same top-margin convention as the other frames.

General note for any future regeneration: `ali_run_1..8` should ideally share the same canvas size, the same transparent padding, and the same horizontal torso placement within their canvas (not just the same feet baseline) — the code-side X-anchor fix compensates for today's inconsistency, but a torso-centered source crop would remove the need for that compensation entirely.

### Validation

* Headless boot clean, exit `0`. Boot log confirms `"using 8 cached run frames at 14.0 FPS x_anchor=-0.599"`.
* Smoke test (deleted after running, `tmp_v136c_smoke_test.gd` + its `.uid`): confirmed 8 frames detected; confirmed all 8 frame indices are actually visited during continuous running with the player never leaving the floor; confirmed feet Y stays within `1px` across 40 sampled frames; confirmed horizontal position stays within `0.5px` across the same 40 samples (the actual jitter fix, directly verified); confirmed the Y-offset helper returns exactly `0.0` for every index now that 8 frames are active; confirmed jump/fall/land still transition correctly; confirmed `ali_land` still renders at its calibrated small size; confirmed a real Fatima checkpoint still returns `player.global_position.y` to exactly `START_PLAYER_POSITION.y`. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four speeds, all four checkpoint trigger scores). `scripts/player.gd` was not touched at all this task.

### Owner F6 checklist

1. Watch a sustained run and confirm the left-right "shake" is gone or much less noticeable.
2. Confirm there's no new visible vertical bounce now that the 4-frame bob is off for the 8-frame cycle.
3. If frame 6 still looks like a visible "blip" in the cycle, that's the flagged `ASSET_REWORK_RECOMMENDED` item.
4. Decide whether `100px` gameplay height still feels right, or test `105-110px` (`OWNER_VISUAL_DECISION_REQUIRED`).

Commit: `autopilot: v1.36C fix Ali 8-frame run jitter`.

## v1.36D — Scene Framing, Road Fill, and Gameplay Zoom Polish — STATUS: COMPLETE

Files changed: `scripts/main.gd`, `scenes/Main.tscn`.

### Task A — Diagnosis (measured, not guessed)

* **Ground/road visual Y range:** `ground_sprite` only drew from `y=470` (`CURB_TOP_Y`) to `y=550` (`470 + GROUND_VISUAL_HEIGHT`, which was `80.0`).
* **Bottom gap:** `y=550` to `y=648` (`VIEW_H`) - a full **98px**, ~15% of the screen height, was uncovered by any sprite.
* **Forced to a short height?** Yes, confirmed: `_apply_ground_texture()` called `ASSET_UTILS.fit_sprite_visible_to_size(ground_sprite, VIEW_W, GROUND_VISUAL_HEIGHT)`, which independently forces *both* width and height.
* **Aspect ratio preserved?** No. Measured the actual texture (`ground_mantarha.png.png`): canvas `2172x334`, visible bbox height `293px` → native aspect ≈ `7.41:1`. Forced into `1152x80` gives ≈ `14.4:1` - roughly **2x vertically squashed** versus its native proportions.
* **Cause of the flat brown strip:** `Ground/GroundBase` (a `Polygon2D`, `z_index=-1`, color `Color(0.42,0.36,0.28,1)`) spans the *entire* lower area (`y=470` to `y=648`, matching the invisible collision extent) as a permanent fallback fill. It was never the problem on its own - it only became visible as a giant flat block because `ground_sprite` covered just the top `80px` of that same area, leaving the rest of `GroundBase`'s flat color exposed.
* **Cause of the buildings/road seam:** `buildings_sprite`/`foreground_sprite` and `ground_sprite` both align their edges to exactly `CURB_TOP_Y=470` (one bottom-aligned, one top-aligned) - mathematically touching with zero overlap. At that kind of razor-thin meeting line, alpha-edge antialiasing on either texture reads as a thin visible seam/gap rather than a clean join.

### Task B — Road/ground visual fill (fixed)

Switched `_apply_ground_texture()` from `fit_sprite_visible_to_size()` (forced, aspect-distorting) to `fit_sprite_visible_to_width(ground_sprite, VIEW_W)` - the same aspect-preserving call already used for `buildings_sprite`/`foreground_sprite`. At `VIEW_W=1152`, this now naturally renders the road at `~155px` tall (confirmed live in the boot log: `final_scale=(0.530387, 0.530387)`, visible height `293*0.530387≈155.4px`) instead of the forced `80px` - **nearly double**, without any distortion. `GROUND_VISUAL_HEIGHT` was updated `80.0 -> 155.0` to match (it now only sizes the no-texture placeholder polygon and the log line; the real sprite derives its own height from the texture). `ROAD_SURFACE_Y`, the collision `RectangleShape2D`, and `GROUND_COLLISION_HEIGHT` were **not touched** - this is purely the visible sprite's drawn height. The remaining ~23px gap between the new road bottom (~625) and the screen edge (648) is covered by `GroundBase`'s existing brown fill, whose color was nudged from `(0.42,0.36,0.28)` to `(0.49,0.36,0.25)` to match the road texture's own measured bottom-edge average color (`(0.49,0.36,0.23)`, sampled directly from the PNG) - so what remains reads as an intentional dirt/road-shoulder color continuation, not a mismatched flat block.

### Task C — Buildings/road gap (fixed)

Added `BG_GROUND_OVERLAP := 10.0`. `_apply_scenery_layer()` now aligns `buildings_sprite`/`foreground_sprite`'s visible bottom to `CURB_TOP_Y + BG_GROUND_OVERLAP` (`480` instead of `470`) - confirmed live in the boot log (`"BuildingsSprite visible_bottom=480.0"`). Since `ground_sprite` starts drawing at `y=470` with a higher z-index (`0`) than the background layers (`-20`/`-10`), the top `10px` of the now-lower-extending background layers tuck cleanly underneath the top of the road sprite instead of meeting it at an exposed seam. Parallax motion (`background_motion.gd`) reads each sprite's `position`/`region`, not this alignment constant, so scrolling is unaffected.

### Task D — Light gameplay zoom/framing

**Camera2D was used** (not a manual world-scale workaround) - it turned out to be the *safest* option, not a risky one: a `Camera2D` only changes which slice of the already-correct world coordinates gets rendered; it never touches `Player`'s `CharacterBody2D`, `move_and_slide()`, the obstacle spawner, or any world-space constant (`ROAD_SURFACE_Y`, `SPAWN_X`, `ENCOUNTER_TARGET_X`, etc. all remain real, unchanged world coordinates). UI needed zero special handling: `CanvasLayer` nodes (the entire `UI` tree) always render in raw screen space and structurally ignore the active `Camera2D`'s transform - confirmed by the smoke test (`score_label` etc. unaffected).

Added a single `GameplayCamera` node (`scenes/Main.tscn`, child of `Main`), positioned at `(576, 324)` with `zoom=(1,1)` by default - this is *exactly* the same view Godot's implicit default camera already produced with no `Camera2D` at all (a `1152x648` viewport with its top-left at world origin has its center at `(576,324)`), so the "default/non-gameplay" framing is mathematically identical to what every existing cinematic/menu scene was already built and tested against.

`GAMEPLAY_ZOOM_FACTOR := 1.12` (within the requested `1.12-1.15` range, kept at the conservative end). `GAMEPLAY_CAMERA_ZOOM := Vector2.ONE / 1.12 ≈ (0.893, 0.893)` (Camera2D's own zoom semantics are inverted - smaller `zoom` values mean *more* magnification, so `1/1.12` is what actually produces a `1.12x` zoom-in). `GAMEPLAY_CAMERA_POSITION` is solved algebraically (not guessed) from the screen-mapping formula `screen = (world - camera) / zoom + view/2`, so that after zooming: Ali's world X (`PLAYER_START_X=220`) still lands at screen X `≈235` (inside the requested `220-250` band), and `ROAD_SURFACE_Y` still lands at the same screen Y as the unzoomed view - confirmed exactly by the smoke test (`ali_screen_x` computed live, found inside the band).

State wiring mirrors the already-validated music state machine exactly (same call sites, same reasoning): `_apply_default_framing()` is called from `_show_start_screen()`, `_start_intro()`, `_open_checkpoint_cinematic()` (covers every checkpoint dialogue, the Father ending, and Game Over via `_end_run()`), and the post-checkpoint countdown (`_finish_encounter_and_countdown()`, still not running yet); `_apply_gameplay_framing()` is called from `_begin_run()` (Restart/Retry/post-intro start - all resume running immediately) and `_finish_countdown()` (the exact moment a post-checkpoint countdown finishes and real running resumes). Both framing functions tween `position`/`zoom` over `CAMERA_TRANSITION_TIME = 0.35s` (`TRANS_SINE`/`EASE_OUT`, smooth not instant) via a single tracked `_camera_tween` (killed/replaced every call, same discipline as every other tween in this project) with `TWEEN_PAUSE_PROCESS` set, since checkpoint dialogue pauses the tree partway through the transition.

### Task E — Obstacle visibility/fairness (measured)

With the `1.12x` zoom, the visible world right edge moves from `1152` (unzoomed) to **`1038.75`** - confirmed live via the smoke test. `OBSTACLE_SPAWNER.SPAWN_X = 1292` stays well beyond that (`1292 > 1038.75`), so obstacles are still fully offscreen when they spawn - actually *more* offscreen-margin than before, not less. Visible distance ahead of Ali (`1038.75 - PLAYER_START_X(220) = 818.75px`) gives:

* Reaction time at speed `225`: `818.75 / 225 ≈ 3.64s` (previously `932/225 ≈ 4.14s`).
* Reaction time at speed `270` (max/post-Jomana): `818.75 / 270 ≈ 3.03s` (previously `932/270 ≈ 3.45s`).

Both are comfortably above the `2.6-2.8s` fairness floor this task set, while still measurably reducing the lead time per the owner's "too much advance warning" complaint - roughly a `12%` cut at every speed, matching the `1.12x` zoom factor exactly (as expected, since zoom uniformly scales the visible distance).

### Validation

* Headless boot clean, exit `0`. Boot log confirms both the new ground fit (`final_scale=(0.530387, 0.530387)`) and the new buildings/foreground overlap (`visible_bottom=480.0`).
* Smoke test (deleted after running, `tmp_v136d_smoke_test.gd` + its `.uid`): confirmed ground/road nodes exist; confirmed menu/intro use default (unzoomed) framing and `score_label` stays in the UI tree throughout; confirmed gameplay framing engages after Skip Intro; confirmed Ali's computed screen X lands inside `220-250`; confirmed the zoomed visible right edge keeps `SPAWN_X` offscreen and reaction time at max speed stays above the `2.6s` floor (matching the hand-calculated `3.03s` exactly); confirmed no obstacle ever spawns inside the zoomed visible area at runtime; confirmed a real Fatima checkpoint opens with default framing and gameplay re-zooms after its countdown; confirmed Game Over switches to default framing; confirmed Retry and Restart both correctly re-zoom for gameplay. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four speeds, all four checkpoint trigger scores). No player physics, collision shape, obstacle spawn logic, story/checkpoint score, reward logic, retry/restart logic, or audio logic was touched - every change here is either a sprite-fitting call, a `.tscn` color/offset tweak, or the new camera framing, none of which touch a single world-space gameplay coordinate.

### Owner F6 checklist

1. Confirm the bottom brown strip is gone or much less noticeable, and that it now reads as an intentional road-edge/dirt-shoulder color rather than an empty block.
2. Confirm the buildings/sidewalk now visually connects to the road with no seam/gap.
3. Confirm gameplay feels "closer"/more focused, and that obstacles feel like they give a bit less advance warning while still being fair to react to.
4. Confirm menu, intro, every checkpoint dialogue, the Father ending, and Game Over all still look fully framed (nothing cropped) - they're using the exact same framing as before this task, so this should be unchanged, but worth a quick look since it's now camera-driven rather than implicit.
5. Confirm the zoom-in/zoom-out transitions feel smooth, not jarring or jittery.

Commit: `autopilot: v1.36D scene framing road fill and gameplay zoom polish`.

## v1.36D-HOTFIX — Fix Camera Zoom Direction, Remove Margins — STATUS: COMPLETE

Files changed: `scripts/main.gd`.

### Task A — Root cause (confirmed exactly as hypothesized)

Godot's `Camera2D.zoom` is a **direct magnification multiplier**, not an inverse field-of-view value: `zoom = Vector2(2,2)` makes everything twice as big (zoomed **in**); `zoom < 1` zooms **out**, showing *more* world squeezed into the same viewport. v1.36D's `GAMEPLAY_CAMERA_ZOOM` was `Vector2.ONE / GAMEPLAY_ZOOM_FACTOR` ≈ `(0.893, 0.893)` - the inverse convention, correct for an orthographic "size" value but backwards for Godot's actual `zoom` property. Assigning `0.893` directly to `Camera2D.zoom` zoomed **out**, and because the background sprites (sky/buildings/foreground/ground) are only sized to cover the nominal `1152x648` view, the now-larger visible world area exposed bare viewport clear color beyond their edges - the dark/gray margins the owner saw. Confirmed: the camera *position* formula was incidentally still correct throughout (multiplying by the inverse value is algebraically the same as dividing by the real value), so only the zoom *value itself* needed correcting, not the framing concept.

### Task B — Fix applied

`GAMEPLAY_CAMERA_ZOOM` now assigns `GAMEPLAY_ZOOM_FACTOR` (`1.12`) **directly**, with no inversion - this is a real `Camera2D.zoom` of `1.12`, a genuine zoom-in. The position-solving formula (`GAMEPLAY_CAMERA_POSITION`) was updated to **divide** by the zoom value instead of multiplying by it, since Godot's real mapping is `screen = (world - camera) * zoom + view/2` (solving for camera divides by zoom). The resulting camera position is numerically unchanged (`≈(524.46, 343.93)`) from v1.36D, since multiplying by the old inverse value and dividing by the new real value are algebraically identical - only the literal `Camera2D.zoom` assignment was the actual bug. Camera2D remains enabled; it did not need to be disabled.

### Task C — Road fixes: all preserved, none contributed to the bug

The aspect-preserving ground fit, the reduced brown strip, the road-matched `GroundBase` color, and the `10px` buildings/ground overlap from v1.36D are **untouched** - none of them caused or contributed to the margin bug (that was purely the `Camera2D.zoom` value). Re-verified live: ground fit `final_scale=(0.530387, 0.530387)` and buildings/foreground `visible_bottom=480.0`, identical to v1.36D.

### Task D — Framing state rules (re-verified, unchanged design)

* **Menu/Start:** default `zoom=1.0` framing - always safe, untouched by this hotfix.
* **Intro/Checkpoints/Father Ending:** default framing (same as menu) - re-confirmed via a real Fatima checkpoint in the smoke test.
* **Active gameplay:** now a real, correct `1.12x` zoom-in.
* **Game Over:** default framing, re-confirmed.
* **Retry/Restart:** both re-confirmed to correctly re-zoom for gameplay with no stuck camera state.

### Task E — Fairness recomputed with the corrected zoom

With the real `zoom=1.12`, the visible world rect (using Godot's actual `size = viewport / zoom` relationship, not the inverted formula v1.36D's own validation accidentally used) is `x=[10.18, 1038.75]`, `y=[54.64, 633.21]` - **fully inside** what the background sprites cover (`[0,1152] x [0,648]`), confirmed live by this hotfix's smoke test: zero exposed margin. `SPAWN_X=1292` stays well offscreen (`1292 > 1038.75`). Visible distance ahead of Ali: `1038.75 - 220 = 818.75px`. Reaction time at speed `270`: `818.75/270 ≈ 3.03s` - comfortably above the `2.6-2.8s` floor, and numerically identical to what v1.36D reported (confirmed mathematically: v1.36D's flawed fairness-check formula and the corrected zoom value happen to produce the same visible-width number, since `0.893 ≈ 1/1.12` - the *intended* design was sound all along; only the literal engine property assignment was wrong).

### Validation

* Headless boot clean, exit `0`.
* Smoke test (deleted after running, `tmp_v136d_hotfix_smoke_test.gd` + its `.uid`): confirmed gameplay zoom is `>1.0` and `<=1.15`; confirmed the visible world rect stays fully within `[0,1152]x[0,648]` (no margins) using the correct Godot zoom-to-visible-size formula; confirmed Ali's screen X stays in the requested band; confirmed `SPAWN_X` stays offscreen and reaction time at max speed stays at `3.03s`; confirmed default framing at menu, intro, a real Fatima checkpoint, and Game Over; confirmed Retry and Restart both correctly re-zoom with no stuck state; confirmed player Y stays aligned to `START_PLAYER_POSITION.y` after Restart. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four speeds, all four checkpoint trigger scores). No physics, collision, obstacle logic, or road collision was touched - this hotfix is contained entirely to two `Vector2` constant definitions in `scripts/main.gd`.

### Owner F6 checklist

1. Confirm gameplay now looks zoomed **in** (closer, Ali/obstacles slightly bigger), not zoomed out.
2. Confirm there are no dark/gray margins anywhere during gameplay.
3. Confirm the bottom brown strip and buildings/road seam fixes from v1.36D are still in effect (this hotfix did not touch them).
4. Confirm menu/intro/checkpoints/Father ending/Game Over still render fully framed with no margins (they use the unchanged default framing).
5. Confirm the zoom transition in/out still feels smooth.

Commit: `autopilot: hotfix camera framing and road polish`.

## v1.36E — Gameplay Framing, Obstacle Grounding, and Runner Lane Polish — STATUS: COMPLETE

Files changed: `scripts/main.gd`, `scripts/obstacle.gd`, `scripts/asset_utils.gd`.

### Task A — Slightly stronger gameplay zoom

`GAMEPLAY_ZOOM_FACTOR`: `1.12 -> 1.15` (within the requested range, did not need to fall back to `1.13/1.14`). Re-verified the visible world rect with the new zoom stays fully inside the background sprites' coverage - `x=[15.65, 1017.39]`, `y=[75.22, 638.70]` against the `[0,1152]x[0,648]` bounds, confirmed live by the smoke test, so no margins were reintroduced. Reaction time at max speed (`270`): `(1017.39 - 220)/270 ≈ 2.95s` - still comfortably above the `2.6-2.8s` fairness floor from earlier tasks.

### Task B — Obstacles grounded visually

Two additive, visual-only changes in `scripts/obstacle.gd`, neither touching `CollisionShape2D`:

1. **Contact shadow.** Added `_apply_shadow()`, building a small soft oval `Polygon2D` (`z_index=-1`, so it draws behind the obstacle sprite) sized to `95%`/`26%` of the obstacle's own `collision_width` (wider obstacles get a proportionally wider shadow) and positioned at the same `collision_bottom_y` the sprite already aligns to. The oval-point generator (`build_oval_polygon()`) was promoted into the shared `asset_utils.gd` (it's the same shape Ali's own ground shadow already uses in `player.gd`) so this didn't need a second hand-rolled copy.
2. **Tiny visual sink.** `ASSET_UTILS.align_sprite_visible_bottom(obstacle_sprite, collision_bottom_y + VISUAL_SINK_PX)` with `VISUAL_SINK_PX = 3.0` - the sprite (only the sprite, never `collision_bottom_y` itself) is drawn `3px` lower than the actual hitbox bottom, reading as "settled into the road" rather than floating. Confirmed live in the boot log: `"visible_bottom=28.0 collision_bottom=25.0"` for the default block (a `3px` sink on top of an unchanged `25.0` collision bottom).

### Task C — Runner lane readability

`ROAD_SURFACE_Y` stays `510` exactly, as required - this was a camera-framing change only. Previously, `GAMEPLAY_CAMERA_POSITION`'s vertical solve pinned `ROAD_SURFACE_Y` to the *same* screen Y as the unzoomed view (`510`). That ratio (how close Ali's sprite/head reads to the curb line) is fixed by the art's own world-space proportions and cannot be changed by zoom or panning alone - but *panning* the vertical framing can still change how much visual "road" appears below Ali vs. how much "sidewalk/sky" looms above him, which is what was actually being asked for. Added `CAMERA_TARGET_SCREEN_Y := 500.0` (instead of implicitly `510`) and updated the position formula to solve against it - confirmed live that `ROAD_SURFACE_Y` now reads at screen Y `~500` instead of `510`, pushing the curb line up and giving the road more visible depth below Ali. `500` was chosen as close to the *safe maximum* pan at this zoom: any further down and the visible world's bottom edge would exceed `GroundBase`'s fixed coverage (`VIEW_H = 648`) and reintroduce a margin, exactly like the v1.36D-HOTFIX bug - confirmed by checking the resulting `visible_bottom (638.70)` stays under `648` with a small safety margin.

### Task D — Preserved

The v1.36D road/ground visual fixes (aspect-preserving ground fit, the reduced brown strip, the road-matched `GroundBase` color, the buildings/ground overlap) were not touched by this task at all - only the camera constants and `obstacle.gd` changed.

### Validation

* Headless boot clean, exit `0`.
* Smoke test (deleted after running, `tmp_v136e_smoke_test.gd` + its `.uid`): confirmed gameplay zoom lands in `1.13-1.18`; confirmed the visible world rect stays fully inside `[0,1152]x[0,648]` (no margins) at the new, stronger zoom; confirmed the road surface now reads higher on screen (`~500`) than its old unzoomed position (`510`); confirmed reaction time at max speed stays above `2.6s`; confirmed `SPAWN_X` stays offscreen; confirmed Ali's screen X stays in the `220-260` band; confirmed a spawned obstacle has both its `CollisionShape2D` (shape assigned, untouched) and a second `Polygon2D` (the new shadow) as children; confirmed jump/fall/land still transition correctly; confirmed a real Fatima checkpoint still re-zooms gameplay correctly afterward and returns `player.global_position.y` to exactly `START_PLAYER_POSITION.y`; confirmed Game Over switches to default framing and Retry re-zooms. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four speeds, all four checkpoint trigger scores, and every obstacle definition's own `collision_width`/`collision_height`). No collision shape, physics body, or obstacle spawn/movement logic was touched - every change here is either a camera constant or a sprite/shadow positioning call.

### Owner F6 checklist

1. Confirm gameplay now reads noticeably closer/more intense than the previous (`1.12x`) pass, without feeling unfair.
2. Confirm obstacles no longer look like they're floating - the shadow and tiny sink should read as "resting on the road."
3. Confirm Ali no longer feels pressed up against the curb/sidewalk line, and the road reads more like a usable lane.
4. Confirm menu/intro/checkpoints/Father ending/Game Over still render fully framed with no margins (unchanged default framing).
5. If the lane still feels too shallow, the safe pan budget at `1.15x` zoom is nearly exhausted (`~9px` of margin left before `CAMERA_TARGET_SCREEN_Y` would need to come back down) - the next lever would be revisiting `GROUND_VISUAL_HEIGHT`/ground texture coverage rather than panning further.

Commit: `autopilot: gameplay framing and obstacle grounding polish`.


## v1.37A — Animated Light Shards Collectible Assets Sourced — 2026-06-29

Status: ASSETS_SOURCED

Added `light_shard_sheet.png` to `assets/collectibles/light_shard/` (CC0 animated star/shard sprite sheet with 6 frames) to unblock the Sonnet coder.

## v1.37A — Animated Light Shards Collectibles Foundation (Implementation) — STATUS: IMPLEMENTED / OWNER F6 REVIEW REQUIRED

Files added: `scenes/Collectible.tscn`, `scripts/gameplay/collectible.gd`, `scripts/gameplay/collectible_spawner.gd`. Files changed: `scripts/main.gd`, `scenes/Main.tscn`.

**Asset used:** the just-sourced `res://assets/collectibles/light_shard/light_shard_sheet.png` (Eiyeron, CC0 1.0, OpenGameArt "Spinning heart and star trinkets", `HUMAN_VISUAL_REVIEW_REQUIRED` per `docs/ASSET_CREDITS.md`). **Measured it directly with PIL before writing any code** rather than trusting the "6 horizontal frames" description: the sheet is actually `64x96px`, and slicing it as 6 frames stacked **vertically** (each `64x16`) produces clean, consistent per-frame bounding boxes; slicing it horizontally (`64/6 ≈ 10.67px` per frame) does not divide evenly and would be wrong. `Sprite2D.vframes = 6` (not `hframes`) is used accordingly, with the frame's real `64x16` size driving the scale-to-`VISUAL_HEIGHT(28px)` calculation directly (no alpha-trim needed for a small, already-tight sprite sheet frame).

### Architecture (kept separated, as required)

* `collectible.gd` (`Area2D`) owns its own movement (`-speed*delta`, matching whatever `current_speed` the spawner gives it), animation (sheet frame-cycling, or a gentle pulse/rotation fallback if the sheet is missing), pickup detection (`body_entered` on the Player), and pickup visuals (sparkle + scale/fade pop, then `queue_free()`).
* `collectible_spawner.gd` (`Node2D`) owns spawn timing/placement only - mirrors `obstacle_spawner.gd`'s exact public shape (`setup`/`start_spawning`/`stop_spawning`/`clear_collectibles`) so `main.gd` calls both spawners identically, side by side, at every relevant lifecycle point.
* `main.gd` only orchestrates: connects each spawned shard's `collected` signal, owns the `collectible_count` state + `النور: 0` label text, and saves/restores the checkpoint snapshot. It does not touch obstacle logic, and `obstacle_spawner.gd` was not modified.

### Fallback chain (asset-safe, never crashes)

1. The real sheet (above) - animates by cycling `frame` through all 6 at `8 FPS`.
2. A static image at `light_shard.png` or `light_shard_1.png`, if the sheet itself is ever missing - same pulse as the placeholder, since a single static image has no frames of its own to cycle.
3. A procedural 5-point golden star `Polygon2D`, built once from plain trigonometry (`Color(1.0, 0.82, 0.25)`) - never a texture, so it can never fail to load, and the only path that also gets the code-side rotation (the sheet/static paths either already animate via frames or are real art that doesn't need a synthetic spin).

All three paths share the same gentle scale "pulse" (`0.92x` to `1.1x` over `0.9s`) so the shard always reads as "alive" regardless of which asset path is active. Missing-asset logging follows the existing `asset_utils.gd` `load_texture_with_fallback()` pattern already used everywhere else in this project (logs once, never crashes, never spams).

### Spawn behavior (v1.37A scope: simple and safe, no obstacle-relative patterns yet)

A single dedicated `Timer` (`CollectibleSpawnTimer`, separate from the obstacle `SpawnTimer`) fires at a randomized `3.0-5.0s` interval - deliberately wider and decoupled from the fixed `2.25s` obstacle cadence so shards never feel mechanically tied to obstacles. Each cycle spawns exactly one shard, at `SPAWN_X` (same offscreen spawn point obstacles use), at one of two heights:

* **Road shard** (`ROAD_SURFACE_Y - 50 = 460`): grabbable just by running - Ali's grounded collision spans world Y `462-510`, so this overlaps it by a forgiving `~12-14px` margin depending on the shard's own radius.
* **Elevated/"jump" shard** (`ROAD_SURFACE_Y - 125 = 385`): chosen from this project's **actual jump-arc math**, not a guess - max rise = `JUMP_VELOCITY² / (2·GRAVITY) = 440² / (2·1050) ≈ 92.19px`, so the body's `48px`-tall collision (centered on the body origin) spans world Y `~369.8-417.8` at the exact apex. `385` sits comfortably inside that band rather than at its razor edge, so it's reachable across a real slice of the jump arc, not only at a frame-perfect instant - deliberately forgiving for a first, child-friendly pass.

**No-overlap safety:** before placing a road-level shard, `_obstacle_too_close_to_spawn_x()` checks every live obstacle's actual `global_position.x`; if one is within `200px` of the spawn point, an elevated shard is used instead that cycle (elevated shards never need this check at all - they sit well above every obstacle's own collision top regardless of horizontal proximity). Obstacle-relative *patterns* (an arc above a specific obstacle, a reward line right after one) are intentionally deferred to v1.37B, exactly as scoped - this milestone only guarantees shards never land inside or directly behind a live obstacle.

### UI

Added `LightShardLabel` (`scenes/Main.tscn`, under `UI`), positioned at `(16,48)-(200,72)` - directly under `ScoreLabel` (`(16,14)-(200,44)`), same left margin, smaller font (`18` vs `24`) and a warm gold font color to visually distinguish it from the score without competing with it. Confirmed clear of `CompanionRibbon` (top-right) and every dialogue/menu element. Shown/hidden in lockstep with `score_label` (visible during gameplay, hidden at the menu).

### State rules (all verified by the smoke test)

* Fresh start / Restart / Father-replay (`_begin_run(..., checkpoint=NONE, ...)`): `collectible_count` and its checkpoint snapshot both reset to `0`.
* Checkpoint reached (`_apply_checkpoint_state()`, the same moment `last_reached_checkpoint` is locked in): `collectible_count_checkpoint_snapshot = collectible_count`.
* Retry from a checkpoint (`_begin_run(..., checkpoint=<not NONE>, ...)`): `collectible_count` is restored from that snapshot - reusing the exact same `checkpoint` parameter already used to derive the companion-ribbon flags, for the same reason.
* Father ending: no special-casing needed - the label is never hidden during any checkpoint cinematic (mirrors `score_label`'s own behavior), so the count stays visibly intact through the ending.
* `collectible_spawner.start_spawning()`/`stop_spawning()`/`clear_collectibles()` are called at every single point `obstacle_spawner`'s equivalents are: menu, a fresh run, every checkpoint encounter trigger, the Zainab-shield countdown, and Game Over - so collectibles always pause/clear in lockstep with obstacles, never mid-checkpoint or mid-Game-Over.

### Validation

* Headless boot clean, exit `0`. Boot log confirms the sheet loads at its real measured size (`size=(64.0, 96.0)`).
* Smoke test (deleted after running, `tmp_v137a_smoke_test.gd` + its `.uid`): confirmed the label's default text; confirmed `collectible_count` starts at `0`; confirmed a shard spawns within the max baseline interval, its sheet frame actually advances, and it moves left; confirmed a real pickup (Area2D overlap, not a direct state edit) increments the count and updates the label text exactly; confirmed Restart resets the count to `0`; confirmed a real Fatima checkpoint snapshots the count and Retry from that checkpoint restores it exactly, including the label text. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep (gravity, jump velocity, max fall speed, jump buffer, road surface Y, player collision half-height, spawn interval/X, all four checkpoint trigger scores). `obstacle_spawner.gd`'s only change this milestone was reverted entirely (a draft `obstacle_spawned` signal, removed once v1.37B's obstacle-relative patterns were deferred) - it ships unmodified from before this milestone.

### Remaining owner F6 review items

1. Listen/look: confirm the shard's spin/shimmer animation and pulse read as intended at gameplay zoom `1.15` (asset status is `HUMAN_VISUAL_REVIEW_REQUIRED`).
2. Confirm the road-level and elevated shard heights feel right by eye, not just by the jump-arc math above.
3. Confirm `النور` label placement/readability under the score.
4. **Pickup audio integrated ahead of schedule.** A dedicated `res://assets/audio/gameplay/shard_pickup.wav` (Kenney UI Audio `switch2.wav`, CC0 1.0, `docs/AUDIO_CREDITS.md` → "Collectibles" section, `HUMAN_AUDIO_REVIEW_REQUIRED`) arrived from the asset-sourcing pass while this exact wiring was in progress. Verified the file exists and is documented before touching anything, then added it through the **existing** `audio_manager.gd` system only - one `SOUND_PATHS`/`VOLUME_DB` entry plus a `play_shard_pickup()` wrapper around the already-shared `_play()` helper, exactly like every other SFX (no second `AudioStreamPlayer`, no node-local playback, missing-file-safe via the same `_resolve_sound_path()` path). Called from `main.gd`'s `_on_collectible_collected()` (the signal handler each shard's `collected` already triggers) - fires exactly once per real pickup, never on spawn, and `reward_star.wav`/jump/hit/music behavior is untouched.

Recommended next task: **v1.37B — Safe Collectible Patterns** (obstacle-relative arc/reward-line patterns).

Commit: `autopilot: v1.37A light shards collectibles foundation`.

## v1.37-HOTFIX — Keep Ali Ground Shadow Projected on Road During Jump — STATUS: COMPLETE

Files changed: `scripts/player.gd`.

### Root cause

`_ground_shadow`/`_soft_shadow` are children of `Player` (the `CharacterBody2D` itself), created once in `_setup_ground_polish()` at a **fixed local offset** `Vector2(0, ali_sprite.FEET_Y)`. That offset is only correct while grounded, because `Player.global_position.y` itself rises and falls during a real jump (real physics motion, not a visual-pose artifact) - and since the shadow's local offset was never recalculated, its global position rode along with the body's full vertical motion. Confirmed via the task's own diagnostic questions: the shadow is a child of the visual-adjacent body (not the sprite's own pose system), it does **not** inherit `ali_sprite`'s per-pose `.position` (run-frame bob/land calibration were never the cause), and it used a static local position rather than any ground-projected calculation - that last point is the actual bug.

### Fix

Added `_update_ground_shadow()`, called every `_physics_process()` tick right after `move_and_slide()`. Each frame it recomputes the shadow's **local** Y as `ROAD_SURFACE_Y - global_position.y` - by construction, `shadow.global_position.y` is then always exactly `ROAD_SURFACE_Y` (`510`), regardless of how far the body has actually risen. `ROAD_SURFACE_Y`/`PLAYER_COLLISION_HALF_HEIGHT` are duplicated locally in `player.gd` (not imported), matching this project's existing per-script-constant convention (`obstacle_spawner.gd` already keeps its own copy of `ROAD_SURFACE_Y` the same way).

### Airborne polish

`MAX_AIR_RISE` is computed directly from this project's real physics, not guessed: `JUMP_VELOCITY² / (2·GRAVITY) ≈ 92.19px`. `air_fraction = clamp((GROUNDED_BODY_Y - global_position.y) / MAX_AIR_RISE, 0, 1)` drives both shadows' `scale` (lerped `1.0 → 0.7`) and `modulate.a` (lerped `1.0 → 0.4`) - shrinking and softening smoothly as Ali rises, returning to normal the instant he's grounded again. Both shadows always share the same scale/alpha/Y so they move and fade together.

### Interaction with other systems

Untouched by design - this fix only ever writes to `_ground_shadow`/`_soft_shadow`'s own `position`/`scale`/`modulate`, never to `ali_sprite` or any of its pose/run/land/story-scaling logic, and never to `obstacle.gd`'s separate contact-shadow system (different nodes, different script, not referenced here at all).

### Validation

* Headless boot clean, exit `0`.
* Smoke test (deleted after running, `tmp_shadow_smoke_test.gd` + its `.uid`): confirmed the shadow sits at `ROAD_SURFACE_Y` while grounded at normal scale/alpha; confirmed that during a real jump the shadow's global Y never moves (`max - min < 1px`) while the body itself measurably rises, and that the shadow visibly shrinks while airborne; confirmed it returns to normal scale/position after landing; confirmed the run animation, `ali_land`'s small/correct calibration, post-checkpoint alignment, and Retry/Restart are all unaffected; confirmed obstacles still carry their own separate contact-shadow polygon, unchanged. One real test-only bug was found and fixed along the way (not a product bug): checking `ali_land` while `_gameplay_active` was still `true` raced against `player.gd`'s own per-tick pose updates, which is why `set_gameplay_active(false)` is called first before that manual check now. **0 failed assertions.**

Immutable benchmarks re-verified unchanged via grep - the new constants (`ROAD_SURFACE_Y`, `PLAYER_COLLISION_HALF_HEIGHT`, `GROUNDED_BODY_Y`, `MAX_AIR_RISE`) are all derived from the existing immutable values, not replacements for them.

### Owner F6 checklist

1. Confirm the shadow visually reads as staying on the road throughout a jump, not floating up with Ali.
2. Confirm the shrink/fade while airborne feels subtle, not distracting.
3. Confirm landing still looks/feels right (no shadow pop or snap).

Commit: `autopilot: keep ali shadow grounded during jump`.
