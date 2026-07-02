# Level 2 Playable Test Checklist — جمانة وأثر الكلمة
# Last updated: 2026-07-02

**Status: OWNER_REVIEW_READY — B1-B4 fixed; run this F6 checklist**

---

## How to Open the Scene

1. Open Godot editor.
2. In the FileSystem panel, navigate to `scenes/level2/Level2_Marsa_Playable.tscn`
3. Double-click to open.
4. Press **F6** (Run Scene) — NOT F5 (that runs Level 1).

---

## B1-B4 Patch Status

These source fixes are present; the checklist below is their owner visual gate.

| Bug | What You See | Fix Status |
|---|---|---|
| B1 | Level 1 red/white road barrier during gameplay | FIXED - runtime verified |
| B2 | Hard vertical line in buildings background | FIXED - drift disabled |
| B3 | Pink shard collectible too small | FIXED - 48px |
| B4 | Rope prop floating in air | FIXED - rope disabled |

---

## Full Owner F6 Checklist

Run this checklist after the Codex patch is applied.

### Menu / Start Screen

- [ ] Title "جمانة وأثر الكلمة" is readable and centered
- [ ] Subtitle "مرسى زليتن" visible
- [ ] Background shows harbor: sky, buildings, boats, pier
- [ ] Jomana stands idle on the pier (left side of screen)
- [ ] No Ali ghost visible
- [ ] "ابدئي الرحلة" button is visible and clickable
- [ ] No horizontal seam bands in background
- [ ] No vertical seam lines in buildings
- [ ] Seagulls flying in sky (may need a few seconds)
- [ ] Boats visible in harbor background
- [ ] Flags visible and swaying gently
- [ ] No rope prop floating in air

### Starting Gameplay

- [ ] Press "ابدئي الرحلة" → harbor reveal animation plays (1.4s)
- [ ] Jomana starts running (switches to run animation)
- [ ] Camera settles into fixed gameplay position
- [ ] Score "الأثر: 0" visible top-left
- [ ] No Ali ghost behind Jomana

### Obstacles

- [ ] First obstacle spawns from the right side
- [ ] Obstacle visual is a HARBOR prop: concrete block, bollard, crates, or pier chunk
- [ ] NO red/white Level 1 road barrier visible
- [ ] Obstacle sits on the pier ground (not floating)
- [ ] Obstacle is proportionally readable vs Jomana's size
- [ ] Tap/click/Space to jump over obstacle
- [ ] Score increments by 1 on each obstacle passed
- [ ] Second obstacle spawns correctly (not only one total)

### Collectibles

- [ ] Pink shard collectibles appear ahead of Jomana
- [ ] Shard is visible (at least ~48px apparent height)
- [ ] LOW_LINE pattern: shards at run height (no jump needed)
- [ ] SMALL_ARC pattern: shards in a low arc (light jump)
- [ ] FULL_ARC pattern: shards in high arc (full jump)
- [ ] Collecting a shard updates "✦N" counter
- [ ] No Level 1 star/heart visual visible on collectibles

### Environment During Gameplay

- [ ] Background stays fixed (buildings do NOT drift left over time)
- [ ] No vertical seam line in harbor buildings after 60+ seconds
- [ ] No horizontal seam bands between background plates
- [ ] Pier ground texture matches the harbor scene
- [ ] Seagulls continue flying overhead
- [ ] Boats visible and bobbing behind pier wall
- [ ] Flags swaying (if small_flags_line_01.png present)
- [ ] No rope prop floating in air

### Jump Feel

- [ ] Jump feel is same as Level 1 (same physics)
- [ ] Jump arc is visible (head does not clip top of screen)
- [ ] Landing animation plays briefly (Jomana crouches)
- [ ] Returns to run animation automatically after landing
- [ ] Audio plays on jump (if audio files present)

### Collision and Game Over

- [ ] Hitting an obstacle triggers Game Over
- [ ] Jomana stops running (IDLE pose)
- [ ] Game Over panel fades in (Arabic text)
- [ ] "إعادة المحاولة من آخر نقطة" button visible
- [ ] "إعادة البدء" button visible
- [ ] Both buttons work

### Story Checkpoints

Reach the following scores (run for ~5-10 minutes or verify by reviewing code):

- [ ] Score 15 → gameplay pauses → Ali character card appears (BLUE panel)
- [ ] Ali's Arabic name "علي" visible on the card
- [ ] Dialogue step 1 shows (character line)
- [ ] Tap to advance → Jomana response
- [ ] Tap to advance → reward text + "متابعة" button
- [ ] Press "متابعة" → countdown 3-2-1 → run resumes at 240 speed

- [ ] Score 35 → Zainab card (ORANGE panel)
- [ ] Score 60 → Fatima card (PINK panel)
- [ ] Score 90 → Father card (DEEP BLUE panel) → "متابعة" → ENDING

### Ending

- [ ] After Father checkpoint, ending panel appears
- [ ] Title: "أحسنتِ يا جمانة!"
- [ ] Message: "كل كلمة طيبة تترك أثرًا"
- [ ] "الأثر الذي تركتِه: N" count shown
- [ ] "العودة إلى القائمة" button → returns to start screen
- [ ] "إعادة الفصل الثاني" button → restarts from score 0

### Retry Flow

- [ ] After game over → Retry from last checkpoint → countdown → run from last checkpoint score + speed
- [ ] After game over → Restart → run from score 0, speed 225

### Mobile (Future — No Web Build Yet)

- [ ] Rotate phone to landscape → gameplay visible
- [ ] Portrait mode → "اقلب الهاتف بالعرض" overlay (already active in main project)
- [ ] Touch/tap → jump

---

## What to Overlook During This Review

These items are intentionally not ready yet. Do not fail the F6 on these:

| Item | Why It Is Placeholder |
|---|---|
| Family character portrait art | PNG portraits not yet generated; text card is the intentional fallback |
| `jomana_dialogue_closeup_01.png` wired | Available but not yet connected to dialogue UI |
| Animated collectible (6-frame sheet) | Not yet wired; single PNG is fine for MVP |
| Sea / breakwater layer visible | These opaque plates are intentionally disabled; boats replace them |
| True 5-layer parallax depth | Needs transparent/seamless asset re-authoring |

---

## Automated Checks (Headless)

These run without the Godot editor. PASS does not replace human F6 review.

```
# Project loads and boots cleanly
Godot_v4.7-stable_win64_console.exe --headless --path . --quit

# Level 2 scene loads without parser errors
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/Level2_Marsa_Playable.tscn --quit

# Level 2 asset check (reports present/missing)
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd

# Level 2 runtime smoke (confirms play path starts)
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd

# Level 1 regression check (must pass - production scene)
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
```

Expected: all exit 0, no GDScript parse errors, LEVEL2_RUNTIME_SMOKE=PASS.

---

## 2026-07-02 F6 Gate

Apply Codex 4-bug patch first, then run this checklist.
If all required items pass → owner approves → Codex may proceed with internal staging.
