# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-02 | Commit: c8ce6e9

**Gate: TWO_CODEX_PASSES_NEEDED — gameplay feel (P1-P5) + story/encounter (C1-C7) before F6**

Open this file to know where things stand in 30 seconds.

---

## Current State

| Field | Value |
|---|---|
| Scene | `scenes/level2/Level2_Marsa_Playable.tscn` |
| Branch | `level2/jomana-marsa-mvp-20260701` |
| Commit | `c8ce6e9` |
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
| Level 2 ending after Father | Panel + buttons working ✅ |
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

## P1–P5 — Gameplay Feel Issues (Codex Fix Needed)

| ID | Issue | Impact |
|---|---|---|
| P1 | Mouse click does not trigger jump | HIGH — breaks Web/mobile experience |
| P2 | IDLE → RUN transition is abrupt | MEDIUM — jarring when play pressed |
| P3 | Some obstacles too wide (landscape PNG scaled by height only) | MEDIUM — unfair feel |
| P4 | Boats partially sunk below pier edge | LOW — visual polish |
| P5 | Flags have no visible anchor posts | LOW — visual coherence |

See `docs/level2/LEVEL2_CODEX_GAMEPLAY_FEEL_PASS.md` for exact Codex instructions.

---

## C1–C7 — Story / Encounter Issues (Codex Fix Needed)

| ID | Issue | Impact |
|---|---|---|
| C1 | Checkpoint dialogue panel covers both characters (card at Y=382-602 on 644px screen) | HIGH — breaks cinematic feel |
| C2 | DimBG opacity 72% — scene completely obscured during encounter | HIGH |
| C3 | Speaker name never updates for ROLE_JOMANA steps — always shows character name | HIGH — confusing |
| C4 | Ali Step 2: Jomana teaches Ali instead of Ali teaching Jomana — logic is reversed | HIGH — story wrong |
| C5 | NPC remains on pier after pressing "تابع" — visible during countdown and next gameplay | HIGH |
| C6 | Dialogue text corrections for all 4 characters | MEDIUM |
| C7 | أحسنت → أحسنتِ (feminine suffix for Jomana) in Father's line | LOW |

See `docs/level2/LEVEL2_STORY_DIALOGUE_QA.md` for full corrected dialogue and root causes.

---

## New Assets Ready to Commit

Owner-generated family portraits are on disk but UNTRACKED:

| File | Status |
|---|---|
| ali_checkpoint_01.png (642×1254 RGBA) | On disk — untracked |
| zainab_checkpoint_01.png (639×1254 RGBA) | On disk — untracked |
| fatima_checkpoint_01.png (738×1254 RGBA) | On disk — untracked |
| father_checkpoint_01.png (660×1254 RGBA) | On disk — untracked |
| family_ending_01.png (1008×1003 RGBA) | On disk — untracked |

Code in `level2_family_checkpoint_visuals.gd` will auto-load them once committed.
Codex must `git add assets/level2/marsa/characters/family/` and commit.

---

## Blocked (Not a Code Issue)

| Item | What Is Needed |
|---|---|
| True 5-layer parallax | Re-author sea + boats plates as transparent RGBA cutouts |
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

1. **Codex** — gameplay feel pass (P1–P5): mouse jump, IDLE delay, obstacle width, boats, family portraits
2. **Codex** — story/encounter pass (C1–C7): panel position, DimBG opacity, NPC off-screen, dialogue corrections
3. **Owner** — F6 review: confirm mouse jump, portraits visible, panel does not cover characters, NPC leaves after "تابع"
4. **Owner decision** — approve or reject for internal staging
5. **Codex** (if approved) — cherry-pick to test-web-deploy, export, internal staging only
