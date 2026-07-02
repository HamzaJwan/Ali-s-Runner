# Level 2 Current State — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Branch: level2/jomana-marsa-mvp-20260701 | Commit: 0da5f76

**Status: OWNER_REVIEW_NEEDED — two showstopper bugs remain before visual approval**

---

## 1. Executive Summary

| Field | Value |
|---|---|
| Level name | جمانة وأثر الكلمة |
| Scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Latest commit | `0da5f76` — level2: fix start flow and add ambient parallax smoke |
| Visual status | Start screen: BEAUTIFUL. Gameplay: 2 showstoppers remain (obstacle skin, buildings seam) |
| Deployed | NO — not wired to main menu, not on any public URL |
| Production Level 1 | Fully untouched, live at game.juanspace.org |

---

## 2. Gameplay Design

Level 2 uses the **same physics engine as Level 1** (CharacterBody2D, shared `player.gd`).
Nothing about the core gameplay feel was changed.

| Rule | Value |
|---|---|
| Runner type | Fixed side-scrolling (camera does not track horizontally) |
| Jump | One-button only (Space / click / tap) |
| Double jump | NO — by design |
| Slide | NO — by design |
| Enemies | NO — by design |
| HP / lives | NO — by design |
| Water death | NO — by design |
| Hostile animals | NO — seagulls are decorative |
| Starting speed | 225 px/s |
| Speed after Ali | 240 px/s |
| Speed after Zainab | 255 px/s |
| Speed after Fatima | 270 px/s |
| Ending trigger | Score 90 (after Father checkpoint) |

---

## 3. Story and Checkpoints

The family checkpoints pause gameplay and show a dialogue card with one family member.

| Score | Character | Arabic Name | Value Theme | Status |
|---|---|---|---|---|
| 15 | Ali (brother) | علي | الكلمة الطيبة بين الأخوة | Card shows (text fallback — no portrait art yet) |
| 35 | Zainab (sister) | زينب | الصبر والتفكير الهادئ | Card shows (text fallback) |
| 60 | Fatima (mother) | فاطمة | الرفق والرحمة | Card shows (text fallback) |
| 90 | Father | الأب | التوكل والعمل وخير العائلة | Card shows (text fallback) → triggers ending |

After Father: ending panel shows "أحسنتِ يا جمانة" / "كل كلمة طيبة تترك أثرًا".
Two buttons: Return to Menu / Replay Chapter 2. Both work correctly.

**Family portrait PNGs** (`ali_checkpoint_01.png` etc.) are NOT yet generated.
The styled color-coded text card is the intentional production fallback until art is created.

---

## 4. Background Environment

### Layer Stack (camera-relative, top to bottom)

| Z | Layer Node | Asset | Status | Notes |
|---|---|---|---|---|
| -99 | ColorRect fill | solid sky blue | ACTIVE | Eliminates color gaps at any zoom |
| -30 | L2_SkyLayer | bg_sky_marsa.png | ACTIVE | Camera-fixed, no drift |
| -18 | L2_FarBuildingsLayer | bg_harbor_buildings.png | ACTIVE | Fixed X, no drift, top-fade shader (55px) |
| -12 | AmbientLife boats | boat_blue_01.png, boat_small_02.png | ACTIVE | Bob animation, z=-8 |
| -8 | AmbientLife flags | small_flags_line_01.png | ACTIVE | Sway animation |
| -8 | AmbientLife net | deco_fishing_net_pile_01.png | ACTIVE | Static |
| -8 | AmbientLife seagulls | seagull_fly_sheet_4f.png | ACTIVE | 3 birds, looping flight |
| -5 | L2_ForegroundPierLayer | fg_pier_ground.png | ACTIVE | Aligned to CURB_TOP_Y=470 (72% screen height) |

### Disabled Plates

| Asset | Reason |
|---|---|
| bg_sea_breakwater.png | Opaque 24-bit RGB — stacking creates visible horizontal seam |
| mg_boats_mid.png | Opaque 24-bit RGB — same issue; replaced by transparent boat props |
| rope_hanging_01.png | No anchor context visible → appears floating; disabled by QA |

### Parallax / Motion Strategy

The gameplay camera is **fixed** — no horizontal tracking during play.
All motion is **ambient-only**:
- Seagulls: cross-screen flight (SeagullLoop script)
- Boats: vertical bob (HarborAmbientBob script, amplitude 3.5px, period 2.6s)
- Flags: gentle sway (HarborAmbientSway script)
- Sky / buildings / pier: fully static (no horizontal drift)

**IMPORTANT:** `HARBOR_DRIFT_SPEED = 3.0` is currently active for the buildings layer.
This is a known bug (B2 below) that creates a vertical seam. Codex must fix it.

---

## 5. Jomana Character

### Asset Status

| Asset | Path | Frames | Status |
|---|---|---|---|
| Run animation | `assets/level2/marsa/characters/jomana/run/jomana_run_01-08.png` | 8 | ACTIVE ✅ |
| Idle animation | `assets/level2/marsa/characters/jomana/idle/jomana_idle_01-04.png` | 4 | ACTIVE ✅ |
| Jump pose | `assets/level2/marsa/characters/jomana/jump/jomana_jump_01.png` | 1 | ACTIVE ✅ |
| Land pose | `assets/level2/marsa/characters/jomana/jump/jomana_land_01.png` | 1 | ACTIVE ✅ |
| Story/wave | `assets/level2/marsa/characters/jomana/story/jomana_smile_wave_01.png` | 1 | ACTIVE ✅ |
| Dialogue closeup | `assets/level2/marsa/characters/jomana/story/jomana_dialogue_closeup_01.png` | 1 | Available, not yet wired |

### Animation State Machine

| Pose | When | Script |
|---|---|---|
| IDLE | Menu (start screen) | jomana_player_visual.gd |
| RUN | During gameplay | jomana_player_visual.gd |
| JUMP | On jump input | jomana_player_visual.gd |
| LAND | On landing | Returns to RUN after 0.2s |
| STORY | During checkpoints | jomana_player_visual.gd |

Ali ghost suppression runs every `_process()` tick (after physics) to counteract
`player.gd._physics_process()` re-enabling the Level 1 Ali sprite each frame.

---

## 6. Obstacles

### Type Mapping

| Level 1 Type | Level 2 Visual | PNG Asset | Visual Height |
|---|---|---|---|
| block | Concrete harbor block | obs_concrete_block_01.png | 88px (was 72) |
| barrier | Bollard with rope | obs_bollard_rope_01.png | 80px (was 70) |
| cone | Bollard with rope | obs_bollard_rope_01.png | 80px (was 70) |
| crate | Stacked crates | obs_crate_stack_01.png | 96px (was 88) |
| sign | Broken pier chunk | obs_broken_pier_chunk_01.png | 72px (was 64) |

**NOTE:** These updated heights are the Codex target. Current commit still has the old values.
Skin application is also broken (B1 below) — current F6 shows Level 1 red barriers.

### Suppression Logic

`level2_obstacle_visuals.gd::apply_skin()` hides both:
- `Polygon2D` — Level 1 procedural rectangle
- `ObstacleSprite` — Sprite2D loaded by `obstacle.gd configure()` with L1 asset

Then adds an `L2Skin` Sprite2D child with the harbor PNG, bottom-aligned using:
`skin.position.y = collision_height/2 - visual_height/2`

---

## 7. Collectibles

| Item | Value |
|---|---|
| Asset | `col_light_shard_pink_01.png` |
| Animated sheet | `col_athar_shard_sheet_6f.png` (available, not animated yet) |
| Visual height | 30px (current, too small) → 48px target (Codex fix needed) |
| Level 1 visual suppression | Hides both `Polygon2D` and `ShardSprite` nodes |

### Lane Patterns (per-cycle of 14 collectibles)

| Pattern | Count | Y (world) | Requires |
|---|---|---|---|
| LOW_LINE | 4 | ROAD_SURFACE_Y - 25px | Running — no jump needed |
| SMALL_ARC | 5 | ROAD_SURFACE_Y - 75px | Light jump |
| FULL_ARC | 5 | ROAD_SURFACE_Y - 120px | Full jump |

---

## 8. Audio

All 8 Level 2 audio files are present and wired. WAV loop mode is set at runtime.

| File | Event | Format |
|---|---|---|
| sea_ambience_loop.wav | Menu/background | WAV, loops |
| marsa_theme_loop.wav | Gameplay music | WAV, loops |
| seagull_distant_01.wav | Ambient seagull call | WAV |
| athar_pickup_01.wav | Collectible collected | WAV |
| checkpoint_chime_01.wav | Checkpoint reached | WAV |
| retry_soft_01.wav | Retry button pressed | WAV |
| jomana_jump_01.wav | Jump input | WAV |
| footstep_stone_01.wav | Footstep on pier | WAV |

OGG conversion is an optional future optimization for smaller web bundle size.

---

## 9. Mobile / Web

- The mobile landscape rotate overlay (`mobile_rotate_overlay.gd`) is an autoload that shows
  "اقلب الهاتف بالعرض" when `height > width`. It applies to the whole project including Level 1.
- Level 2 is **NOT in the web build** — not wired to main menu, not deployed.
- Level 1 at `game.juanspace.org` is unaffected by all Level 2 work.

---

## 10. Known Bugs (Codex Fix Required)

| ID | Bug | Root Cause | Fix Location |
|---|---|---|---|
| B1 | Level 1 red obstacle barrier still showing | `apply_skin` called with 3 args, takes 2 — Godot 4.x throws "Invalid call", skin never applies | `level2_marsa_playable.gd` line ~857 |
| B2 | Hard vertical seam in buildings layer ~60s into gameplay | `harbor_phase` drifts buildings left; non-seamless image shows copy-join | `level2_marsa_playable.gd` `_update_background_parallax()` |
| B3 | Pink shard collectible too small (30px) | Scale constant `30.0` calibrated for L1 Ali, too small for L2 Jomana | `level2_marsa_playable.gd` `_apply_l2_collectible_visual()` |
| B4 | `rope_hanging_01.png` appears floating | No visible anchor context | `level2_marsa_playable.gd` `_build_ambient_props()` |

See the QA report (produced 2026-07-02) for detailed root cause and exact Codex fix prompt.

---

## 11. Known Limitations (Not Bugs)

1. Family checkpoint portraits → styled text card fallback (intentional — art not generated)
2. True 5-layer parallax → needs transparent/seamless asset versions (authoring task for owner)
3. Animated shard (6-frame sheet) → not yet wired; single PNG is active
4. `jomana_dialogue_closeup_01.png` → available but not wired to dialogue UI
5. Level 1 → Level 2 chapter transition → documented in `docs/GAME_CHAPTER_FLOW.md`, not implemented
6. OGG audio → WAV works; OGG is a future web-optimization
