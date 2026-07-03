# Level 2 Asset QA Report — جمانة وأثر الكلمة
# Generated: 2026-07-01 | Branch: level2/jomana-marsa-mvp-20260701

---

## 1. Jomana Character Assets

| Asset | Exists | Original Dims | Normalized | Alpha | Verdict |
|---|---|---|---|---|---|
| jomana_run_01.png | YES | 229x449 | 384x512 | RGBA | PASS |
| jomana_run_02.png | YES | 210x429 | 384x512 | RGBA | PASS |
| jomana_run_03.png | YES | 218x433 | 384x512 | RGBA | PASS |
| jomana_run_04.png | YES | 244x422 | 384x512 | RGBA | PASS |
| jomana_run_05.png | YES | 194x430 | 384x512 | RGBA | PASS |
| jomana_run_06.png | YES | 236x425 | 384x512 | RGBA | PASS |
| jomana_run_07.png | YES | 201x431 | 384x512 | RGBA | PASS |
| jomana_run_08.png | YES | 227x398 | 384x512 | RGBA | PASS |
| jomana_idle_01.png | YES | 311x566 | 384x512 | RGBA | PASS |
| jomana_idle_02.png | YES | 298x565 | 384x512 | RGBA | PASS |
| jomana_idle_03.png | YES | 266x571 | 384x512 | RGBA | PASS |
| jomana_idle_04.png | YES | 279x587 | 384x512 | RGBA | PASS |
| jomana_jump_01.png | YES | 515x730 | 384x512 | RGBA | PASS |
| jomana_land_01.png | YES | 485x751 | 384x512 | RGBA | PASS |
| jomana_smile_wave_01.png | YES | 484x836 | original | RGBA | PASS (story pose) |
| jomana_dialogue_closeup_01.png | YES | 615x719 | original | RGBA | PASS (portrait) |

**Normalization:** All gameplay frames (run 1-8, idle 1-4, jump, land) normalized to 384x512
using scale-to-height method — character fills 512px height, centered in 384px canvas.
Original files preserved in _source/ subfolder. Story/wave frames kept at original size.

**Baseline:** All frames feet at canvas bottom y=512. Script uses CANVAS_HEIGHT=512 reference
(s=160/512=0.3125), centered=false, position=(-60,-136) for foot-grounded alignment.

---

## 2. Background Assets

| Asset | Exists | Dims | Mode | Notes | Verdict |
|---|---|---|---|---|---|
| bg_sky_marsa.png | YES | 1058x371 | RGB | Scale 1.089 fills 1152px width | PASS |
| bg_sea_breakwater.png | YES | 1058x341 | RGB | Scale 1.089 | PASS |
| bg_harbor_buildings.png | YES | 1058x253 | RGB | Scale 1.089 | PASS |
| mg_boats_mid.png | YES | 1058x233 | RGB | Scale 1.089 | PASS |
| fg_pier_ground.png | YES | 1058x282 | RGB | Scale 1.089 | PASS |

**Layer Y positioning fix:** All layers were at world y=0, appearing above the gameplay zone.
Fixed in level2_marsa_playable.gd via _position_background_layers():
  L2_SkyLayer:            y=0   (sky fills upper viewport)
  L2_SeaBreakwaterLayer:  y=294 (sea horizon ~25% down screen)
  L2_FarBuildingsLayer:   y=345 (buildings ~40% down)
  L2_BoatsMidLayer:       y=410 (boats above pier ~55%)
  L2_ForegroundPierLayer: y=446 (pier covers gameplay floor ~65%+)

---

## 3. Obstacle Assets

| Asset | Exists | Dims | Alpha | Role | Verdict |
|---|---|---|---|---|---|
| obs_concrete_block_01.png | YES | 303x193 | RGBA | Low block | PASS |
| obs_crate_stack_01.png | YES | 283x316 | RGBA | Tall stack | PASS |
| obs_bollard_rope_01.png | YES | 402x218 | RGBA | Bollard pair | PASS |
| obs_broken_pier_chunk_01.png | YES | 309x161 | RGBA | Flat rubble | PASS |

**Wiring:** obstacle_spawner.obstacle_spawned signal connected to _on_obstacle_spawned_l2().
Skins applied per spawn. Level 1 ObstacleSpawner NOT modified.

---

## 4. Collectibles

| Asset | Exists | Dims | Alpha | Notes | Verdict |
|---|---|---|---|---|---|
| col_light_shard_pink_01.png | YES | 119x140 | RGBA | Single shard | PASS |
| col_athar_shard_sheet_6f.png | YES | 525x134 | RGBA | 6 frames (87.5x134 each) | PASS |

**Filename fix:** Manifest COL_SHARD_SINGLE updated to col_light_shard_pink_01.png
(was col_athar_shard_pink_gold_01.png which did not exist).

---

## 5. Ambient Props

| Asset | Exists | Dims | Alpha | Role | Distraction | Verdict |
|---|---|---|---|---|---|---|
| seagull_fly_sheet_4f.png | YES | 610x147 | RGBA | 4-frame fly (152x147 each) | Low | PASS |
| boat_blue_01.png | YES | 536x268 | RGBA | BG decoration | Low | PASS |
| boat_small_02.png | YES | 373x246 | RGBA | BG variation | Low | PASS |
| small_flags_line_01.png | YES | 405x126 | RGBA | Wind props deco | Low | PASS |
| rope_hanging_01.png | YES | 503x138 | RGBA | Deco only | Low | PASS |
| deco_fishing_net_pile_01.png | YES | 581x218 | RGBA | BG deco | Medium | PASS_WITH_MINOR_NOTES |

**Minor note:** Fishing net pile is large/colorful. Confirm not confused with obstacle in F6.
**Wiring:** Art ready. Ambient Life Lane to wire seagull sheet and boats into procedural systems.

---

## 6. Integration Status

| System | Status | Notes |
|---|---|---|
| Jomana visual wiring | ACTIVE | _setup_jomana_visual() instantiates jomana_player_visual.gd |
| Jomana AliSprite hiding | ACTIVE | Hidden when real art loads; teal fallback if placeholder |
| Background layer Y positions | FIXED | _position_background_layers() in _ready() |
| Background PNG auto-load | ACTIVE | All 5 layers via level2_environment_visual.gd |
| Obstacle visual skins | ACTIVE | obstacle_spawned signal connected |
| Collectible manifest path | FIXED | Points to actual filename |
| Audio | PENDING | No audio files yet |
| Family checkpoint art | PENDING | 0/4 sprites generated |
| Ambient props wiring | NEXT | Art ready; code needed |

---

## 7. Owner Action Needed

1. F6 review: Open scenes/level2/Level2_Marsa_Playable.tscn, press F6.
   - Does Jomana real art show?
   - Are backgrounds correct?
   - Are obstacles showing harbor PNG skins?
2. Generate family checkpoint art: ali_checkpoint_01.png, zainab_checkpoint_01.png,
   fatima_checkpoint_01.png, father_checkpoint_01.png -> assets/level2/marsa/characters/family/
3. Source CC0 audio: sea_ambience_loop.ogg, marsa_theme_loop.ogg, seagull_distant_01.wav
4. Check fishing net pile is not confused with active obstacle in F6.

---

## 8. Current Readiness

READY_FOR_OWNER_F6_REAL_ART_APPROVAL

All critical integration wiring complete. Real Jomana art, backgrounds, and obstacle skins
are now active in the playable scene. Owner F6 review is the next gate.
