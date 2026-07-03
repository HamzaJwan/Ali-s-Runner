# Level 2 Development Roadmap — جمانة وأثر الكلمة

**Game:** خطوات الخير | **Level 2 place:** مرسى زليتن | **Hero:** جمانة

---

## Phase 1 — Playable Foundation ✅ COMPLETE

- [x] Isolated Level 2 playable scene (`Level2_Marsa_Playable.tscn`)
- [x] Jomana placeholder (teal polygon, same physics as Level 1 Player.tscn)
- [x] Procedural 5-layer harbor background (zero external assets)
- [x] Family checkpoints: Ali (15) → Zainab (35) → Fatima (60) → Father (90)
- [x] Game Over card with retry/restart
- [x] Ambient life: seagulls, boat bob, water shimmer shader
- [x] Level 2 encounter data with family characters
- [x] Documentation: LEVEL2_PLAYABLE_TEST.md, MULTI_CODER_WORKFLOW.md

---

## Phase 2 — Game Feel 🔄 IN PROGRESS

- [x] Camera zoom upgrade: 1.18 → 1.38
- [x] Look-ahead camera (smooth lerp toward track ahead)
- [x] Vertical offset to keep jump arc in frame
- [x] Harbor reveal animation improvement (0.95 → 1.38)
- [x] Checkpoint order updated: Ali → Zainab → Fatima → Father
- [x] Jomana animation pipeline (`jomana_player_visual.gd`) — ready for real frames
- [x] Progressive difficulty speeds: 225 → 240 → 255 → 270
- [ ] Real Jomana run/idle/jump frames (waiting on owner art)
- [ ] Parallax background scrolling (waiting on real Sprite2D layers)
- [ ] Subtle foot dust on run/land

---

## Phase 3 — Character Lane 🎨 NEXT

**One coder, dedicated to:** `assets/level2/marsa/characters/jomana/`

- [ ] Drop `jomana_run_01.png … 08.png` → auto-loads in `jomana_player_visual.gd`
- [ ] Drop `jomana_idle_01.png … 04.png`
- [ ] Drop `jomana_jump_01.png`, `jomana_land_01.png`
- [ ] Drop `jomana_smile_wave_01.png` for checkpoint moments
- [ ] Calibrate foot alignment to pier surface
- [ ] Test at GAMEPLAY_ZOOM 1.38 — confirm Jomana is readable

See `docs/level2/JOMANA_IMAGE_REQUESTS.md` for exact specs and AI prompts.

---

## Phase 4 — Environment Lane 🌊 PLANNED

**One coder, dedicated to:** `assets/level2/marsa/backgrounds/`

- [ ] Source/generate 5 background PNG layers (see `LEVEL2_VISUAL_DIRECTION.md`)
- [ ] Replace procedural `ColorRect` shapes with `Sprite2D` layers
- [ ] Add `BackgroundMotion` parallax (existing Level 1 system, but with Sprite2Ds)
- [ ] Pier ground texture (stone/limestone)
- [ ] Test on mobile/web (Compatibility renderer)

---

## Phase 5 — Gameplay Dressing Lane 🏗️ PLANNED

**One coder, dedicated to:** `assets/level2/marsa/obstacles/` + `collectibles/`

- [ ] Harbor obstacle skins (concrete block, crates, bollards, stone chunk)
- [ ] Collectible shard redesign if needed (current pink crystal → may become sea crystal)
- [ ] Checkpoint NPC art (Ali, Zainab, Fatima, Father at harbor position)
- [ ] Verify obstacle readability rules (see `LEVEL2_OBSTACLE_READABILITY.md`)

---

## Phase 6 — Audio Lane 🎵 PLANNED

**One coder, dedicated to:** `assets/level2/marsa/audio/`

- [ ] Sea ambience loop (CC0 — must document source before integration)
- [ ] Soft harbor music (distinct from Level 1 calm music)
- [ ] Seagull cry SFX (short, occasional, non-annoying)
- [ ] Collectible pickup sound (can reuse Level 1 `shard_pickup.wav`)
- [ ] All audio needs credits entry before integration

---

## Phase 7 — Polish and QA 🔍 FUTURE

- [ ] Owner F6 visual review — full playthrough
- [ ] Arabic text approval for all checkpoint dialogue
- [ ] Web performance test (Compatibility renderer, single-threaded)
- [ ] Mobile touch test
- [ ] Integration decision: wire Level 2 into main menu or standalone launch
- [ ] Level 2 build for internal testing
- [ ] No public release until all owner gates are approved

---

## Gate Before Any Next Phase

**Owner must approve Level 2 game feel (camera + Jomana visual) before**
starting Phases 3–7. A single F6 play-through with feedback is enough.

---

## What Will NOT Be in Level 2

- ❌ Double jump
- ❌ Slide mechanic
- ❌ Enemies or hostile NPCs
- ❌ HP/lives bar
- ❌ Shop or upgrades
- ❌ Seagulls as hazards
- ❌ Fishing nets as gameplay obstacles
- ❌ Physics changes from Level 1
