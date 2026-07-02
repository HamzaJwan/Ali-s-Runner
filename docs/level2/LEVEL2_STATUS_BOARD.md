# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Gameplay-feel base: 5a491f3

**Gate: GAMEPLAY_FEEL_PASS_IMPLEMENTED — automated checks pass; owner F6 feel review required**

Open this file to know where things stand in 30 seconds.

---

## Current State

| Field | Value |
|---|---|
| Scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Commit | `5a491f3` |
| Deployed | NO |
| Level 1 | UNTOUCHED — live at game.juanspace.org |

---

## What Works (Owner F6 Confirmed)

| Item | Evidence |
|---|---|
| Start screen — beautiful harbor | Screenshot confirmed: mosque, boats, flags, Jomana idle ✅ |
| Jomana real art running (8 frames) | Real art working correctly ✅ |
| Harbor obstacles — NO red L1 barrier | Concrete block, bollard, crates, pier chunk showing ✅ |
| Background clean — no seam bands | 3-plate composition working ✅ |
| Buildings fixed — no vertical seam | Drift disabled ✅ |
| Pink shard (48px) visible | Correct size ✅ |
| Rope prop disabled | No floating rope ✅ |
| Seagulls, boat bob, flag sway | Ambient life working ✅ |
| Story checkpoints (Ali/Zainab/Fatima/Father) | Text card flow works ✅ |
| Game Over / Retry / Restart | All working ✅ |
| Level 2 ending after Father | Family image + panel + replay/menu buttons working in code; F6 review pending |
| Audio 8/8 WAV files | All wired ✅ |
| Mobile landscape overlay | Working ✅ |
| Level 1 completely unaffected | Confirmed ✅ |

---

## B1–B4 Bug Status (All Fixed)

| ID | Status | Fix |
|---|---|---|
| B1 obstacle skin | FIXED | Uses `definition["id"]`; harbor PNG applied; L1 visuals hidden first |
| B2 buildings seam | FIXED | HARBOR_DRIFT_SPEED=0; buildings X is fixed |
| B3 shard scale | FIXED | L2_COLLECTIBLE_VISUAL_HEIGHT=48px |
| B4 rope prop | FIXED | Rope disabled (no anchor context) |

---

## P1–P5 — Gameplay Feel Status

| ID | Issue | Impact |
|---|---|---|
| P1 | IMPLEMENTED / RUNTIME PASS | Mouse 10/10, touch, and Space use gameplay-only paths; UI states block jumps |
| P2 | IMPLEMENTED / F6 REVIEW | Start changes to RUN with a short 0.18s alpha settle |
| P3 | IMPLEMENTED / F6 REVIEW | All five skins pass width/height/bottom checks; collision unchanged |
| P4 | IMPLEMENTED / F6 REVIEW | Transparent boats raised 34px and retain gentle bob motion |
| P5 | IMPLEMENTED / F6 REVIEW | Foot-aligned dust plus flags, boats, and seagulls provide honest motion |

See `docs/level2/LEVEL2_CODEX_GAMEPLAY_FEEL_PASS.md` for exact Codex instructions.

---

## C1–C7 — Story / Encounter Status

| ID | Issue | Impact |
|---|---|---|
| C1 | IMPLEMENTED / F6 REVIEW | Subtitle card is 720×148 at screen Y=12–160 |
| C2 | IMPLEMENTED / F6 REVIEW | Dim overlay reduced to 30% |
| C3 | IMPLEMENTED / AUTOMATED PASS | Speaker changes between helper, Jomana, and reward |
| C4 | IMPLEMENTED / TEXT REVIEW | Ali now teaches Jomana about kind words |
| C5 | IMPLEMENTED / AUTOMATED PASS | NPC and encounter art are removed before countdown |
| C6 | IMPLEMENTED / OWNER TEXT REVIEW | Final dialogue and explicit speaker stored per step |
| C7 | PRESERVED | Feminine-address ending wording remains in the existing ending flow |

See `docs/level2/LEVEL2_STORY_DIALOGUE_QA.md` for full corrected dialogue and root causes.

---

## Family Assets Integrated by This Patch

Owner-generated family portraits are loaded by the encounter helper and staged with this patch:

| File | Status |
|---|---|
| ali_checkpoint_01.png | Integrated; target height 165px |
| zainab_checkpoint_01.png | Integrated; target height 155px |
| fatima_checkpoint_01.png | Integrated; target height 140px and remains smallest |
| father_checkpoint_01.png | Integrated; target height 205px |
| family_ending_01.png | Integrated into the Level 2 ending |

Missing files remain fallback-safe through the existing generated NPC card.

---

## Blocked (Not a Code Issue)

| Item | What Is Needed |
|---|---|
| True 5-layer parallax | Buildings stay fixed and seam-safe; re-author sea/buildings/boats as transparent RGBA cutouts |
| OGG audio | Optional optimization for smaller web bundle |
| Seamless foreground tile | For optional foreground scroll enhancement |

---

## Must NOT Be Touched

- `scenes/Main.tscn` — Level 1 scene
- `scripts/main.gd` — Level 1 controller
- `scripts/obstacle.gd` — Level 1 obstacle (shared)
- `D:\GODOT\test1\test-web-deploy` — Docker web deploy directory
- Docker / Web export / Deployment scripts
- Main menu scene (Level 2 must NOT be wired yet)

---

## Next Actions in Order

1. **Owner** — F6 review: run checklist in `docs/level2/LEVEL2_PLAYABLE_TEST.md`
2. **Owner decision** — approve or reject for internal staging
3. **Codex** (if approved) — cherry-pick to test-web-deploy, export, deploy to internal staging
4. **Post-F6 polish (only if requested)** — tune width caps, dust strength, or boat baseline from F6 evidence

## Level 1 → Level 2 Transition Status

**NOT YET IMPLEMENTED** — documented only.
See `docs/GAME_CHAPTER_FLOW.md` and `docs/GAME_CHAPTER_STORY_BIBLE.md`.
Level 2 is not in the main menu. Must NOT be wired until owner approves Level 2 for production.
