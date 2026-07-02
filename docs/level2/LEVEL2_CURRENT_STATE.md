# Level 2 Current State — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Branch: level2/jomana-marsa-mvp-20260701 | Commit: c8ce6e9

**Status: OWNER_REVIEW_NEEDED — visual/gameplay QA pending; do NOT deploy**

---

## 1. Executive Summary

| Field | Value |
|---|---|
| Level name | جمانة وأثر الكلمة |
| Scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Latest Codex commit | `c8ce6e9` — level2: fix obstacle skins seam drift collectibles and ambient props |
| Visual status | Start screen: BEAUTIFUL. Gameplay: improved; 5 gameplay-feel issues remain |
| Deployed | NO — not wired to main menu, not on any public URL |
| Production Level 1 | Fully untouched, live at game.juanspace.org |

---

## 2. What Works (Confirmed by Owner F6)

| Item | Status |
|---|---|
| Start screen: harbor photograph, mosque, boats, flags | ✅ BEAUTIFUL |
| Jomana real art (8-frame run, 4-frame idle, jump, land, wave) | ✅ WORKING |
| Harbor obstacles (concrete block, bollard, crates, pier chunk) | ✅ WORKING — no red L1 barrier |
| 3-plate background (sky + buildings + pier) | ✅ CLEAN — no seam bands |
| Buildings layer: no horizontal drift, no vertical seam | ✅ FIXED |
| Pink shard collectible (48px) | ✅ VISIBLE |
| Rope prop disabled | ✅ CORRECT |
| Seagulls flying | ✅ WORKING |
| Boat bob | ✅ WORKING |
| Flag sway | ✅ WORKING |
| Story checkpoint flow (Ali/Zainab/Fatima/Father) | ✅ WORKING |
| Game Over + Retry + Restart | ✅ WORKING |
| Level 2 ending panel after Father | ✅ WORKING |
| Audio 8/8 WAV files | ✅ WIRED |
| Mobile landscape overlay | ✅ WORKING |
| Level 1 unaffected | ✅ CONFIRMED |

---

## 3. Owner F6 Issues — Needs Codex Pass

| # | Issue | Impact |
|---|---|---|
| P1 | Mouse click does not trigger jump (keyboard works) | HIGH — breaks Web/mobile feel |
| P2 | IDLE → RUN transition is abrupt / snaps | MEDIUM — feels unpolished |
| P3 | Some obstacles visually wider than their collision box | MEDIUM — feels unfair |
| P4 | Boats appear partially sunk under pier edge | LOW — visual composition |
| P5 | Flags lack visible anchor context | LOW — visual coherence |

---

## 4. New Owner Assets (Not Yet Committed)

All 5 family portrait PNGs exist on disk but are UNTRACKED (not in git):

| File | Size | Format | Status |
|---|---|---|---|
| ali_checkpoint_01.png | 642×1254 | RGBA | On disk, untracked |
| zainab_checkpoint_01.png | 639×1254 | RGBA | On disk, untracked |
| fatima_checkpoint_01.png | 738×1254 | RGBA | On disk, untracked |
| father_checkpoint_01.png | 660×1254 | RGBA | On disk, untracked |
| family_ending_01.png | 1008×1003 | RGBA | On disk, untracked |

The code in `level2_family_checkpoint_visuals.gd` already handles these —
it will auto-load them if present. Codex must commit them and verify the scaling/positioning.

---

## 5. Background Plate Status

| Asset | Status | Notes |
|---|---|---|
| bg_sky_marsa.png | ACTIVE | 1058×371 RGB. Camera-fixed. |
| bg_harbor_buildings.png | ACTIVE | 1058×253 RGB. Fixed X (no drift). Top-fade shader 55px. |
| fg_pier_ground.png | ACTIVE | 1058×282 RGB. Aligned to CURB_TOP_Y=470. |
| bg_sea_breakwater.png | DISABLED | Opaque — creates seam. Rich harbor photo covers this zone. |
| mg_boats_mid.png | DISABLED | Opaque — same. Transparent boat props cover this zone. |

---

## 6. Obstacle Mapping

All 4 harbor PNG obstacles are ACTIVE. Collision unchanged from Level 1.

| Level 1 Type | Level 2 PNG | PNG Dimensions | Col Width | Visual Width at 88/80/96/72px |
|---|---|---|---|---|
| block | obs_concrete_block_01.png | 303×193 RGBA | 30px | ~138px (landscape — wide) |
| barrier | obs_bollard_rope_01.png | 402×218 RGBA | 68px | ~147px (landscape — very wide) |
| cone | obs_broken_pier_chunk_01.png | 309×161 RGBA | 30px | ~154px (landscape — too wide) |
| crate | obs_crate_stack_01.png | 283×316 RGBA | 48px | ~86px (portrait — proportional) |
| sign | obs_broken_pier_chunk_01.png | 309×161 RGBA | 38px | ~138px (landscape — wide) |

**Obstacle width issue**: Landscape images scaled by height become 3-5x wider than collision box.
Crate is fine (portrait format). Others need per-obstacle max-width clamping. See QA report.

---

## 7. Family Portraits Status

Auto-load code in `level2_family_checkpoint_visuals.gd` is ready.
Color-coded text card fallback still shows because portrait PNGs are untracked.
Codex must `git add` the family PNG directory and commit them.

---

## 8. Input Status

| Input | Status |
|---|---|
| Space bar → jump | ✅ Works |
| Keyboard tap → jump | ✅ Works |
| Mouse click → jump | ❌ Not working (UI may be consuming events) |
| Touch/tap (mobile) | Not tested — web build not deployed |

---

## 9. Deployment Gate

**DO NOT DEPLOY.** Gates in order:

1. Codex applies gameplay-feel pass (P1–P5 + family portraits)
2. Owner F6 review confirms fix
3. Owner explicitly approves internal staging
4. Codex cherry-picks to test-web-deploy only
5. Owner confirms staging, then approves production
