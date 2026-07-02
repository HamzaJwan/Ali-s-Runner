# Level 2 Playable Test Checklist — جمانة وأثر الكلمة
# Last updated: 2026-07-02

**Status: OWNER_REVIEW_NEEDED — run after Codex gameplay-feel pass**

---

## How to Open the Scene

1. Open Godot editor.
2. In the FileSystem panel, navigate to `scenes/level2/Level2_Marsa_Playable.tscn`
3. Double-click to open.
4. Press **F6** (Run Scene) — NOT F5 (that runs Level 1).

---

## Confirmed Fixes from c8ce6e9

These were verified by code review. Owner F6 confirms them visually:

| Fix | Expected |
|---|---|
| B1 — obstacle skin | Harbor PNGs show (concrete block, bollard, crates, pier chunk) — NO red/white barrier |
| B2 — buildings seam | Background stays clean after 60+ seconds — no vertical cut appears |
| B3 — shard 48px | Pink shard clearly visible during run |
| B4 — rope disabled | No floating rope in sky or harbor area |

---

## Start Screen

- [ ] Title "جمانة وأثر الكلمة" readable and centered
- [ ] Harbor background: sky, buildings, boats, pier — cohesive
- [ ] Jomana stands idle on pier (left side)
- [ ] No Ali ghost visible
- [ ] "ابدئي الرحلة" button visible and clickable
- [ ] Seagulls visible in sky
- [ ] Boats visible behind pier wall (not sinking below pier edge)
- [ ] Boats remain visibly in water through their full bob cycle
- [ ] Flags hanging in harbor area (no rope visible)
- [ ] No horizontal seam bands in background
- [ ] No vertical seam in buildings layer

---

## Play Button / Transition

- [ ] Click "ابدئي الرحلة" → harbor reveal animation plays (~1.4s)
- [ ] Jomana stays IDLE during the camera reveal
- [ ] After reveal settles → Jomana transitions to RUN smoothly (not abrupt snap)
- [ ] HUD "الأثر: 0   ✦ 0" visible in top-left
- [ ] No Ali ghost during gameplay

---

## Jump Input (Critical for Web + Mobile)

- [ ] **Space bar** → jump triggers ✅
- [ ] **Left mouse click** during gameplay → jump triggers (MUST work)
- [ ] Repeat mouse jump at least 10 times — no missed grounded clicks
- [ ] Touch/tap also jumps during gameplay
- [ ] Menu/dialogue/ending button clicks never trigger a jump
- [ ] **Click/tap on background** (not on UI) → jump triggers
- [ ] Jump does NOT advance dialogue when not in checkpoint mode
- [ ] Tap/click on "متابعة" button works correctly during checkpoint

---

## Obstacles

- [ ] First obstacle spawns from right side
- [ ] Obstacle is a HARBOR prop — concrete block / bollard / crates / pier chunk
- [ ] NO red/white Level 1 road barrier visible at any time
- [ ] Obstacle visual width is proportional (not spreading across the full pier width)
- [ ] Obstacle sits ON the pier ground (not floating above, not sinking below)
- [ ] Jump clears the obstacle with reasonable timing
- [ ] Second obstacle spawns (not just one total)
- [ ] After several obstacles: various types appear (not just block)

---

## Collectibles

- [ ] Pink shard is clearly visible (≥48px apparent height)
- [ ] LOW_LINE: shards at run height — collectible without jumping
- [ ] SMALL_ARC: shards in a gentle arc — requires light jump
- [ ] FULL_ARC: shards in high arc — requires full jump
- [ ] Collecting increments "✦N" counter
- [ ] Passing an obstacle updates الأثر without erasing the ✦ count
- [ ] No Level 1 star/heart visible
- [ ] Shards do NOT appear directly inside obstacle collision zones

---

## Background During Gameplay

- [ ] Buildings stay fixed — no drift to the left over time
- [ ] No vertical seam appears even after 60+ seconds
- [ ] No horizontal seam bands
- [ ] Seagulls continue flying throughout
- [ ] Boats visible and bobbing
- [ ] Flags swaying
- [ ] Scene feels alive without being distracting
- [ ] Sandy dust follows Jomana's feet while running and stops while airborne

---

## Jump and Landing

- [ ] Jump arc is visible — head does not clip top of screen
- [ ] Jump animation plays during ascent
- [ ] Land animation plays briefly on landing
- [ ] Returns to RUN after landing (within 0.2s)
- [ ] LAND contact is brief (~0.10s) and never switches to RUN while airborne
- [ ] No lingering LAND pose during next obstacle

---

## Story Checkpoints — Family Portraits

Automated runtime coverage now verifies the Ali checkpoint opens, displays real art
or its safe fallback, cleans the NPC before countdown, restores the gameplay camera,
and resumes both obstacle and collectible spawners. The checks below remain visual.

Reach each score milestone to test:

- [ ] Score 15 → gameplay pauses → **Ali portrait appears** (young boy in white thobe)
- [ ] Ali Arabic name "علي" visible on card
- [ ] Dialogue text readable, not covering portrait
- [ ] Card remains at the top (Y=12–160) and the 30% dim keeps both faces readable
- [ ] Speaker label follows each step, including Ali's two lines and Jomana's replies
- [ ] Tap/Space to advance → Ali's second line → reward text → "متابعة"
- [ ] "متابعة" → countdown 3-2-1 → run resumes at 240 speed
- [ ] Jomana returns to the fixed gameplay position before countdown
- [ ] No helper portrait or NPC remains visible after Continue
- [ ] Obstacles and collectibles resume after the countdown safety window

- [ ] Score 35 → **Zainab portrait** (young girl in pink dress)
- [ ] Score 60 → **Fatima portrait** (baby in pink — smallest character)
- [ ] Score 90 → **Father portrait** (man in suit) → ending

---

## Ending

- [ ] Father checkpoint → "متابعة" → **family ending image** appears (family group photo)
- [ ] Family ending image appears to the left of the ending card and is not hidden behind it
- [ ] Title: "أحسنتِ يا جمانة!"
- [ ] Message: "كل كلمة طيبة تترك أثرًا."
- [ ] "الأثر الذي تركتِه: N" count shown
- [ ] "العودة إلى القائمة" → returns to start screen
- [ ] "إعادة الفصل الثاني" → restarts from score 0

---

## Game Over

- [ ] Hitting obstacle → Jomana stops (IDLE)
- [ ] Game Over panel fades in (Arabic text)
- [ ] "إعادة المحاولة من آخر نقطة" button works
- [ ] "إعادة البدء" button works

---

## What to Accept Without Failing

These are not blocking this F6 review:

| Item | Why Acceptable |
|---|---|
| `jomana_dialogue_closeup_01.png` not wired to dialogue | Available, not MVP requirement |
| Animated shard (6-frame sheet) | Single PNG is fine for MVP |
| Sea/breakwater opaque plates disabled | Harbor photograph covers this visually |
| True 5-layer parallax | Needs transparent asset re-authoring |
| OGG audio conversion | WAV works; OGG is future optimization |

---

## Automated Checks (Headless — Run Before Owner F6)

```
Godot_v4.7-stable_win64_console.exe --headless --path . --quit
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/Level2_Marsa_Playable.tscn --quit
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
```

All must exit 0. LEVEL2_RUNTIME_SMOKE=PASS. No GDScript parse errors.

---

## DO NOT DEPLOY after this F6

Even if all items above pass, Level 2 must not go to `game.juanspace.org`.
Internal staging requires explicit owner approval after this F6.
