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
* ✅ **Ali Visual Calibration and v1.36B smoothing:** run frames remain normalized to the shared visible-height baseline; LAND uses a dedicated calibrated scale near `79x80 px`; the current four-frame cycle runs at `14 FPS` and is ready to discover up to eight frames.
* ✅ **v1.2B Dust/Shadow Polish:** grounded shadow, running dust, jump/landing puff, and Game Over impact puff are implemented and regression-tested.
* ⬜ HUMAN_TEST_REQUIRED — parallax loop-seam quality, menu pulse/bob "feel," and general visual polish all need an in-engine look (`docs/AUTOPILOT_PROGRESS.md` lists several specific visual risk items under "HUMAN_VISUAL_REVIEW_REQUIRED").

## 3. Story Presentation

* ✅ **v1.25B Cinematic Intro Story Presentation:** Ali and Father appear in-world with speaker focus, Arabic dialogue, and clean teardown into gameplay.
* ✅ **v1.26 Family Companion Journey UI:** Fatima, Zainab, and Jomana accumulate in the companion ribbon; Retry restores the checkpoint set and Restart clears it.
* ✅ **v1.27 Father Ending Family Group Scene:** the ending shows all three joined sisters, and Play Again resets companion state and all NPC scales to `1.0`.
* ✅ The underlying narrative direction remains documented in `docs/STORY_PLAN.md` Section 14, "Family Companion Journey."

## 4. Audio

* ✅ v0.95A: 11 CC0 SFX integrated (button click, dialogue blip, jump, land, hit, checkpoint, 3 rewards, game over, victory) via `scripts/audio/audio_manager.gd`. Missing-file-safe, no crash if any sound is absent.
* ⛔ BLOCKED / ⬜ HUMAN_TEST_REQUIRED — **all 11 integrated SFX remain `HUMAN_AUDIO_REVIEW_REQUIRED`.** This is the single most important open item for Gold: the owner must listen to and approve/remap/reject each one before this branch is treated as a release candidate.
* ✅ / ⛔ **v0.95B PARTIAL_COMPLETE:** licensed `main_theme_soft_loop.ogg` is integrated, loops at `-22 dB`, and ducks during intro/checkpoints/Game Over. `hit_soft_impact.wav` and `level1_exciting_loop.ogg` remain deliberately unintegrated because their source/license entries are not verified. All music/SFX still require human tone approval.
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

## 7. Latest Polish and Owner F6 Gates — 2026-06-29

Implemented with automated passes, but still requiring owner F6 review:

* ✅ / ⬜ Fatima scale `72`, remaining the smallest character.
* ✅ / ⬜ Father height `215` and heroic intro/ending emphasis.
* ✅ / ⬜ Soft oval shadow replacing the black rectangle beneath Ali.
* ✅ / ⬜ Run smoothing at `14 FPS`, bounded bob/contact dust, and 1-8 frame readiness.
* ✅ / ⬜ Living story-character idle motion with shared cleanup.
* ✅ / ⬜ Intro `التالي` placement clear of Father.
* ✅ / ⬜ Enlarged companion ribbon inside the top-right viewport boundary.
* ✅ / ⬜ Documented jump/hit replacements and fallback-ready audio structure.

Pending release gates:

* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm LAND size, feet alignment, and transition feel after a jump.
* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm Ali remains at the correct road height after Fatima and Zainab Continue/countdown.
* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm Jomana text wraps inside the card at `1152x648`.
* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm Arabic terminal punctuation renders on the correct visual side.
* ⬜ `HUMAN_AUDIO_REVIEW_REQUIRED` — confirm calm music owns non-running states and exciting music owns active running, with comfortable crossfades.
* ⬜ `HUMAN_AUDIO_REVIEW_REQUIRED` — listen to and approve/reject active SFX and both music tracks.
* ⬜ `LICENSE_VERIFICATION_REQUIRED_BEFORE_PUBLIC_RELEASE` — document the exact source/license for `level1_exciting_loop.ogg`; owner has authorized in-project use meanwhile.
* ✅ `OWNER_DECISION_KEEP_CURRENT_FATHER_LINE` — do not rewrite the current Father ending phrase.

## 8. v1.37A — Light Shards Collectibles Foundation — 2026-06-29

* ✅ / ⬜ Animated "شظايا نور" collectible (`light_shard_sheet.png`, CC0, `HUMAN_VISUAL_REVIEW_REQUIRED`) - spawns, animates, moves, and is picked up; separate `النور: 0` counter, never mixed with `score`/checkpoints/obstacle speed.
* ✅ Restart resets the counter; checkpoint reach snapshots it; Retry from that checkpoint restores it exactly.
* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm the shard's spin/pulse reads well at gameplay zoom `1.15` and the road/elevated heights feel fair by eye.
* ✅ Pickup SFX integrated (`shard_pickup.wav`, Kenney UI Audio, CC0) - `HUMAN_AUDIO_REVIEW_REQUIRED` still applies, same as every other SFX in the project.

Level 1 remains **AUTOMATED GOLD CANDIDATE / OWNER VISUAL AND AUDIO REVIEW REQUIRED**, not Final Gold.

## 9. v1.37B/C + v1.37-HOTFIX + v1.38 — Collectible Patterns, Juice, Shadow Fix — 2026-06-29

* ✅ Safe obstacle-relative patterns (arc above / reward line / raised-near-barrier), each spawned at the obstacle's own known position/speed so it can never drift into that obstacle's hitbox - verified by direct hitbox-rectangle overlap checks in the smoke test, not just by eye.
* ✅ Pickup juice complete: sparkle, scale/fade pop, and a `"+1"` floating pop, all on top of the already-integrated `shard_pickup.wav`.
* ✅ Ali's ground shadow now stays pinned to `ROAD_SURFACE_Y` during a jump (it previously rode up with the body) and gets a subtle airborne shrink/fade derived from this project's real jump-apex math.
* ✅ Small score/light-shard counter "pop" juice added.
* ⬜ `OWNER_F6_RETEST_REQUIRED` — confirm the arc/reward-line patterns feel intentional and fun, not random or distracting, and confirm the shadow fix reads correctly during a real jump.

## 10. Final Roadmap Audit — 2026-06-30

* ✅ Improved background art committed (`bg_buildings.png.png`, `bg_foreground.png.png` — owner-provided higher-quality versions, confirmed rendering correctly at 1152×648).
* ✅ Menu pulse/bob confirmed already smooth (`TRANS_SINE/EASE_IN_OUT`; backlog entry was stale).
* ✅ Full end-to-end regression smoke test passed — menu, intro, jump/shadow/run, all 4 checkpoints, Father ending, Game Over, Retry, Restart, music state, collectibles, immutable constants.
* ✅ Footstep audio — `BLOCKED_BY_AUDIO_ASSET` (no footstep sound in AUDIO_CREDITS.md); documented, correctly deferred.
* ✅ Dialogue typewriter per-character — `FUTURE` per AUDIO_DESIGN_PLAN.md "if ever pursued"; the one-per-advance blip already plays.
* ✅ Audio mute toggle — not in roadmap; evaluated and intentionally deferred as a new idea for the owner to approve.

Level 1 remains **AUTOMATED GOLD CANDIDATE / OWNER VISUAL AND AUDIO REVIEW REQUIRED**, not Final Gold.

## What "Gold" Does Not Require

To keep this checklist honest and not a moving target, the following are explicitly **not** required for Level 1 to be called Gold — they can ship later without blocking this milestone:

* Web export (v1.4) / Android export (v1.5) — separate, later milestones.
* Ambience loops, if the owner accepts shipping without them.
* v1.3 Character Animation Expansion (the older, broader animation-expansion milestone, distinct from the narrower v1.26A calibration fix above).
* Any Level 2 content (`docs/LEVEL_2_PLAN.md`) — explicitly out of scope until after this checklist.
* Web / Android export (v1.40/v1.41) — both blocked by missing export templates, Android SDK, and JDK; documented with exact owner action steps in `docs/AUTOPILOT_PROGRESS.md`.

## How to Use This Checklist

1. Whoever is implementing (currently the parallel "Sonnet" track per `docs/AUTOPILOT_PROGRESS.md`) works through the ⬜ NOT IMPLEMENTED items one at a time, small-step style, same as every other milestone in this project.
2. After each implementation step, update this checklist's status for that item — do not mark anything ✅ without a corresponding validation entry in `docs/AUTOPILOT_PROGRESS.md`.
3. The ⬜ HUMAN_TEST_REQUIRED items cannot be closed by any AI agent — they need the owner to actually press F6 and look/listen.
4. Once every item is ✅ or explicitly owner-accepted, declare Level 1 Gold and proceed to `docs/AI_GAME_ROADMAP.md` ("v1.35 — Complete Roadmap Refresh") and then `docs/LEVEL_2_PLAN.md`.

**Current overall status: NOT FINAL GOLD — AUTOMATED GOLD CANDIDATE / OWNER VISUAL AND AUDIO REVIEW REQUIRED.** Automated checks cover the complete Level 1 loop and latest polish. The owner gates above remain open, including dynamic-music listening, Jomana/RTL review, LAND/post-checkpoint-height retest, and active-audio approval.
