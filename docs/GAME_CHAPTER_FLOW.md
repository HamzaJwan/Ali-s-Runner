# Game Chapter Flow — خطوات الخير
# One game, multiple chapters. Last updated: 2026-07-03

---

## Core Concept

خطوات الخير is ONE unified game with a chapter-based structure.
Each chapter is a different child in Zliten with a different value theme.
Chapters share the same one-button runner mechanic but have distinct heroes,
environments, music, and story checkpoints.

Core message: كل خطوة طيبة تترك أثرًا.

---

## Chapter Structure

### Chapter 1 — علي (Level 1)
- Hero: علي
- Place: منطقة المنطرحة، زليتن
- Theme: أثر الخير الأول داخل العائلة
- Scene: scenes/Main.tscn (current default boot scene)
- Status: PRODUCTION-READY, deployed at game.juanspace.org

### Chapter 2 — جمانة (Level 2)
- Hero: جمانة
- Place: مرسى زليتن
- Title: جمانة وأثر الكلمة
- Theme: الكلمة الطيبة، الصبر، الرفق، التوكل والعمل، العائلة
- Checkpoint order: Ali(15) → Zainab(35) → Fatima(60) → Father(90)
- Scene: scenes/level2/Level2_Marsa_Playable.tscn
- Status: INTERNAL F6 TESTING — real art integrated, audio integrated, pending owner F6 approval

### Future chapters (not planned yet)
- Chapter 3: Zainab — blocked until Chapter 2 reaches production

---

## Intended Game Flow (Target)

```
Main Menu (خطوات الخير)
    │
    ▼
Chapter 1: Ali
    │  [Player completes Level 1 — reaches Father checkpoint]
    ▼
Chapter Transition Card
"انتهت رحلة علي... والآن جاء دور جمانة"
    │
    ▼
Chapter 2: Jomana
    │  [Player completes Level 2 — reaches Father checkpoint]
    ▼
Chapter 2 Ending / Family Marsa Scene
    │
    ▼
(Future) Chapter Select or Credits
```

---

## Current State (2026-07-03)

| Component | Status |
|---|---|
| Level 1 (Ali) | PRODUCTION — deployed, story polished 2026-07-02 |
| Level 2 (Jomana) F6 scene | PARALLAX_CANDIDATE — commit 101bdfe; motion improved, tile joins need cleanup |
| Chapter transition card | PARTIAL — completion UI reuses the Level 1 Game Over card |
| Level 1 → Level 2 transition | IMPLEMENTED / OWNER FLOW REVIEW REQUIRED in 318d131 |
| Level 2 in main menu | NOT YET — isolated by design |

**Transition review gate:** direct scene loading was implemented before Level 2 owner approval.
Keep it isolated on this branch until the visual composition and full chapter flow pass owner F6.

---

## Recommended Architecture: GameFlow Scene

The current branch uses a direct button-to-scene change. If a reusable chapter system is desired
after owner approval, the recommended target architecture remains:

### Step 1: Level 1 completion signal
Add to scripts/main.gd:
```gdscript
signal level_completed(level_id: String)
```
Emit it at the Father checkpoint ending (after the final dialogue closes).
This is a 3-line change in Level 1, fully reversible.

### Step 2: Chapter transition card
Create:
  scenes/chapter_transition.tscn
  scripts/chapter_transition.gd

Shows:
- Arabic chapter title
- Brief value summary
- 3-second fade, then auto-proceeds

### Step 3: GameFlow scene (or simple autoload)
Create:
  scenes/GameFlow.tscn
  scripts/game_flow.gd

Responsibilities:
- Listen for level_completed("level1")
- Show chapter transition card
- Load Level 2 scene
- On Level 2 completed: show transition or return to menu

### Step 4: Level 2 entry contract
Level 2 always starts clean:
- reset score to 0
- reset speed to 225
- reset collectible count
- no Level 1 checkpoint state leaks
- show Level 2 title card ("جمانة وأثر الكلمة")

### Step 5: Web test
After local validation:
- Merge/cherry-pick Level 2 into test-web-deploy worktree
- Export Web build
- Deploy to game.juanspace.org

---

## Mobile Landscape Gate (Shared UX)

The mobile landscape overlay (`scripts/ui/mobile_rotate_overlay.gd`) is an autoload
and therefore active in ALL chapters automatically:

- Chapter 1 (Ali) — already in main scene via autoload ✅
- Chapter 2 (Jomana) — also via autoload ✅
- Future chapters — automatic, no per-chapter setup needed

The overlay is the first UX layer every mobile player sees. It is chapter-agnostic
and should be kept working at all times.

---

## Safety Constraints

- Level 1 must NEVER break during Level 2 development.
- Level 2 F6 standalone testing must remain working at all times.
- Do not make Level 2 the default boot scene until owner approves.
- Do not merge to main until all validation passes.
- Do not deploy Level 2 publicly until owner reviews F6 real-art + audio.

---

## Next Steps for Integration

1. Repair Level 2 opaque-plate tile joins without losing the stronger running motion.
2. Add a full integration test: Level 1 Father -> completion card -> Level 2 load -> ending.
3. Owner completes F6 visual, flow, and audio review.
4. Decide whether to keep the direct button or replace it with a reusable GameFlow scene.
5. Run internal staging review.
6. Merge and deploy only after explicit owner approval.
