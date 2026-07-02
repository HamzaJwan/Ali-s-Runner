# Level 2 Deploy Handoff — جمانة وأثر الكلمة
# Status: READY_FOR_OWNER_F6_FULL_ASSET_REVIEW
# Last updated: 2026-07-02

---

## Quick Status

| Item | Status |
|---|---|
| Branch | level2/jomana-marsa-mvp-20260701 |
| Level 2 entry scene | scenes/level2/Level2_Marsa_Playable.tscn |
| Level 1 untouched | YES |
| Docker/deploy untouched | YES |
| Playable in F6 | YES |
| Owner F6 approval | PENDING (needs final review) |

---

## Current Camera / Framing

| Constant | Value | Notes |
|---|---|---|
| GAMEPLAY_ZOOM | 1.18 | Jomana ≈ 188px tall on screen |
| CAM_SCREEN_X | 200 | Jomana appears at ~17% from left |
| LOOKAHEAD_X | 0 | Built into CAM_SCREEN_X (≤200 = far left = more road visible) |
| VERTICAL_OFFSET | -14 | Camera slightly high: jump arc visible, ground share reduced |
| Pier on screen | 72% from top | Matches CURB_TOP_Y physics, ground share = 28% |
| Camera type | FIXED — no per-frame tracking | One tween on Play, then locked |

---

## Active Background Plates

| Asset | Status | Role |
|---|---|---|
| bg_sky_marsa.png | ACTIVE | Full-screen backdrop, camera-fixed, + sky fill ColorRect behind |
| bg_harbor_buildings.png | ACTIVE | Harbor middle plate, top-fade shader (55px blend into sky) |
| fg_pier_ground.png | ACTIVE | Foreground gameplay pier, aligned to CURB_TOP_Y |

## Disabled Opaque Plates

| Asset | Status | Why Disabled |
|---|---|---|
| bg_sea_breakwater.png | DISABLED | Opaque RGB — creates visible horizontal seam when stacked on buildings |
| mg_boats_mid.png | DISABLED | Opaque RGB — same issue |

**Note:** True five-layer parallax requires transparent cutout layers for sea, buildings, and boats. Current owner art is 24-bit RGB opaque. These assets need transparent (alpha-channel) re-authoring to enable true parallax without seams.

---

## Transparent Ambient Assets (Active)

| Asset | Status | Role |
|---|---|---|
| seagull_fly_sheet_4f.png | ACTIVE | Animated seagulls in sky area |
| boat_blue_01.png | ACTIVE | Gentle background bob; no collision |
| boat_small_02.png | ACTIVE | Gentle background bob; no collision |
| small_flags_line_01.png | ACTIVE | Subtle sway behind gameplay |
| rope_hanging_01.png | ACTIVE | Subtle sway behind gameplay |
| deco_fishing_net_pile_01.png | ACTIVE | Static decoration behind lane; no collision |

---

## Obstacle Assets

| Level 1 Type | Level 2 Visual | Status |
|---|---|---|
| block | obs_concrete_block_01.png | ACTIVE (72px visual height) |
| barrier | obs_bollard_rope_01.png | ACTIVE (70px) |
| cone | obs_broken_pier_chunk_01.png | ACTIVE (70px) |
| crate | obs_crate_stack_01.png | ACTIVE (88px) |
| sign | obs_broken_pier_chunk_01.png | ACTIVE (64px) |

Level 1 visual (ObstacleSprite + Polygon2D) hidden when L2 texture loads.

---

## Collectibles

| Asset | Status |
|---|---|
| col_light_shard_pink_01.png | ACTIVE — single pink/gold shard (30px visual) |
| col_athar_shard_sheet_6f.png | Available — not yet animated |

Collectible patterns: LOW_LINE (4 shards) → SMALL_ARC (5) → FULL_ARC (5) → cycle.
Level 1 visual (ShardSprite + Polygon2D) hidden on spawn.

---

## Jomana Character Assets

| Asset | Status |
|---|---|
| jomana_run_01..08.png | ACTIVE — 8-frame run animation |
| jomana_idle_01..04.png | ACTIVE — idle on menu |
| jomana_jump_01.png | ACTIVE — jump pose |
| jomana_land_01.png | ACTIVE — land pose |
| jomana_smile_wave_01.png | ACTIVE — story/checkpoint pose |
| jomana_dialogue_closeup_01.png | Available — not yet wired to dialogue UI |

---

## Checkpoint Story

| Score | Character | Arabic | Status |
|---|---|---|---|
| 15 | Ali | علي | NPC card with blue background |
| 35 | Zainab | زينب | NPC card with orange background |
| 60 | Fatima | فاطمة | NPC card with pink background |
| 90 | Father | الأب | NPC card with deep-blue background |

Level 2-specific family portrait PNGs not yet generated. Using styled text cards as intentional fallback.

Speed progression: 225 → 240 (after Ali) → 255 (Zainab) → 270 (Fatima).
After Father: Level 2 ending panel "أحسنتِ يا جمانة / كل كلمة طيبة تترك أثرًا".

---

## Audio

All 8 WAV files present and integrated. WAV loop mode set at runtime.
OGG conversion: documented as future optimization for smaller Web bundle.

---

## Instructions for Codex

**DEPLOY_STATUS: PARTIAL_OWNER_REVIEW_NEEDED**

Do NOT deploy Level 2 publicly until:
1. Owner completes F6 review and approves the composition
2. Family checkpoint portrait art is generated (or owner approves text-card fallback)
3. RC smoke passes on the merged branch

When deploying to internal staging:
- Merge/cherry-pick level2/jomana-marsa-mvp-20260701 into test-web-deploy
- Export Web build with existing settings
- Deploy to game.juanspace.org/level2 (NOT the main route)
- Test on mobile landscape (the overlay gate handles portrait)
- Rollback if Level 1 route (game.juanspace.org) is affected

Do NOT deploy Level 2 to the main public route until the owner explicitly approves.

---

## Codex Structural Cleanup (2026-07-02)

- Level 2 now owns `scripts/level2/gameplay/level2_collectible_spawner.gd`; it no longer rewrites random Level 1 collectible Y positions after spawn.
- One pattern is active at a time: `LOW_LINE`, `SMALL_ARC`, then `FULL_ARC`.
- Visual-only lane offset is `30px`. Physics, gravity, jump, collision, and Level 1 files are unchanged.
- Gameplay camera is fixed at zoom `1.18`, with Jomana at screen X `200`.
- Jomana and harbor obstacle art share visual screen baseline Y `550`.
- Collectible world lanes are `485 / 435 / 390`.
- Existing Level 1 family art is used as checkpoint fallback when dedicated Level 2 portraits are absent.
- Checkpoint dialogue card is now 540x220 in the lower-left; the arriving character is staged on the right.
- Level 2 ending offers both replay and return to the Level 2 menu.

## Start Freeze Hotfix (2026-07-02)

- Root cause in the owner screenshot: Godot was paused on an active editor breakpoint at the former collectible-spawner line. The source was not hung.
- The Play path now rejects double clicks, explicitly unpauses the tree, and starts obstacle and collectible spawners independently with warnings instead of blocking the scene.
- `scripts/tools/level2_runtime_smoke.gd` starts the scene programmatically and verifies gameplay state, player activation, and both timers.
- Fixed-camera ambient motion is active: sky and pier remain fixed, the duplicated harbor plate drifts at `3px/s`, boats bob, flags/rope sway, and seagulls move independently.
- Flags and rope were lowered to the harbor/pier anchor zone so they no longer read as floating in open sky.

## Active Living Harbor Assets

| Asset | Runtime role |
|---|---|
| seagull_fly_sheet_4f.png | independent sky motion |
| boat_blue_01.png | transparent background boat with gentle bob |
| boat_small_02.png | transparent background boat with gentle bob |
| small_flags_line_01.png | subtle wind sway behind gameplay |
| rope_hanging_01.png | subtle wind sway behind gameplay |
| deco_fishing_net_pile_01.png | non-collision background decoration |

## Known Limitations

1. Background seams: fully resolved for 3-plate composition. True 5-layer parallax needs transparent assets.
2. Family checkpoint portraits: using styled text cards (intentional, not broken).
3. Ambient boats/flags/nets: art available, wiring to ambient system pending.
4. OGG audio: WAV works; OGG smaller for Web bundle.
5. Level 1 → Level 2 chapter transition: documented in docs/GAME_CHAPTER_FLOW.md, not yet implemented.
