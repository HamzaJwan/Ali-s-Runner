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
