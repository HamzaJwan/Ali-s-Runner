# Level 2 Environment Asset Requirements
# الطبقات الخمس — مرسى زليتن

Drop final PNG files into `assets/level2/marsa/backgrounds/`.
The environment loader (`scripts/level2/environment/level2_environment_visual.gd`)
detects them automatically and replaces procedural shapes. No code change needed.

---

## Required Files

### Layer 1 — Sky
**File:** `assets/level2/marsa/backgrounds/bg_sky_marsa.png`
**Content:** Mediterranean morning sky — clear blue, soft scattered clouds near horizon.
**Canvas:** 1152×648 minimum. 2304×648 preferred (2× for scroll loop).
**Transparency:** No (full opaque background).
**Parallax ratio:** 0.00–0.01 (nearly static).
**Loop:** Not needed (or very slow).
**Notes:** Horizon should fade from blue to soft hazy white/gold.

### Layer 2 — Sea + Breakwater
**File:** `assets/level2/marsa/backgrounds/bg_sea_breakwater.png`
**Content:** Calm deep blue sea, stone breakwater silhouette across horizon, optional lighthouse.
**Canvas:** 2304×648 (must loop seamlessly).
**Transparency:** Sky area at top should be transparent (let L1 sky show through).
**Parallax ratio:** 0.05 (slow drift).
**Loop:** Yes — left edge must match right edge exactly.
**Notes:** Water shimmer shader is applied ON TOP in code. Do not bake animated shimmer into art.

### Layer 3 — Far Harbor Buildings
**File:** `assets/level2/marsa/backgrounds/bg_harbor_buildings.png`
**Content:** Distant Zliten harbor — whitewashed buildings, minaret, palm silhouettes, soft detail.
**Canvas:** 2304×648 (loop).
**Transparency:** Upper area transparent (sky shows through).
**Parallax ratio:** 0.15.
**Loop:** Yes.
**Contrast:** Low — slightly faded/hazy. Buildings must NOT compete visually with obstacles.

### Layer 4 — Boats / Mid Harbor
**File:** `assets/level2/marsa/backgrounds/mg_boats_mid.png`
**Content:** Fishing boats (blue hulls, white cabins, masts), dock details, ropes in water.
**Canvas:** 2304×648 (loop).
**Transparency:** Below boats should be transparent (sea shows through).
**Parallax ratio:** 0.35.
**Loop:** Yes.
**Notes:** Boat bob is applied in code. Art should show boats as static sprites.
Boat colors: blue hull (#2A4E8E), cream cabin (#D4C4A0), dark mast.

### Layer 5 — Foreground Pier / Gameplay Lane
**File:** `assets/level2/marsa/backgrounds/fg_pier_ground.png`
**Content:** Stone pier surface (limestone, warm grey). Must be solid at bottom edge.
**Canvas:** 2304×520 approx (taller strip, Y 390 to bottom of screen).
**Transparency:** No transparency at bottom — must completely cover anything below.
**Parallax ratio:** 1.00 (moves with game speed).
**Loop:** Yes — critical that left/right edges match perfectly.
**Critical rule:** The top edge of the pier at Y≈470 (curb line) must be clearly defined.
No gameplay obstacles baked into this image.

---

## General Art Specs (All 5 Layers)

| Property | Value |
|---|---|
| Format | PNG |
| Color mode | RGBA 32-bit |
| Preferred width | 2304 px (2× viewport for seamless loop) |
| Height | 648 px (or cropped to needed area) |
| Viewport | 1152×648 |
| Style | Stylized 2D illustration (not photorealistic, not cartoon) |
| Palette | Mediterranean warm: blues, sandy golds, warm greys |
| Obstacles | NEVER baked into background |
| Text | NEVER |

---

## Looping Requirement

For any layer with `loop = yes`, the LEFT edge and RIGHT edge of the image must
match pixel-perfectly. Test by placing two copies side by side.

---

## Environment Loader

When PNG files are present, `scripts/level2/environment/level2_environment_visual.gd`
loads them into Sprite2D nodes and attaches them to the 5 layer nodes. If any file
is missing, it logs a warning and keeps the procedural placeholder active.

This means:
- You can drop one layer at a time to test
- Missing layers do not crash the scene
- No code change needed to activate real art
