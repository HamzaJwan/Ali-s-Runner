# Level 2 Obstacle Asset Requirements
# العقبات — مرسى زليتن

Drop final PNG files into `assets/level2/marsa/obstacles/`.
Collision logic reuses Level 1's ObstacleSpawner unchanged.
Only the visual (Sprite2D texture) changes per obstacle.

---

## Required Obstacle Files

### 1. Low Concrete Block
**File:** `assets/level2/marsa/obstacles/obs_concrete_block_01.png`
**Description:** Simple low concrete/cement block. Very readable silhouette.
**Recommended visual size:** ~80×40 px on screen at gameplay zoom 1.38
**Canvas:** 128×96 transparent PNG
**Top highlight:** Lighter grey top face for 3D depth reading
**Bottom:** Should appear "sitting" on pier, not floating
**Collision:** RectangleShape2D smaller than art (forgive collision, good UX)

### 2. Crate Stack
**File:** `assets/level2/marsa/obstacles/obs_crate_stack_01.png`
**Description:** 2–3 wooden fishing crates stacked. Tall, clear silhouette.
**Recommended visual size:** ~70×90 px on screen
**Canvas:** 128×160 transparent PNG
**Color:** Brown wooden planks (#8B5E3C), dark wood grain lines
**Notes:** Should be clearly taller than the concrete block for variety.

### 3. Bollard + Rope Barrier
**File:** `assets/level2/marsa/obstacles/obs_bollard_rope_01.png`
**Description:** Two short stone/iron bollards connected by a thick rope or chain.
**Recommended visual size:** ~110×60 px on screen
**Canvas:** 160×96 transparent PNG
**Color:** Dark stone/iron bollards, thick natural-fiber rope
**Notes:** The rope connecting them must be clearly visible and readable.

### 4. Broken Pier Chunk
**File:** `assets/level2/marsa/obstacles/obs_broken_pier_chunk_01.png`
**Description:** A raised/broken stone chunk sticking up from the pier surface.
**Recommended visual size:** ~90×38 px on screen
**Canvas:** 128×80 transparent PNG
**Notes:** Lowest obstacle. Must be clearly visible — darker than pier, with visible cracks.

---

## Obstacle Art Rules

1. **High contrast with pier background.** The pier is warm sandy stone — obstacles must be darker or distinctly different.
2. **Dark top edge.** Every obstacle needs a clearly visible top face/edge so the player knows where the jump-clear point is.
3. **Transparent background.** PNG with alpha — never white or colored backgrounds.
4. **No embedded shadows.** Collision silhouette should be clean. Optional: very subtle soft shadow below the obstacle only (not inside it).
5. **Simple silhouettes.** At runner speed (game is moving), players have 0.3–0.5 seconds to react. Silhouette must be readable instantly.
6. **Collision shape smaller than art.** This is deliberate — slightly forgiving collision feels better than pixel-perfect (which feels unfair to children).

## Background-Only Elements (NOT Obstacles)

The following must NEVER be placed in the gameplay lane (Y 390–520 world space):
- Fishing nets hanging/spread
- Loose rope coils
- Anchor
- Fishing rods/equipment

These are background decoration in Layer 3 or 4 art only.

## Collision Reference

All 4 obstacles reuse `RectangleShape2D` from Level 1 obstacle system.
Approximate collision boxes (world space, narrower/shorter than visual):

| Obstacle | Collision W | Collision H |
|---|---|---|
| Concrete block | 44px | 26px |
| Crate stack | 38px | 42px |
| Bollard + rope | 46px | 30px |
| Broken pier chunk | 48px | 18px |
