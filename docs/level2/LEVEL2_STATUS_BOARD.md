# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Commit: 0da5f76

**Gate: OWNER_REVIEW_NEEDED — fix 4 bugs first, then F6, then staging**

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

## Bugs — Codex Must Fix Before Owner F6

| ID | Bug | Impact |
|---|---|---|
| B1 | Level 1 red/white road barrier still shows during gameplay | Showstopper — wrong obstacles |
| B2 | Hard vertical seam in buildings layer appears ~60s into any run | Showstopper — visible composition break |
| B3 | Pink collectible shard renders at 30px — too small for Jomana's scale | Polish — barely visible |
| B4 | `rope_hanging_01.png` appears unsupported in air | Polish — disable it |

Root causes and exact fixes documented in QA report (2026-07-02).
Codex fix prompt is in the same report.

---

## Blocked (Not a Code Issue)

| Item | What Is Needed |
|---|---|
| Family portrait art at checkpoints | Generate ali/zainab/fatima/father checkpoint PNGs → drop in `assets/level2/marsa/characters/family/` |
| Family ending image | Generate `family_marsa_ending_01.png` |
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

1. **Codex** — apply 4-bug patch from QA report (B1 obstacle skin arg, B2 buildings drift, B3 shard scale, B4 rope disable)
2. **Owner** — F6 review: confirm no red barriers, no seam, shard visible, composition clean
3. **Owner decision** — approve or reject for internal staging
4. **Codex** (if approved) — cherry-pick to test-web-deploy, export, deploy to internal staging URL
5. **Owner** — generate family portrait PNGs to unlock styled checkpoint art
