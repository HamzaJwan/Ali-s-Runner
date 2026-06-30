# Ali Runner — Future Feature Backlog

## Golden Rule

Do not implement all backlog features at once. Every feature must be one small Codex task. After every Codex task, test with F6 before continuing.

---

## Safe Next Features

Low risk, small scope, build directly on existing patterns.

* Obstacle spawn offscreen fix (v0.61 — obstacles spawn outside the right edge and enter naturally, instead of appearing in the middle of the screen).
* Arabic dialogue system (reuse one checkpoint panel, swap text per character — see `docs/STORY_PLAN.md`).
* Story checkpoint panel (pause, show portrait + dialogue, Continue button).
* ~~Zainab cinematic checkpoint (v0.70)~~ — **done.**
* ~~Cinematic encounter polish template (v0.70P)~~ — **done, but temporary.** The "popup panel polish" (rounded golden-bordered card, speaker-name badge, fade-in reveal, pop tweens) is a real, working stepping stone — not the final direction. The preferred scalable direction is the **in-world cinematic encounter template (v0.73)**: Ali and the character facing each other in the street, dialogue as a speech bubble/small panel near the speaker, world always visible. v0.73 is now the next recommended task — see `docs/AI_GAME_ROADMAP.md`.
* ~~In-world cinematic encounter template (v0.73)~~ — **done.** In-world presentation works, and the per-character config table (character_id, trigger_score, asset_path, placeholder_text, speaker_name, dialogue_steps, reward_text, retry_score, post_checkpoint_speed, encounter_position, character_visual_mode, checkpoint_state, game_over_line) was migrated into `scripts/story/encounter_data.gd` as part of v0.74.
* ~~Dialogue bubble smart placement (v0.74, Part 1)~~ — **done.** The in-world dialogue bubble now positions itself near the speaker and clamps to stay inside the viewport (`_position_dialogue_bubble_for_speaker`/`_clamp_bubble_position` in `scripts/main.gd`), avoiding face coverage.
* ~~Story code modularization (v0.74, Part 2)~~ — **done.** Per-character dialogue/trigger/reward/speed data now lives in one shared config table in `scripts/story/encounter_data.gd` instead of hand-written constants and match-blocks.
* ~~Safe multi-agent workflow (v0.74B)~~ — **done.** Parallel-AI rules documented and followed (never two agents on `main.gd`/`Main.tscn` at once, Sonnet on docs while Codex codes, Antigravity reviews after Codex finishes).
* ~~`main.gd` responsibility split (v0.74B)~~ — **done.** `scripts/gameplay/obstacle_spawner.gd`, `scripts/gameplay/difficulty_manager.gd`, `scripts/story/encounter_controller.gd`, and `scripts/ui/dialogue_bubble_helper.gd` all now exist as separate files; `scripts/main.gd` shrank from ~886 to 709 lines.
* ~~Jomana cinematic checkpoint (v0.71)~~ — **done** (will be re-presented in-world by v0.73, not re-implemented from scratch).
* ~~Father ending / final success panel (v0.72)~~ — **done** (same — re-presented in-world by v0.73).
* Difficulty chapters tied to checkpoints (slightly faster/harder after each sister) — **done** (225 → 240 → 255 → 270 across Fatima/Zainab/Jomana).
* Audio foundations (button click, jump, land, checkpoint, game over, victory, one soft background loop — see `docs/AUDIO_DESIGN_PLAN.md`, roadmap v0.95). Still later — not started.
* ~~Obstacle variety, one new type at a time (v0.75)~~ — **done.** All five obstacle types (block/barrier/cone/crate/sign) exist with real PNG art and are selected with weighted randomness per difficulty chapter — see "Medium-Risk Features" below for what's still future (real PNG *replacement* polish, coins, etc.).
* ~~**v1.26 — Family Companion Journey UI**~~ — **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** Portraits accumulate correctly, Retry/Restart restore or clear state, and the top-right ribbon has been enlarged for readability.

### Latest Level 1 Polish Slices — IMPLEMENTED / OWNER F6 RETEST REQUIRED

* Fatima encounter scale `72`, still the smallest character.
* Father height `215` with stronger heroic focus in intro and ending presentation.
* Black rectangular foot artifact replaced by a soft oval shadow.
* Run smoothing implemented: `13 FPS` during the initial polish sprint, then `14 FPS` plus bounded bob/contact timing and 1-8 frame readiness in v1.36B.
* Subtle story-character idle/breath motion implemented with shared cleanup on gameplay return.
* Intro `التالي` control moved away from Father.
* Companion ribbon enlarged and kept inside the top-right viewport boundary.
* Documented jump/hit candidates integrated through safe fallback-ready audio paths.

These items remain owner-review gates despite their automated passes.

## Medium-Risk Features

More moving parts, still scoped to one feature at a time.

* Checkpoint retry system (track last reached checkpoint, retry from there instead of always restarting from the beginning — see roadmap v0.66).
* Emotional Game Over variants (death screen text changes based on the last checkpoint reached — see `docs/STORY_PLAN.md` "Death and Retry Tone").
* Coins / collectibles risk-reward — **fully implemented through v1.37C** (animated shards, obstacle-relative patterns, pickup juice/SFX, shadow hotfix, score pop). Owner F6 visual/audio review still required before public release.
* ~~Random obstacle pool (choosing among multiple obstacle types at random)~~ — **done** (v0.75, weighted selection in `scripts/gameplay/obstacle_spawner.gd`).
* ~~Obstacle variety (concrete block, road barrier, construction cone, low crate, broken road sign)~~ — **done** (v0.75, all five exist with real PNG art, not placeholder-only).
* Real obstacle PNG *quality* pass (replacing the current AI-generated/sourced art with anything better, or adding more variety beyond the current five) — optional future polish, not scheduled.
* Standalone collectible pickups, separate from story rewards (was the old "v0.85 — Collectibles" milestone) — **superseded by v1.37A's "شظايا نور" light shards** (real implementation, not the placeholder `date_collectible.png`/`star_collectible.png`/`coin_collectible.png` names this line originally tracked).
* ~~Ali pose-slot system (v0.8A)~~ — **done.** Pose-switching mechanism in `scripts/player_visual.gd`, with `ali_idle.png` fallback for any missing pose.
* ~~Ali 4-frame run cycle (v0.8B)~~ — **done.** Real 4-frame run cycle (`ali_run_1..4.png`) at 10 FPS, cached, with fallback to `ali_run.png` then `ali_idle.png` then placeholder. Remaining poses (jump/fall/land/slide/hurt/victory) are wired into the same slot system — see `docs/ASSET_FOLDER_MAP.md` for per-pose asset status. **v0.8C — Ali Pose Polish Pass** (reviewing those poses' feel/timing) is the next step in this area, not full re-implementation.
* **v0.8D — Game Over Impact Moment** (new, planned polish): when Ali hits an obstacle — stop obstacle spawning immediately; stop or safely clear active obstacles so the background doesn't keep scrolling as if nothing happened; switch Ali to the hurt pose; add a short child-friendly impact moment (small dust puff, gentle stumble, tiny bounce-back, obstacle wobble, short hit-stop); then show Game Over after a brief delay (~0.35-0.6s). Rules: no violence, no blood, no scary injury, no explosion, no health bar — one hit still ends the run, checkpoint retry stays unchanged, physics constants stay unchanged; this is visual feedback only. Recommended first implementation: stop spawner → clear/stop obstacles → set Ali's hurt pose → delay the Game Over panel slightly → add a dust/impact placeholder only if safe → no camera system unless safely isolated. See `docs/AI_GAME_ROADMAP.md` ("Next Recommended Steps") for where this sits relative to v0.8C/v0.85/v0.9.
* Real reward effects (Fatima bonus star, Zainab one-hit shield, Jomana boost/safer spacing — one at a time). Stays scheduled at v0.9, not part of v0.70/v0.71/v0.72 — those three checkpoints stay flavor-text-only rewards, same as Fatima today.
* Dialogue typing sound (typewriter-style blips during Arabic story text, with skip-to-complete option — see roadmap v0.96).
* Ambience layers (wind, birds, distant city loop, kept low volume and non-distracting — see roadmap v0.97).
* Game juice / feedback polish: small camera shake on hit or hard landing (separate from the v1.15 camera zoom/focus system), UI score number briefly scaling up/down when it changes, a small particle puff on jump and landing. All purely cosmetic, no gameplay effect. Overlaps with v0.8D above for the "hit" case specifically — implement together if convenient, but v0.8D's hurt-pose/spawner-stop/delay behavior is the priority, not camera shake.
* Running footstep loop sound, tied to Ali's movement while running (distinct from the single one-shot jump/land sounds already in `docs/AUDIO_DESIGN_PLAN.md`) — needs simple loop start/stop logic tied to the run state.
* **v0.95C — Dynamic Music State Switching:** **IMPLEMENTED / OWNER F6 AUDIO REVIEW REQUIRED.** Calm/gameplay state calls, one-player crossfade infrastructure, and fallback are implemented; the owner explicitly authorized `level1_exciting_loop.ogg` for project use. License verification remains required before public release.
* **v1.36A — Arabic Dialogue Layout and RTL Polish:** **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** Jomana wrapping/card containment and centralized RTL punctuation handling passed automated tests. Preserve the current Father ending phrase.
* **Audio asset improvement (v0.95B/v0.95C):** documented jump/hit replacements, calm music, and owner-authorized active-running music are integrated with safe fallbacks/state switching. All remain `HUMAN_AUDIO_REVIEW_REQUIRED`; `level1_exciting_loop.ogg` also remains `LICENSE_VERIFICATION_REQUIRED_BEFORE_PUBLIC_RELEASE`. Ambience is still blocked.
* ~~**Ali visual calibration (v1.26A plus hotfix/v1.36B)**~~ — **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** Run frames remain normalized; LAND has a dedicated calibrated scale; post-checkpoint height cleanup is automated-tested.
* ~~**v1.27 — Father Ending Family Group Scene**~~ — **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** Family composition/reset is tested; current Father ending phrase remains unchanged by owner decision.
* ~~**v1.2B — Dust/Shadow Polish**~~ — **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** Dust and impact effects work; the reported black rectangle was replaced with a soft oval shadow.
* **v1.34 — Level 1 Gold Candidate:** **AUTOMATED GOLD CANDIDATE / OWNER VISUAL AND AUDIO REVIEW REQUIRED.** Do not declare Final Gold yet.
* ~~**Menu motion smoothing (v1.25A-P)**~~ — **DONE.** Both the Play button pulse and Ali's idle bob already use `TRANS_SINE`/`EASE_IN_OUT` with gentle scales (1.05 and 1.04 respectively) and long periods (0.9s and 1.2s). The "not started" status was stale; code was already correct. Confirmed in final audit.
* **Arabic title reconsideration (v1.36 planning; tracked as v1.25A-P):** "علي رنر" is too narrow for a story that may later include playable Jomana/Zainab. Owner-suggested first try: **"مغامرة نور البيت"** with subtitle **"رحلة في المنطرحة — زليتن"**, keeping "Ali Runner" as the internal/repo name only. Not started — see `docs/AI_GAME_ROADMAP.md` ("v1.25A-P") for the full candidate list.
* ~~**Cinematic intro redesign (v1.25B)**~~ — **IMPLEMENTED / OWNER F6 RETEST REQUIRED.** The in-world Ali/Father intro, heroic focus, living idle motion, and corrected `التالي` placement are automated-tested.

## High-Risk / Later Features

Bigger systems; only attempt once the story and gameplay loop are stable.

* Complex multi-lane coin patterns (beyond simple, clearly-readable coin placement near obstacles).
* Procedural obstacle generation (beyond a small hand-tuned obstacle pool).
* Advanced checkpoint save/load system (persisting progress across sessions, beyond the in-run retry-from-checkpoint in v0.66).
* Cinematic intro prototype (static background + Arabic narration line, then start game).
* Real `Camera2D` zoom and focus moments (zoom on Ali at intro, focus on checkpoints) — must not break the fixed viewport layout. Note: checkpoint encounters use a safe "fake zoom"/no-zoom presentation instead (dim overlay + focused dialogue, no real camera) — first as a popup card (v0.67/v0.70P), now moving to an in-world speech-bubble style (v0.73). This item is specifically about upgrading to a true `Camera2D` zoom later, once the in-world presentation is stable and a real camera can be added without breaking the fixed viewport. Remains later/out of scope for v0.73.
* Background motion / parallax (moving clouds, dust particles, moving palm leaves) — must not affect gameplay collision.
* Character animation expansion (beyond Ali's basic poses, for sisters/father if ever animated).
* Dynamic music mood changes per story chapter (intro calm, after Fatima warmer, after Zainab braver, after Jomana more energetic, father ending emotional/victory — see `docs/AUDIO_DESIGN_PLAN.md`, roadmap "Future — Dynamic Music").
* **v1.4X — Optional Non-Colliding Companion Followers:** Zainab and Jomana may later appear as small visual followers behind Ali after joining. Higher risk and future only: no collision bodies, no gameplay effect, no extra lanes, and followers pause during checkpoints/Game Over. Fatima remains a seated baby portrait/icon and never runs. Implement only after v1.26 is stable.
* Web export (HTML5).
* Android export (only after web export is stable).

## Dream Backlog

Ideas only — not scoped, not scheduled, must not affect Level 1 (Al-Mantarah) development.

* **Part 2 — Sisters Adventure.** Confirmed direction (owner note, 2026-06-28): yes, a future second part could let the player play as one of Ali's sisters in another location. Early ideas:
  * جمانة في الشط — Jomana at the beach (Zliten seafront).
  * زينب في حديقة أو طريق جديد — Zainab in a garden or a new road/area.
  * فاطمة كـ baby bonus character — Fatima as a baby bonus character (not a full runner, consistent with her size/role rules in `docs/STORY_PLAN.md`).
  * Not touched now — focus stays on completing Ali's story in Al-Mantarah first. Level 1 must first reach **v1.34 — Level 1 Gold Candidate**, then **v1.35 — Complete Roadmap Refresh**, before **v2.0 — Level 2 Design Plan** (see `docs/AI_GAME_ROADMAP.md` and the new `docs/LEVEL_2_PLAN.md`) turns this idea into an actual plan. None of v1.34/v1.35/v2.0 are started.
* Beach level (Zliten seafront) as a continuation of Ali's own story, separate from the Part 2 sisters idea above.
* Desert level.
* Full cinematic cutscene system (beyond the simple static-background intro in v1.1).
* Complex branching dialogue tree.
* Meta-progression / permanent upgrades (roguelite-style): a currency the player collects and spends between runs to unlock permanent upgrades (e.g. double jump, a starting shield). Interesting idea, but it changes the game from "one fixed-difficulty story level" into a persistent-progression game — needs its own save/load system (see "Advanced checkpoint save/load system" above) and a shop/upgrade UI. Not compatible with the current scope; only reconsider after v1.0 ships, and only if the owner actively wants this structural change.
* Cloud saves, accounts, login, online features, ads — explicitly out of scope per the project's Core Rule for Future AI Agents.

---

## Design Decisions — Not Doing For Now

Documented so future planning (or a coding agent reading the docs) doesn't re-propose these.

* **No HP/lives bar.** One hit still ends the run immediately. The v0.66 checkpoint retry system, plus Zainab's future one-hit shield (v0.9), already give the player a forgiving second chance without a numeric health counter — simpler and more consistent with the one-tap, child-friendly design than a health bar would be.
* **No procedural terrain/floor generation.** The road is a fixed visual baseline representing a real street (Al-Mantarah, Zliten) — generating it procedurally would fight the art direction. The project's equivalent of "procedural generation" is randomized obstacle *selection* from a small hand-tuned pool (see "Random obstacle pool" above and `docs/ANIMATION_AND_ASSET_PLAN.md` "Random Obstacle Selection Design"), which is already planned and is sufficient.

---

## Future Asset Names (Planning Reference)

These are documented now so future Codex tasks use consistent paths. None of these files are required to exist yet.

Characters (Ali animation poses, sister/father helpers): see `docs/ANIMATION_AND_ASSET_PLAN.md` for the full path list and the staged implementation plan.

* `res://assets/characters/fatima/fatima_helper.png`
* `res://assets/characters/zainab/zainab_helper.png`
* `res://assets/characters/jomana/jomana_helper.png`
* `res://assets/characters/father/father_ending.png`
* `res://assets/characters/fatima/fatima_companion.png`
* `res://assets/characters/zainab/zainab_companion.png`
* `res://assets/characters/jomana/jomana_companion.png`

The three companion paths are optional future slots for v1.26/v1.27/v1.4X. Stage 1 needs only a small transparent portrait/icon; existing helper portraits may be reused if they remain readable. Missing companion files must use safe fallbacks.

Obstacle variety: see `docs/ANIMATION_AND_ASSET_PLAN.md` ("Obstacle Variety Planning") for the full path list — as of v0.75, all five planned obstacle types (`obstacle_block.png`, `obstacle_barrier.png`, `obstacle_cone.png`, `obstacle_crate.png`, `obstacle_sign.png`) exist with real PNG art.

UI:

* `res://assets/ui/dialogue_panel.png`
* `res://assets/ui/star_reward.png`
* `res://assets/ui/heart_courage.png`
* `res://assets/ui/key_path.png`
* `res://assets/ui/shield_icon.png`
* `res://assets/ui/boost_icon.png`

Audio:

See `docs/AUDIO_DESIGN_PLAN.md` for the full organized audio asset path list (UI, player, gameplay, story, ambience, music subfolders), licensing rules, and required `docs/AUDIO_CREDITS.md` format for when audio files are actually added.
