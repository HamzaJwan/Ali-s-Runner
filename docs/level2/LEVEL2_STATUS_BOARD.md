# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Commit: 0da5f76

**Gate: OWNER_REVIEW_READY — automated checks pass; F6 approval still required**

Open this file to know where things stand in 30 seconds.

---

## Current State

| Field | Value |
|---|---|
| Scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Commit | `0da5f76` |
| Deployed | NO |
| Level 1 | UNTOUCHED — live at game.juanspace.org |

---

## What Works Right Now

| Item | Evidence |
|---|---|
| Start screen — beautiful harbor | Owner screenshot confirmed: mosque, boats, flags, Jomana idle ✅ |
| Jomana real art running (8 frames) | Screenshot shows real art, correct animation ✅ |
| 3-plate background (sky + buildings + pier) | No horizontal band seams ✅ |
| Seagulls flying | 3 birds visible in gameplay screenshots ✅ |
| Boat bob animation | Boats behind pier wall ✅ |
| Flag sway animation | Flags visible in harbor ✅ |
| Pink shard collectibles spawning | Pink shards visible in screenshots (too small, see B3) ✅ |
| Collectible patterns cycling (LOW/ARC) | Pattern logic implemented ✅ |
| Story checkpoint flow | Text card appears, advance with tap, ends after Father ✅ |
| Game Over panel (Arabic) | Animated, Retry/Restart work ✅ |
| Fixed camera (no race condition) | No sliding/race condition since commit 524ffda ✅ |
| Audio 8/8 files integrated | sea/theme/seagull/pickup/checkpoint/retry/jump/footstep ✅ |
| Mobile landscape overlay | "اقلب الهاتف بالعرض" shows on portrait ✅ |
| Level 1 completely unaffected | Confirmed across all commits ✅ |

---

## B1-B4 Fix Status

| ID | Status | Result |
|---|---|---|
| B1 obstacle skin | FIXED | Uses emitted `id`; runtime verifies harbor skin and hidden legacy nodes |
| B2 buildings seam | FIXED | Opaque non-tileable harbor plate is fixed horizontally |
| B3 shard scale | FIXED | Pink/gold shard target height is 48px |
| B4 floating rope | FIXED | Rope disabled; flags placed at harbor anchor zone |

Owner F6 must visually confirm these fixes before staging.

---

## Blocked (Not a Code Issue)

| Item | What Is Needed |
|---|---|
| Family portrait art at checkpoints | PNGs detected locally but untracked; owner must approve provenance and commit them separately |
| Family ending image | `family_ending_01.png` detected locally but untracked; source fallback remains safe |
| True 5-layer parallax | Re-author bg_sea_breakwater + mg_boats_mid as transparent-channel images |
| OGG audio conversion | Optional — WAV works; OGG smaller for web |

---

## Must NOT Be Touched

- `scenes/Main.tscn` — Level 1 scene
- `scripts/main.gd` — Level 1 controller
- `scripts/obstacle.gd` — Level 1 obstacle (shared, no changes allowed)
- `D:\GODOT\test1\test-web-deploy` — Docker web deploy directory
- Docker / Web export / Deployment scripts
- Main menu scene (Level 2 must NOT be wired to main menu yet)

---

## Next Actions in Order

1. **Owner** — F6 review: confirm no red barriers, no seam, shard visible, composition clean
3. **Owner decision** — approve or reject for internal staging
4. **Codex** (if approved) — cherry-pick to test-web-deploy, export, deploy to internal staging URL
5. **Owner** — approve/provenance-check the currently untracked family PNGs before committing them
