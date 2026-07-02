# Level 2 Asset Inventory — جمانة وأثر الكلمة
# Last updated: 2026-07-02
# Single source of truth for all assets. When an asset ships, update Status here.

---

## Background Plates

| File | Path | Status | Notes |
|---|---|---|---|
| bg_sky_marsa.png | assets/level2/marsa/backgrounds/ | ACTIVE | 1058×371 RGB. Camera-fixed sky backdrop. |
| bg_harbor_buildings.png | assets/level2/marsa/backgrounds/ | ACTIVE | 1058×253 RGB. Fixed X (no drift). Top-fade shader blends top 55px into sky. |
| fg_pier_ground.png | assets/level2/marsa/backgrounds/ | ACTIVE | 1058×282 RGB. Aligns to CURB_TOP_Y=470 (72% screen). |
| bg_sea_breakwater.png | assets/level2/marsa/backgrounds/ | DISABLED | 1058×341 RGB. Opaque — creates horizontal seam when stacked on buildings. |
| mg_boats_mid.png | assets/level2/marsa/backgrounds/ | DISABLED | 1058×233 RGB. Opaque — same seam issue. Replaced by transparent boat props. |

Note: All 5 background PNGs are 24-bit opaque RGB. True 5-layer parallax requires re-authoring
bg_sea_breakwater and mg_boats_mid as RGBA transparent cutout images.

---

## Jomana Character

| File | Path | Status | Notes |
|---|---|---|---|
| jomana_run_01.png | .../characters/jomana/run/ | ACTIVE | Frame 1 of 8 run cycle. 384×512 normalized canvas. |
| jomana_run_02.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_03.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_04.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_05.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_06.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_07.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_run_08.png | .../characters/jomana/run/ | ACTIVE | |
| jomana_idle_01.png | .../characters/jomana/idle/ | ACTIVE | 4-frame idle cycle used on menu. |
| jomana_idle_02.png | .../characters/jomana/idle/ | ACTIVE | |
| jomana_idle_03.png | .../characters/jomana/idle/ | ACTIVE | |
| jomana_idle_04.png | .../characters/jomana/idle/ | ACTIVE | |
| jomana_jump_01.png | .../characters/jomana/jump/ | ACTIVE | Single jump pose frame. |
| jomana_land_01.png | .../characters/jomana/jump/ | ACTIVE | Single land pose frame. Returns to RUN after 0.2s. |
| jomana_smile_wave_01.png | .../characters/jomana/story/ | ACTIVE | Used during checkpoints (STORY pose). |
| jomana_dialogue_closeup_01.png | .../characters/jomana/story/ | AVAILABLE | Not yet wired to dialogue UI. |

---

## Family Checkpoint Portraits

| File | Path | Status | Notes |
|---|---|---|---|
| ali_checkpoint_01.png | assets/level2/marsa/characters/family/ | MISSING | Not yet generated. Styled text card is fallback. |
| zainab_checkpoint_01.png | assets/level2/marsa/characters/family/ | MISSING | Not yet generated. Styled text card is fallback. |
| fatima_checkpoint_01.png | assets/level2/marsa/characters/family/ | MISSING | Not yet generated. Styled text card is fallback. |
| father_checkpoint_01.png | assets/level2/marsa/characters/family/ | MISSING | Not yet generated. Styled text card is fallback. |
| family_marsa_ending_01.png | assets/level2/marsa/characters/family/ | MISSING | Not yet generated. Ending panel shows text only. |

Fallback behavior: `level2_family_checkpoint_visuals.gd` loads PNG if present; if missing,
`_build_npc_card()` in the main controller creates a color-coded styled panel with the Arabic name.

---

## Obstacles

| File | Path | Status | Level 1 Type | Notes |
|---|---|---|---|---|
| obs_concrete_block_01.png | assets/level2/marsa/obstacles/ | ACTIVE | block | Visual height 88px. |
| obs_bollard_rope_01.png | assets/level2/marsa/obstacles/ | ACTIVE | barrier, cone | Visual height 80px. Used for both barrier and cone. |
| obs_crate_stack_01.png | assets/level2/marsa/obstacles/ | ACTIVE | crate | Visual height 96px. |
| obs_broken_pier_chunk_01.png | assets/level2/marsa/obstacles/ | ACTIVE | sign | Visual height 72px. |

Note: Skin application is currently broken (B1 bug). Codex fix required.
After fix: `ObstacleSprite` + `Polygon2D` hidden; `L2Skin` Sprite2D added with bottom alignment.

---

## Collectibles

| File | Path | Status | Notes |
|---|---|---|---|
| col_light_shard_pink_01.png | assets/level2/marsa/collectibles/ | ACTIVE | Single pink/gold shard. 48px target visual height (after B3 fix). |
| col_athar_shard_sheet_6f.png | assets/level2/marsa/collectibles/ | AVAILABLE | 6-frame animated sheet. Not yet wired. |

Level 1 visuals hidden on spawn: `Polygon2D` (yellow placeholder) + `ShardSprite` (L1 animation).

---

## Ambient Props

| File | Path | Status | Notes |
|---|---|---|---|
| seagull_fly_sheet_4f.png | assets/level2/marsa/ambient/seagulls/ | ACTIVE | 4-frame wing-beat sheet. 3 seagulls looping across sky. |
| boat_blue_01.png | assets/level2/marsa/ambient/boats/ | ACTIVE | Blue fishing boat. Bob animation (amplitude 3.5px, period 2.6s). World Y=452. |
| boat_small_02.png | assets/level2/marsa/ambient/boats/ | ACTIVE | Smaller boat. Bob animation. World Y=458. |
| small_flags_line_01.png | assets/level2/marsa/ambient/wind_props/ | ACTIVE | Colorful hanging flags. Sway animation. World Y=435 (after B4 fix). |
| rope_hanging_01.png | assets/level2/marsa/ambient/wind_props/ | DISABLED | Floating without anchor context. Commented out in code. |
| deco_fishing_net_pile_01.png | assets/level2/marsa/ambient/deco/ | ACTIVE | Static net pile at ground level. |

---

## Audio

| File | Path | Status | Event |
|---|---|---|---|
| sea_ambience_loop.wav | assets/level2/marsa/audio/ | ACTIVE | Menu background ambience. Loops. |
| marsa_theme_loop.wav | assets/level2/marsa/audio/ | ACTIVE | Gameplay music. Loops. |
| seagull_distant_01.wav | assets/level2/marsa/audio/ | ACTIVE | Ambient seagull call. |
| athar_pickup_01.wav | assets/level2/marsa/audio/ | ACTIVE | Collectible collected. |
| checkpoint_chime_01.wav | assets/level2/marsa/audio/ | ACTIVE | Checkpoint reached. |
| retry_soft_01.wav | assets/level2/marsa/audio/ | ACTIVE | Retry button pressed. |
| jomana_jump_01.wav | assets/level2/marsa/audio/ | ACTIVE | Jump input. |
| footstep_stone_01.wav | assets/level2/marsa/audio/ | ACTIVE | Footstep on pier stone. |

All audio is WAV format. Loop mode set at runtime via `AudioStreamWAV.LOOP_FORWARD`.
OGG conversion is a future optional optimization for smaller web bundle size.

---

## Shaders

| File | Path | Status | Purpose |
|---|---|---|---|
| bg_top_fade.gdshader | assets/level2/marsa/shaders/ | ACTIVE | Fades top 55px of buildings plate to transparent so it blends into sky. |

---

## Scripts — Level 2 Exclusive

| File | Path | Purpose |
|---|---|---|
| level2_marsa_playable.gd | scripts/level2/ | Main Level 2 controller — all gameplay, camera, parallax, UI |
| level2_asset_manifest.gd | scripts/level2/ | Single source of truth for all asset paths |
| level2_encounter_data.gd | scripts/level2/ | Family dialogue data, checkpoint scores, RTL utilities |
| level2_environment_visual.gd | scripts/level2/environment/ | Loads 3-plate PNG background, applies z-indices and shader |
| jomana_player_visual.gd | scripts/level2/character/ | Jomana animated sprite — auto-loads PNG frames, pose state machine |
| level2_obstacle_visuals.gd | scripts/level2/gameplay/ | Harbor obstacle skin adapter — adds L2Skin Sprite2D to each obstacle |
| level2_collectible_spawner.gd | scripts/level2/gameplay/ | Level 2 local collectible spawner with lane pattern cycling |
| level2_audio_manager.gd | scripts/level2/audio/ | Wraps Level 1 audio, adds Level 2 WAV files |
| level2_family_checkpoint_visuals.gd | scripts/level2/story/ | Loads family portrait PNGs for checkpoints (falls back to text) |
| seagull_loop.gd | scripts/level2/ambient/ | Seagull cross-screen flight animation |
| harbor_ambient_bob.gd | scripts/level2/ambient/ | Vertical bob animation for boats |
| harbor_ambient_sway.gd | scripts/level2/ambient/ | Horizontal sway animation for flags |

## Scripts — Tools (Headless QA)

| File | Path | Purpose |
|---|---|---|
| level2_asset_check.gd | scripts/tools/ | Reports present/missing Level 2 assets. Exit 0 always. |
| level2_runtime_smoke.gd | scripts/tools/ | Calls debug_start_gameplay_for_smoke() and checks play path starts. |
| rc_smoke_check.gd | scripts/tools/ | General project boot check. |
