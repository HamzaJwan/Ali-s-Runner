# Ali Runner — Level 1 Gold Candidate Checklist

This is the consolidated checklist for **v1.34 — Level 1 Gold Candidate** (see `docs/AI_GAME_ROADMAP.md`). It exists because Level 1 polish/fix work has been tracked piecemeal across many small entries in `docs/AUTOPILOT_PROGRESS.md` and this roadmap — this document pulls all of it into one place so "is Level 1 actually done?" has a single answer instead of needing to read a dozen scattered entries.

**A build only qualifies as "Gold Candidate" once every item below is either checked off, or explicitly accepted as a known/documented limitation by the owner.** "Ship without ambience music" is an acceptable owner decision. "Ship with the menu tween leak" is not — that's a defect, not a scope choice.

Status legend: ✅ code-verified (headless/automated test passed) · ⬜ HUMAN_TEST_REQUIRED (cannot be judged headlessly) · ⬜ NOT IMPLEMENTED (planned only) · ⛔ BLOCKED (waiting on an external input, e.g. a licensed asset)

## 1. Core Gameplay Loop

* ✅ Start screen, Play, jump (tap/click/Space), score, obstacles, Game Over, Restart — all verified via headless smoke tests across multiple sessions (`docs/AUTOPILOT_PROGRESS.md`, v1.0 entry).
* ✅ Four story checkpoints (Fatima 15, Zainab 35, Jomana 60, Father 90) trigger, run dialogue, and apply correct post-checkpoint state.
* ✅ Retry from Last Checkpoint and Restart from Beginning both verified to reset score/speed/state correctly, including after the menu-tween-leak fix.
* ✅ Reward effects implemented and tested: Fatima +5 score bonus, Zainab one-hit shield (absorb then expire), Jomana temporary safer-spacing window.
* ✅ Obstacle variety (5 types, weighted by difficulty chapter) implemented and tested.
* ⬜ HUMAN_TEST_REQUIRED — none of the above has been played by a human via F6 yet. Every "✅" above is a passed automated/headless test, not a human play session.

## 2. Visual Presentation

* ✅ Background motion / parallax (v1.2A) implemented and tested.
* ✅ Foreground opacity fix (the "weak/washed-out wall" issue) — root-caused and fixed (see `docs/AUTOPILOT_PROGRESS.md`, "v1.2A-FIX + v1.25A" entry).
* ✅ Hero menu presentation (Ali enlarged on the start screen, idle bob, Play-button pulse, title/subtitle fade-in) implemented.
* ✅ Menu tween leak fixed and regression-tested (Ali no longer stays enlarged after a fast Play/Skip).
* ⬜ NOT IMPLEMENTED — **v1.26A Ali Visual Calibration**: Ali's run-cycle/landing frames still pulse in size (~1.9x swing observed) due to inconsistent PNG crop heights. This is a known, real, unfixed defect — see `docs/AI_GAME_ROADMAP.md` ("v1.26A").
* ⬜ NOT IMPLEMENTED — **v1.2B Dust/Shadow Polish** (jump/landing dust puff, grounded drop shadow).
* ⬜ HUMAN_TEST_REQUIRED — parallax loop-seam quality, menu pulse/bob "feel," and general visual polish all need an in-engine look (`docs/AUTOPILOT_PROGRESS.md` lists several specific visual risk items under "HUMAN_VISUAL_REVIEW_REQUIRED").

## 3. Story Presentation

* ⬜ NOT IMPLEMENTED — **v1.25B Cinematic Intro Story Presentation**: the intro is still flat centered-text "الراوي" narration, not yet the in-world Ali/Father speech-bubble scene the owner requested.
* ⬜ NOT IMPLEMENTED — **v1.26 Family Companion Journey UI**: sisters do not yet visibly "join" Ali after their checkpoints.
* ⬜ NOT IMPLEMENTED — **v1.27 Father Ending Family Group Scene**: the Father ending does not yet show the gathered family.
* ✅ The underlying narrative direction for all three of the above is fully documented (`docs/STORY_PLAN.md` Section 14, "Family Companion Journey") — the design is settled even though the implementation isn't.

## 4. Audio

* ✅ v0.95A: 11 CC0 SFX integrated (button click, dialogue blip, jump, land, hit, checkpoint, 3 rewards, game over, victory) via `scripts/audio/audio_manager.gd`. Missing-file-safe, no crash if any sound is absent.
* ⛔ BLOCKED / ⬜ HUMAN_TEST_REQUIRED — **all 11 integrated SFX remain `HUMAN_AUDIO_REVIEW_REQUIRED`.** This is the single most important open item for Gold: the owner must listen to and approve/remap/reject each one before this branch is treated as a release candidate.
* ⬜ NOT IMPLEMENTED — **v0.95B**: better hit sound, background music, ambience. Three candidate files exist on disk (`hit_soft_impact.wav`, `main_theme_soft_loop.ogg`, `level1_exciting_loop.ogg`); only `main_theme_soft_loop.ogg` has a verified license so far (OpenGameArt "Icy Heights," CC0 1.0). None are integrated in code yet, and none are tone-approved.
* ⛔ BLOCKED — ambience loops (city/birds/wind): no candidates sourced at all yet.

## 5. Arabic / Localization

* ✅ All gameplay UI controls converted to Arabic-only (Score, Game Over, Retry, Restart, Play, Skip Intro, intro Next/Skip, checkpoint Continue) — verified via `grep` across `scenes/Main.tscn` for any remaining mixed Arabic/Latin string, confirmed only the intentional "Ali Runner" English subtitle remains.
* ✅ RTL properties (`text_direction`/`language`) applied consistently across the Arabic-only labels/buttons.
* ⬜ HUMAN_TEST_REQUIRED — actual RTL rendering/readability/clipping at runtime has not been confirmed by a human (`docs/AUTOPILOT_PROGRESS.md` notes this every time as a residual risk).
* ⬜ NOT IMPLEMENTED — Arabic title reconsideration ("علي رنر" → e.g. "مغامرة نور البيت") is documented as a recommendation but not actioned; final choice is an explicit owner decision (`docs/AI_GAME_ROADMAP.md` "v1.25A-P").

## 6. Process / Safety

* ✅ Every code change in this checklist's history was validated headless (`--headless --path . --quit`, exit 0) and immutable-constants-checked (gravity 1050, jump -440, fall 700, buffer 0.12, road 510, collision 32x48, spawn interval 2.25, spawn X 1292, speeds 225/240/255/270, checkpoints 15/35/60/90) before being committed.
* ✅ All work has stayed on `autopilot/v1-level1-20260628-1842` — `main` has not been touched.
* ⬜ NOT DONE — this branch has not yet been merged to `main`, and per the audio-approval blocker above, should not be until the owner has listened to the SFX.

## What "Gold" Does Not Require

To keep this checklist honest and not a moving target, the following are explicitly **not** required for Level 1 to be called Gold — they can ship later without blocking this milestone:

* Web export (v1.4) / Android export (v1.5) — separate, later milestones.
* Ambience loops, if the owner accepts shipping without them.
* v1.3 Character Animation Expansion (the older, broader animation-expansion milestone, distinct from the narrower v1.26A calibration fix above).
* Any Level 2 content (`docs/LEVEL_2_PLAN.md`) — explicitly out of scope until after this checklist.

## How to Use This Checklist

1. Whoever is implementing (currently the parallel "Sonnet" track per `docs/AUTOPILOT_PROGRESS.md`) works through the ⬜ NOT IMPLEMENTED items one at a time, small-step style, same as every other milestone in this project.
2. After each implementation step, update this checklist's status for that item — do not mark anything ✅ without a corresponding validation entry in `docs/AUTOPILOT_PROGRESS.md`.
3. The ⬜ HUMAN_TEST_REQUIRED items cannot be closed by any AI agent — they need the owner to actually press F6 and look/listen.
4. Once every item is ✅ or explicitly owner-accepted, declare Level 1 Gold and proceed to `docs/AI_GAME_ROADMAP.md` ("v1.35 — Complete Roadmap Refresh") and then `docs/LEVEL_2_PLAN.md`.

**Current overall status: NOT YET GOLD.** Most-blocking open items: human audio approval (Section 4) and the three not-yet-implemented presentation milestones (v1.25B, v1.26, v1.27).
