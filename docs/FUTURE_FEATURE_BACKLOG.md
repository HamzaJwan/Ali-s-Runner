# Ali Runner — Future Feature Backlog

## Golden Rule

Do not implement all backlog features at once. Every feature must be one small Codex task. After every Codex task, test with F6 before continuing.

---

## Safe Next Features

Low risk, small scope, build directly on existing patterns.

* Obstacle spawn offscreen fix (v0.61 — obstacles spawn outside the right edge and enter naturally, instead of appearing in the middle of the screen).
* Arabic dialogue system (reuse one checkpoint panel, swap text per character — see `docs/STORY_PLAN.md`).
* Story checkpoint panel (pause, show portrait + dialogue, Continue button).
* Father ending / final success panel.
* Difficulty chapters tied to checkpoints (slightly faster/harder after each sister).
* Audio foundations (button click, jump, land, checkpoint, game over, victory, one soft background loop — see `docs/AUDIO_DESIGN_PLAN.md`, roadmap v0.95).

## Medium-Risk Features

More moving parts, still scoped to one feature at a time.

* Checkpoint retry system (track last reached checkpoint, retry from there instead of always restarting from the beginning — see roadmap v0.66).
* Emotional Game Over variants (death screen text changes based on the last checkpoint reached — see `docs/STORY_PLAN.md` "Death and Retry Tone").
* Coins / collectibles risk-reward (tempts the player to leave the safe path; must never create unfair or impossible jumps — see roadmap "Future — Coins / Collectibles Risk-Reward").
* Random obstacle pool (choosing among multiple obstacle types at random) — only after the offscreen spawn fix and at least one extra obstacle type are individually stable.
* Obstacle variety (one new safe obstacle type at a time: concrete block, road barrier, construction cone, low crate, broken road sign).
* Standalone collectible pickups, separate from story rewards (e.g. `date_collectible.png`, `star_collectible.png`, `coin_collectible.png`) — optional, deferred from the main roadmap (was the old "v0.85 — Collectibles" milestone).
* Ali basic animation (idle_breathing, run, jump, fall, land, slide, hurt, victory — one pose at a time).
* Real reward effects (Fatima bonus star, Zainab one-hit shield, Jomana boost/safer spacing — one at a time).
* Dialogue typing sound (typewriter-style blips during Arabic story text, with skip-to-complete option — see roadmap v0.96).
* Ambience layers (wind, birds, distant city loop, kept low volume and non-distracting — see roadmap v0.97).

## High-Risk / Later Features

Bigger systems; only attempt once the story and gameplay loop are stable.

* Complex multi-lane coin patterns (beyond simple, clearly-readable coin placement near obstacles).
* Procedural obstacle generation (beyond a small hand-tuned obstacle pool).
* Advanced checkpoint save/load system (persisting progress across sessions, beyond the in-run retry-from-checkpoint in v0.66).
* Cinematic intro prototype (static background + Arabic narration line, then start game).
* Camera zoom and focus moments (`Camera2D`, zoom on Ali at intro, focus on checkpoints) — must not break the fixed viewport layout.
* Background motion / parallax (moving clouds, dust particles, moving palm leaves) — must not affect gameplay collision.
* Character animation expansion (beyond Ali's basic poses, for sisters/father if ever animated).
* Dynamic music mood changes per story chapter (intro calm, after Fatima warmer, after Zainab braver, after Jomana more energetic, father ending emotional/victory — see `docs/AUDIO_DESIGN_PLAN.md`, roadmap "Future — Dynamic Music").
* Web export (HTML5).
* Android export (only after web export is stable).

## Dream Backlog

Ideas only — not scoped, not scheduled, must not affect Level 1 (Al-Mantarah) development.

* **Part 2 — Sisters Adventure.** Confirmed direction (owner note, 2026-06-28): yes, a future second part could let the player play as one of Ali's sisters in another location. Early ideas:
  * جمانة في الشط — Jomana at the beach (Zliten seafront).
  * زينب في حديقة أو طريق جديد — Zainab in a garden or a new road/area.
  * فاطمة كـ baby bonus character — Fatima as a baby bonus character (not a full runner, consistent with her size/role rules in `docs/STORY_PLAN.md`).
  * Not touched now — focus stays on completing Ali's story in Al-Mantarah first.
* Beach level (Zliten seafront) as a continuation of Ali's own story, separate from the Part 2 sisters idea above.
* Desert level.
* Full cinematic cutscene system (beyond the simple static-background intro in v1.1).
* Complex branching dialogue tree.
* Cloud saves, accounts, login, online features, ads — explicitly out of scope per the project's Core Rule for Future AI Agents.

---

## Future Asset Names (Planning Reference)

These are documented now so future Codex tasks use consistent paths. None of these files are required to exist yet.

Characters:

* `res://assets/characters/fatima/fatima_helper.png`
* `res://assets/characters/zainab/zainab_helper.png`
* `res://assets/characters/jomana/jomana_helper.png`
* `res://assets/characters/father/father_ending.png`

UI:

* `res://assets/ui/dialogue_panel.png`
* `res://assets/ui/star_reward.png`
* `res://assets/ui/heart_courage.png`
* `res://assets/ui/key_path.png`
* `res://assets/ui/shield_icon.png`
* `res://assets/ui/boost_icon.png`

Audio:

See `docs/AUDIO_DESIGN_PLAN.md` for the full organized audio asset path list (UI, player, gameplay, story, ambience, music subfolders), licensing rules, and required `docs/AUDIO_CREDITS.md` format for when audio files are actually added.
