# Project Current State — خطوات الخير
# Last updated: 2026-07-02

---

## One-Line Summary

Level 1 (Ali) is live and stable. Level 2 (Jomana) is in internal F6 testing with visual and story
encounter improvements pending Codex implementation before owner approval.

---

## Deployment Status

| Chapter | URL | Status |
|---|---|---|
| Chapter 1 — علي | game.juanspace.org | ✅ LIVE — production |
| Chapter 2 — جمانة | localhost (editor F6) | 🔧 INTERNAL — not deployed |
| Chapter 1→2 transition | Not built | 📋 PLANNED |

---

## What Is Working

### Level 1 (production — untouched by Level 2 work)

| Item | Status |
|---|---|
| Ali runner — jump, obstacle, collectible | ✅ |
| Family checkpoints: Fatima(15) Zainab(35) Jomana(60) Father(90) | ✅ |
| Game Over / Retry / Restart flow | ✅ |
| Father ending scene (all family) | ✅ |
| Audio, visual, camera | ✅ |
| Web export at game.juanspace.org | ✅ |
| Mobile landscape on web | ✅ |

### Level 2 (internal only)

| Item | Status |
|---|---|
| Start screen: harbor scene, Jomana idle | ✅ Beautiful |
| Harbor obstacles: concrete block, bollard, crate, pier chunk | ✅ No red L1 barrier |
| Background: sky + buildings + pier (no seam) | ✅ |
| Seagulls, boat bob, flag sway | ✅ |
| Pink shard collectible (48px) | ✅ |
| Story checkpoint flow (text cards) | ✅ |
| Family portraits on disk (RGBA, all 5 files) | ✅ On disk — uncommitted |
| Family portraits loading at checkpoints | ✅ Code ready — needs git add |
| Game Over / Retry / Restart | ✅ |
| Level 2 ending after Father | ✅ |
| Audio 8/8 WAV | ✅ |

---

## What Needs Codex (Implementation Passes)

### Gameplay Feel Pass (from `docs/level2/LEVEL2_CODEX_GAMEPLAY_FEEL_PASS.md`)

| ID | Issue | Priority |
|---|---|---|
| P1 | Mouse click doesn't trigger jump | HIGH |
| P2 | IDLE → RUN transition is abrupt | MEDIUM |
| P3 | Obstacle visual width too wide for landscape PNGs | MEDIUM |
| P4 | Boats sinking below pier edge | LOW |

### Story / Encounter Pass (from `docs/level2/LEVEL2_STORY_DIALOGUE_QA.md`)

| ID | Issue | Priority |
|---|---|---|
| C1 | Checkpoint panel covers characters (Card at Y=382 on 644px screen) | HIGH |
| C2 | DimBG 72% opacity obscures scene | HIGH |
| C3 | Speaker name never updates for ROLE_JOMANA steps | HIGH |
| C5 | NPC doesn't leave screen after "تابع" | HIGH |
| C_asset | Commit family portrait PNGs | HIGH |

---

## What Was Changed in This Session (2026-07-02)

### Level 1 Story (COMMITTED — `scripts/story/encounter_data.gd`)

| What changed | Why |
|---|---|
| Fatima emoji removed from placeholder text and dialogue | Emojis in game strings are unpolished |
| Fatima Ali line: now mentions "أثر" explicitly | Connects to core game message |
| Zainab: added full teaching dialogue (3-step + reward) | More depth; defines courage properly |
| Jomana: added kind-words lesson preview | Seeds Level 2's entire theme |
| Father: added التوكل + "كلامك وخطواتك" | Bridges to Level 2; completes the value set |

**Guaranteed safe:** Only string values changed. No constants, no physics, no signals.

### Documentation (COMMITTED)

| File | Action |
|---|---|
| `docs/GAME_CHAPTER_STORY_BIBLE.md` | NEW — full narrative guide for both chapters |
| `docs/STORY_AUDIT_LEVEL1_LEVEL2.md` | NEW — complete story audit with change log |
| `docs/PROJECT_CURRENT_STATE.md` | NEW — this file |
| `docs/STORY_PLAN.md` | Updated — reflects new approved L1 dialogue |

### Level 2 Dialogue (UNCOMMITTED — Codex changes pending commit)

| File | Status |
|---|---|
| `scripts/level2/level2_encounter_data.gd` | Modified by Codex — improved dialogue, uncommitted |
| `scripts/level2/level2_marsa_playable.gd` | Modified by Codex — gameplay fixes, uncommitted |
| `scripts/level2/gameplay/level2_collectible_spawner.gd` | Modified by Codex — uncommitted |
| `scripts/level2/story/level2_family_checkpoint_visuals.gd` | Modified by Codex — uncommitted |
| `assets/level2/marsa/characters/family/` | 5 RGBA PNGs — untracked (needs git add) |

---

## What Must NOT Be Touched

- `scenes/Main.tscn` — Level 1 production scene
- `scripts/main.gd` — Level 1 controller (only read)
- Level 1 physics: ROAD_SURFACE_Y, jump force, gravity, obstacle timings
- Docker / Web export / D:\GODOT\test1\test-web-deploy
- Main menu (Level 2 must NOT be wired in yet)
- `docs/STORY_PLAN.md` reward texts that are marked owner-approved ("اكتملت الرحلة — المنطرحة، زليتن.")

---

## Level 2 Owner F6 Checklist (Next Gate)

### After Codex applies P1-P5 + C1-C5 + portrait commit:

**Gameplay:**
- [ ] Mouse click triggers jump
- [ ] IDLE → RUN transition is smooth (Jomana stays IDLE during harbor reveal)
- [ ] Obstacles are harbor props (not red barriers)
- [ ] Obstacle width is proportional to Jomana's jump arc

**Story/Encounter:**
- [ ] Score 15 → Ali portrait appears (young boy in white thobe) on screen
- [ ] Dialogue card is at TOP of screen — characters visible below
- [ ] Background visible (dim overlay is light, not dark)
- [ ] Speaker name updates per step (علي vs جمانة)
- [ ] Press "تابع" → Ali slides off screen → countdown → gameplay resumes
- [ ] Score 35 → Zainab portrait
- [ ] Score 60 → Fatima portrait (baby)
- [ ] Score 90 → Father portrait → ending with family group image

**No deployment until:**
- All above F6 items pass
- Owner explicitly approves staging

---

## Safe Staging Plan (When Ready)

1. Codex cherry-pick approved commit → `test-web-deploy` branch
2. Web export with existing settings
3. Deploy to `game.juanspace.org/level2` (NOT main route)
4. Owner tests on mobile landscape
5. Only after owner approves: promote to main game flow (Level 1 → transition → Level 2)
