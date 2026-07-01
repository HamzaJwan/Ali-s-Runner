# Jomana Image Asset Requests — جمانة

**Purpose:** Tell the owner exactly what images to generate (AI) or illustrate.
**Game engine:** Godot 4.7 — images are loaded at runtime, no re-export needed.

---

## Canvas Specification (ALL frames)

| Property | Value |
|---|---|
| Size | **256×256 px** (or 512×512 for higher quality) |
| Background | **Transparent** (PNG with alpha) |
| Orientation | Side view, **facing RIGHT** |
| Character scale | Same in every single frame |
| Foot baseline | Always at **same Y pixel** in every frame |
| Outfit | Same teal/mint dress, same hijab, every frame |
| Face | Same face, same expression style |
| Shadow | No baked shadow |
| Text | No text inside image |

---

## 1. Run Animation — REQUIRED FIRST

**Path:** `assets/level2/marsa/characters/jomana/run/`

| File | Description |
|---|---|
| `jomana_run_01.png` | Left foot back, right foot forward |
| `jomana_run_02.png` | Mid-stride, feet crossing |
| `jomana_run_03.png` | Right foot back, left foot forward |
| `jomana_run_04.png` | Feet together (center point) |
| `jomana_run_05.png` | Mirror of frame 1 |
| `jomana_run_06.png` | Mirror of frame 2 |
| `jomana_run_07.png` | Mirror of frame 3 |
| `jomana_run_08.png` | Mirror of frame 4 |

**AI prompt template (use for each frame, change N):**
```
Frame [N] of 8, side-view running animation of Jomana,
a cheerful young Libyan girl, age 8-10, facing right,
wearing a light teal/mint long dress and teal hijab,
same character proportions in every frame,
transparent background, 256x256 PNG canvas,
feet aligned to the same ground baseline,
clean 2D game character sprite style,
no background scenery, no shadows,
arms and legs naturally in motion for frame [N] of 8-frame run cycle.
```

---

## 2. Idle Animation — HIGH PRIORITY

**Path:** `assets/level2/marsa/characters/jomana/idle/`

| File | Description |
|---|---|
| `jomana_idle_01.png` | Standing still, calm expression |
| `jomana_idle_02.png` | Very slight weight shift left |
| `jomana_idle_03.png` | Back to neutral |
| `jomana_idle_04.png` | Very slight weight shift right |

**AI prompt:**
```
Jomana standing idle, young Libyan girl, teal dress and teal hijab,
facing right, side view, calm gentle expression, slight breathing pose,
transparent background, 256x256 PNG, same foot baseline as run frames.
```

---

## 3. Jump and Land — REQUIRED

**Path:** `assets/level2/marsa/characters/jomana/jump/`

| File | Description |
|---|---|
| `jomana_jump_01.png` | Airborne, arms up, legs tucked slightly |
| `jomana_land_01.png` | Just landed, slight crouch, knees bent |

---

## 4. Story / Checkpoint Poses

**Path:** `assets/level2/marsa/characters/jomana/story/`

| File | Description | When used |
|---|---|---|
| `jomana_smile_wave_01.png` | Big smile, one hand raised/waving | After checkpoint reward |
| `jomana_dialogue_closeup_01.png` | Thoughtful expression, head slightly tilted | During Jomana's dialogue lines |

---

## 5. Optional Future

**Path:** `assets/level2/marsa/characters/jomana/spritesheets/`

| File | Description |
|---|---|
| `jomana_run_spritesheet_8x1.png` | All 8 run frames in one row: 2048×256 px |

---

## Important Rules Across ALL Frames

1. **Same character identity** — face, hijab style, dress color must be identical
2. **Same scale** — Jomana must be the same HEIGHT in every image
3. **Same foot position** — feet must touch the same Y coordinate
4. **No cropping** — head, feet, hands must be fully inside the 256×256 canvas
5. **Transparent background only** — never white, grey, or colored background
6. **Facing RIGHT** — all gameplay art faces right

---

## Where the Code Looks for Files

```gdscript
# scripts/level2/character/jomana_player_visual.gd
const ASSET_ROOT := "res://assets/level2/marsa/characters/jomana/"
# Run: ASSET_ROOT + "run/jomana_run_01.png" ... "jomana_run_08.png"
# Idle: ASSET_ROOT + "idle/jomana_idle_01.png" ... "jomana_idle_04.png"
# Jump: ASSET_ROOT + "jump/jomana_jump_01.png"
# Land: ASSET_ROOT + "jump/jomana_land_01.png"
# Story: ASSET_ROOT + "story/jomana_smile_wave_01.png"
```

When the run frames are present, the placeholder automatically hides.
No code change needed — just drop the PNGs in the correct folder.

---

## Fallback If Only One Image Is Available

If you only have one reference image of Jomana (e.g., a single standing pose):

1. Use it as `jomana_idle_01.png` (duplicated to 01–04 for a still idle)
2. The placeholder continues for running
3. This gives you Jomana on the story checkpoint screen without placeholder

The pipeline supports partial assets — even one frame is better than none.

---

## Quality Checklist (Before Submitting Frames)

For each PNG frame, verify:

- [ ] Background is **transparent** (not white or colored)
- [ ] Canvas is exactly **256×256 px**
- [ ] Character **faces right** in all frames
- [ ] Feet touch the **same Y pixel** in every frame
- [ ] Character is same **height/scale** in every frame
- [ ] Same **face**, same **dress color**, same **hijab** in every frame
- [ ] No text, no watermarks, no signatures inside image
- [ ] No baked-in hard shadow under character

---

## Recommendation: Start With 8 PNG Frames, Not Skeleton2D

Skeleton2D (bone-based animation with dress/hair physics) is powerful but complex.
For MVP, test the 8-frame PNG approach first.

If the owner approves the look of the 8-frame run animation → ship it.
If the owner wants smoother hair/dress → pursue Skeleton2D R&D separately.

Do NOT spend weeks on Skeleton2D before confirming basic animation is acceptable.

---

## Current Status

| Asset | Status |
|---|---|
| jomana_run_01–08.png | ⬜ NEEDED |
| jomana_idle_01–04.png | ⬜ NEEDED |
| jomana_jump_01.png | ⬜ NEEDED |
| jomana_land_01.png | ⬜ NEEDED |
| jomana_smile_wave_01.png | ⬜ NEEDED |
| Pipeline code | ✅ Ready — auto-detects when files are present |
