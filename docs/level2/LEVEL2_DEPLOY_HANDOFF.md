# Level 2 Deploy Handoff — جمانة وأثر الكلمة
# Status: OWNER_REVIEW_NEEDED
# Last updated: 2026-07-02

---

## STOP — Read Before Deploying

**DO NOT DEPLOY LEVEL 2 TO PRODUCTION.**

Level 2 is not approved for public release. The production route `game.juanspace.org`
must only serve Level 1 until the owner explicitly gives go-ahead.

Two showstopper bugs (B1 obstacle skin, B2 buildings seam) must be fixed and
owner F6 must pass before any staging deployment.

---

## Quick Status

| Field | Value |
|---|---|
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Entry scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Level 1 untouched | YES — confirmed across all commits |
| Docker/deploy untouched | YES |
| Playable in F6 | YES (with known bugs B1-B4) |
| Owner F6 approval | PENDING (after Codex applies 4-bug patch) |
| Staging approved | NO |
| Production approved | NO |

---

## Current Camera / Framing

| Constant | Value | Notes |
|---|---|---|
| GAMEPLAY_ZOOM | 1.18 | Jomana ~188px tall on screen |
| CAM_SCREEN_X | 200 | Jomana at ~17% from left edge |
| LOOKAHEAD_X | 0 | Baked into CAM_SCREEN_X |
| VERTICAL_OFFSET | -14 | Slightly high: jump arc visible, ground share = 28% |
| Pier on screen | 72% from top | Matches CURB_TOP_Y=470 world physics |
| Camera type | FIXED - no per-frame horizontal tracking | One tween on Play, then locked |

---

## Active Background Plates

| Asset | Status | Role |
|---|---|---|
| bg_sky_marsa.png | ACTIVE | Full-screen backdrop, camera-fixed |
| bg_harbor_buildings.png | ACTIVE | Harbor city silhouette, top-fade shader 55px, FIXED X |
| fg_pier_ground.png | ACTIVE | Foreground pier, aligned to CURB_TOP_Y |

## Disabled Opaque Plates

| Asset | Why Disabled |
|---|---|
| bg_sea_breakwater.png | Opaque RGB - creates visible horizontal seam when stacked |
| mg_boats_mid.png | Opaque RGB - same issue; replaced by transparent boat props |

Note: HARBOR_DRIFT_SPEED const is reserved but buildings X must be fixed (not drifting).
Drift on a non-seamless image creates a vertical seam at the copy-join after ~60s.

---

## Active Transparent Ambient Props

| Asset | Status | Effect |
|---|---|---|
| seagull_fly_sheet_4f.png | ACTIVE | 3 animated seagulls in sky |
| boat_blue_01.png | ACTIVE | Blue fishing boat, bob animation |
| boat_small_02.png | ACTIVE | Small boat, bob animation |
| small_flags_line_01.png | ACTIVE | Colored flags, sway animation |
| deco_fishing_net_pile_01.png | ACTIVE | Static net pile at ground level |
| rope_hanging_01.png | DISABLED | Floating without anchor context |

---

## Obstacle Assets

| Level 1 Type | Level 2 Visual | PNG | Visual Height |
|---|---|---|---|
| block | Concrete block | obs_concrete_block_01.png | 88px |
| barrier | Bollard+rope | obs_bollard_rope_01.png | 80px |
| cone | Bollard+rope | obs_bollard_rope_01.png | 80px |
| crate | Crate stack | obs_crate_stack_01.png | 96px |
| sign | Pier chunk | obs_broken_pier_chunk_01.png | 72px |

Level 1 visuals (ObstacleSprite + Polygon2D) hidden when L2 texture loads.
B1 bug: skins not applied in current commit (3rd arg to apply_skin).

---

## Collectibles

| Asset | Status |
|---|---|
| col_light_shard_pink_01.png | ACTIVE - 48px visual height (after B3 fix) |
| col_athar_shard_sheet_6f.png | Available - not animated yet |

Pattern: LOW_LINE (4) then SMALL_ARC (5) then FULL_ARC (5) then repeat.

---

## Jomana Character Assets

| Asset | Status |
|---|---|
| jomana_run_01-08.png | ACTIVE - 8-frame run cycle |
| jomana_idle_01-04.png | ACTIVE - idle on menu |
| jomana_jump_01.png | ACTIVE - jump pose |
| jomana_land_01.png | ACTIVE - returns to RUN after 0.2s |
| jomana_smile_wave_01.png | ACTIVE - checkpoint/story pose |
| jomana_dialogue_closeup_01.png | Available - not yet wired to dialogue |

---

## Family Checkpoint

| Score | Character | Status |
|---|---|---|
| 15 | Ali | Color-coded text card (blue) - portrait PNG not yet generated |
| 35 | Zainab | Color-coded text card (orange) - portrait PNG not yet generated |
| 60 | Fatima | Color-coded text card (pink) - portrait PNG not yet generated |
| 90 | Father | Color-coded text card (deep blue) then ending panel |

---

## Audio

8/8 WAV files present. WAV loop mode set at runtime. OGG: future optimization.

---

## Bugs to Fix Before Any Deployment

| ID | Bug | Fix Location |
|---|---|---|
| B1 | L1 red barrier showing | Remove 3rd arg from apply_skin call in level2_marsa_playable.gd line 857 |
| B2 | Buildings vertical seam at ~60s | Remove harbor_phase drift, set buildings_layer.position.x = left |
| B3 | Shard 30px too small | Change 30.0 to 48.0 in _apply_l2_collectible_visual() |
| B4 | Rope prop floating | Comment out AMB_ROPE line in _build_ambient_props() |

---

## Instructions for Codex - Internal Staging Only

DEPLOY_STATUS: DO NOT DEPLOY - OWNER_REVIEW_NEEDED

Only proceed with staging after all of:
1. Codex applies 4-bug patch
2. Owner completes F6 review and explicitly approves
3. Staging RC smoke passes

### Staging Deployment Steps (When Approved)

```
# 1. Do NOT use main or test-web-deploy directly
git checkout level2/jomana-marsa-mvp-20260701

# 2. Cherry-pick approved commit to test-web-deploy (separate worktree)
git checkout test-web-deploy
git cherry-pick <approved-commit-hash>

# 3. Export Web build using existing export preset
# Do NOT change export settings

# 4. Deploy to INTERNAL staging route only
# Preferred: game.juanspace.org/level2 or level2-test.juanspace.org
# NOT the main route game.juanspace.org

# 5. Verify Level 1 at game.juanspace.org still works

# 6. If Level 1 is broken: revert immediately
```

### Validation Commands Before Staging

```
Godot_v4.7-stable_win64_console.exe --headless --path . --quit
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
```

### Rollback Policy

If staging breaks Level 1 or causes any regression:
- Revert the cherry-pick on test-web-deploy immediately
- Redeploy Level 1 only
- Report to owner before any further action

### Production Promotion Checklist (All Required)

- [ ] Owner F6 review passed
- [ ] Owner staging review passed
- [ ] All 4 bugs B1-B4 confirmed fixed
- [ ] Family portrait PNGs added (or owner approves text-card fallback for production)
- [ ] RC smoke: exit 0 on all validation commands
- [ ] Level 1 at game.juanspace.org confirmed unaffected
- [ ] Owner explicitly says "deploy to production"

---

## Known Limitations

1. Background seams: fully resolved for 3-plate composition. True 5-layer parallax needs transparent re-authored assets.
2. Family checkpoint portraits: text card fallback (intentional - art pending).
3. Ambient rope: disabled (no anchor context).
4. OGG audio: WAV works; OGG smaller for web.
5. Level 1 to Level 2 chapter transition: documented in docs/GAME_CHAPTER_FLOW.md, not yet implemented.
