# خطوات الخير — Level 2 Production Roadmap
# جمانة وأثر الكلمة — مرسى زليتن
# Last updated: 2026-07-02 | Branch: level2/jomana-marsa-mvp-20260701

---

## Design Pillars

| Pillar | Meaning |
|---|---|
| أجواء عائلية آمنة | No violence, no enemies, no water death, no scary tone |
| هوية مرسى زليتن | Fishing boats, seagulls, stone pier, Mediterranean light |
| عالم حي ومقروء | Living sea/wind/birds — but never distracting from obstacles |
| بساطة التحكم | One-button jump, same jump feel as Level 1, no Double Jump or Slide |
| قصة مبنية على القيم | الكلمة الطيبة → الصبر → الرفق → التوكل — through family encounters |
| أداء الويب/الهاتف | CPUParticles only, lightweight shaders, Compatibility renderer |

---

## Must NOT Build (Ever, Unless Owner Changes Design)

- Enemies or hostile animals
- Hostile seagulls
- Water death gaps / Jomana falling into sea
- Double jump
- Slide mechanic
- Moving platforms
- Complex GPU particle systems
- Skeleton2D for MVP (research only, not production)
- Multiple playable characters in one level

---

## Sprint History and Status

### Sprint 1 — Foundation
**Status: DONE**
- Playable scene `Level2_Marsa_Playable.tscn`
- Shared Level 1 physics (unmodified `player.gd`, `obstacle_spawner.gd`)
- 5-node background container (`L2_SkyLayer` through `L2_ForegroundPierLayer`)
- Procedural ColorRect background (placeholder)
- Camera cinematic reveal (0.88 → 1.18 over 1.4s)
- Checkpoint skeleton (Ali/Zainab/Fatima/Father at scores 15/35/60/90)
- Game Over + Retry/Restart flow

### Sprint 2 — Real Art Integration
**Status: DONE**
- Jomana 8-frame run animation (`jomana_run_01-08.png`) — normalized 384×512
- Jomana 4-frame idle + jump + land + story poses
- `jomana_player_visual.gd` — auto-detects PNGs, falls back to placeholder
- Ali ghost suppression via `_process()` running after `_physics_process()`
- `level2_asset_manifest.gd` — single source of truth for all paths
- `level2_environment_visual.gd` — 3-plate PNG background auto-loader
- Background top-fade shader (`bg_top_fade.gdshader`) — 55px blend on buildings

### Sprint 3 — Camera and Gameplay Feel
**Status: DONE**
- Fixed camera: `GAMEPLAY_ZOOM=1.18`, `CAM_SCREEN_X=200`, no per-frame horizontal tracking
- Lookahead baked into `_gameplay_cam_pos` (not dynamic)
- `VERTICAL_OFFSET=-14` — slight high camera, keeps jump arc visible, reduces ground share
- Pier at 72% screen height (aligns to `CURB_TOP_Y=470`)
- Camera race condition fixed: `_begin_run()` no longer drives camera tween
- One tween path only: `_play_harbor_reveal()` on first play, `_apply_gameplay_cam()` on retry

### Sprint 4 — Environment Composition
**Status: DONE (except B2 buildings drift — Codex fix pending)**
- 3-plate active composition: sky + buildings (top-fade shader) + pier
- `bg_sea_breakwater.png` and `mg_boats_mid.png` disabled (opaque, create seams)
- 2-sprite side-by-side technique for buildings (2×1152 = 2304 world units coverage)
- Sky ColorRect fill (z=-99) eliminates any color gap
- **B2 BUG PENDING:** buildings drift (`HARBOR_DRIFT_SPEED=3.0`) creates vertical seam. Fix: set buildings X fixed (same as sky + pier).

### Sprint 5 — Collectibles and Obstacles
**Status: PARTIAL — B1 and B3 pending**
- Collectible spawner: level2-local `level2_collectible_spawner.gd`
- Pattern cycling: LOW_LINE(4) → SMALL_ARC(5) → FULL_ARC(5) → repeat (cycle=14)
- Level 1 collectible visuals hidden: `Polygon2D` + `ShardSprite`
- L2 shard `col_light_shard_pink_01.png` added as `L2ShardSprite`
- Obstacle visual skins: `level2_obstacle_visuals.gd` — hides `Polygon2D` + `ObstacleSprite`, adds `L2Skin`
- **B1 BUG PENDING:** `apply_skin()` called with 3 args (should be 2) → skin never applies → L1 red barrier shows
- **B3 BUG PENDING:** shard visual height 30px → needs 48px for Jomana's scale
- SpawnTimer `one_shot=false` fixed (was causing only 1 obstacle ever)
- GroundBase hidden when pier PNG loads

### Sprint 6 — Story Checkpoints
**Status: DONE (text cards) / BLOCKED (portrait art)**
- `Level2EncounterData` — complete dialogue for all 4 family members
- `level2_family_checkpoint_visuals.gd` — loads PNG portrait if present, falls back to text card
- `_build_npc_card()` — color-coded panel per character (Ali=teal, Zainab=orange, Fatima=pink, Father=deep-blue)
- After Father: ending panel "أحسنتِ يا جمانة" / "كل كلمة طيبة تترك أثرًا"
- **BLOCKED:** family portrait PNGs not yet generated (`ali_checkpoint_01.png` etc.)

### Sprint 7 — Audio
**Status: DONE**
- `level2_audio_manager.gd` — all 8 WAV files integrated
- WAV loop mode set at runtime (`AudioStreamWAV.LOOP_FORWARD`)
- All events wired: menu music, gameplay music, pickup, checkpoint, retry, jump, footstep
- OGG conversion: optional future optimization for web bundle size

### Sprint 8 — QA and Owner F6
**Status: IN PROGRESS**
- QA report produced 2026-07-02: 4 bugs identified (B1–B4)
- Codex fix prompt written
- **WAITING:** Codex to apply 4-bug patch
- **WAITING:** Owner F6 review after patch

### Sprint 9 — Internal Web Staging
**Status: NOT STARTED — blocked on Sprint 8 approval**
- Codex cherry-pick to `test-web-deploy` branch
- Web export with existing Godot settings
- Deploy to internal staging URL (NOT game.juanspace.org main route)
- Mobile landscape test
- Owner signs off on staging build
- **Do NOT start until owner approves F6**

### Sprint 10 — Production Promotion
**Status: NOT STARTED — blocked on Sprint 9**
- Level 1 → Level 2 chapter transition (see `docs/GAME_CHAPTER_FLOW.md`)
- Wire Level 2 into main menu (new chapter select or auto-continue)
- Public promotion to `game.juanspace.org`
- **Do NOT start until Sprint 9 is complete and owner explicitly approves**

---

## Future / Nice-to-Have (Not in MVP Scope)

| Feature | Status |
|---|---|
| Animated shard (6-frame sheet) | Available PNG, not wired |
| `jomana_dialogue_closeup_01.png` wired to dialogue UI | Available PNG, not wired |
| Rare collectibles (shell, starfish) | Scope expansion — after MVP ships |
| Jomana dress/hair secondary animation | After MVP ships |
| More obstacle variety | After MVP ships |
| Weather transitions | After MVP ships |
| OGG audio | Future web optimization |
| Transparent sea/boats layers (true 5-layer parallax) | Requires re-authoring assets with alpha channel |
| Level 3 (Zainab's chapter) | After Level 2 reaches production |
