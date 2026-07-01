# Level 2 Visual Direction — مرسى زليتن
# جمانة وأثر الكلمة

## Atmosphere Summary

Warm, sunlit Libyan harbour on a calm morning.
The sea is gentle, the sky is clear Mediterranean blue with soft clouds.
Stone pier, colourful fishing boats, distant whitewashed buildings.
A lighthouse or minaret visible on the horizon gives authentic local identity.
Seagulls fly lazily in the background.
The mood is: safe, familiar, family, warm — not dramatic or suspenseful.

**Colour palette reference (from concept art, 2026-07-01):**
- Sky: bright blue (#66AEEA) fading to hazy pale blue at horizon
- Sea: deep turquoise-blue (#2B7AB8) with lighter shallow band near pier
- Stone pier: warm sandy limestone (#B09870)
- Boats: blue hulls (#2A4E8E) with cream/white cabins
- Buildings: whitewashed sandstone (#D4C4A0)
- Collectibles: pink/rose crystal with gold glow

---

## 5-Layer Parallax Plan

| # | Layer node name | Content | Scroll factor | Notes |
|---|---|---|---|---|
| L1 | `L2_SkyLayer` | Sky gradient, clouds | 0.00 | Fixed — never scrolls |
| L2 | `L2_SeaBreakwaterLayer` | Sea body, breakwater, lighthouse | 0.02 | Very slow drift |
| L3 | `L2_FarBuildingsLayer` | Harbour buildings, minaret silhouette | 0.05 | Low contrast |
| L4 | `L2_BoatsMidLayer` | Fishing boats, dock details | 0.12 | Boats also bob |
| L5 | `L2_ForegroundPierLayer` | Stone pier, gameplay lane | 0.18–0.65 | Clear runner path |

**Do not exceed 5 main scroll layers** in the MVP.
Decorative elements (palm, flags, ropes) attach to their closest layer.

---

## Water Animation Plan

**Technique:** `ShaderMaterial` on a `ColorRect` spanning the sea area.
**Shader file:** `scripts/level2/ambient/water_shimmer.gdshader`
**Renderer compatibility:** Godot Compatibility (WebGL 2.0 / OpenGL ES 3.0) ✅
**Performance:** Very low — two `sin()` calls in the fragment shader only.

**Key shader parameters:**
- `wave1_speed = 0.9` — large slow swell
- `wave1_freq = 6.0` — swell frequency
- `wave2_speed = 2.1` — small ripple
- `wave2_freq = 18.0` — ripple frequency
- `shimmer_strength = 0.35` — sunlight glint intensity

**DO NOT use:** `SCREEN_TEXTURE` — not reliably available on mobile/web.

---

## Seagull Plan

**Count:** 2–4 seagulls maximum in LookDev. 3–5 in production (owner decides).
**Script:** `scripts/level2/ambient/seagull_loop.gd`
**Visual:** Procedural M-shaped polygon (no sprite asset required in LookDev).
**Production:** `AnimatedSprite2D` with a 4–6 frame wing-flap spritesheet.
**Flight Y range:** 80 – 260 (well above the gameplay lane at Y 390+).
**No collision.** No attack. No AI path-finding. Just a looping tween across the sky.

---

## Boat Bob Plan

**Script:** `scripts/level2/ambient/harbor_ambient_bob.gd`
**Amplitude:** 2.5–3.5 pixels (very subtle)
**Period:** 2.4–3.0 seconds
**Stagger:** Each boat gets a different `phase_offset` so they don't all peak together.
**Mast sway:** Mast polygon inside each boat gets `harbor_ambient_sway.gd`.

---

## Wind Sway Plan

**Script:** `scripts/level2/ambient/harbor_ambient_sway.gd`
**Applies to:** rope polygons, flag polygons, palm leaf polygons attached to Layer 4/5 nodes.
**Max angle:** 3–6 degrees (subtle, not exaggerated).
**Period:** 1.8–2.2 seconds.

---

## Obstacle Readability Rules

| Obstacle | Y position | Width | Height | Readable? |
|---|---|---|---|---|
| Low concrete block | ROAD_Y | 46px | 28px | ✅ Clear at speed |
| Crate stack | ROAD_Y | 40px | 44px | ✅ Tall, distinct |
| Bollard + rope | ROAD_Y | 50px | 36px | ✅ Upright silhouette |
| Stone chunk | ROAD_Y | 54px | 22px | ⚠️ Low — needs contrast |

**General rules:**
- Obstacle colour must contrast with the pier stone (avoid same sandy beige).
- Add a top highlight to every obstacle to separate it from the ground.
- Minimum obstacle width: 36px for readability at runner speed.
- Obstacle tops should be at least 20px above the ground colour.

---

## What Goes in Background vs Gameplay Lane

| Element | Location | Why |
|---|---|---|
| Fishing nets hanging on walls | L3 / L4 background | Decorative — cannot look like jump target |
| Rope coils on pier edge | L5 far edge (x > 900) or decoration | Must not overlap gameplay X range when spawner is active |
| Bollards with rope between them | Gameplay lane (as obstacle) | Only if clearly styled as obstacle — high contrast |
| Fisherman silhouette | L3 / L4 far background | Tiny, no collision, not a story character |
| Seagulls | L2 / L3 sky zone (Y < 260) | Above gameplay — never in lane |
| Palm tree | L5 right decorative edge | Outside active spawn zone |

**Key rule:** If an element is in Y range 390–520 and X range 200–1292 (spawn zone),
it must look like an obstacle OR be clearly non-interactive background.
Never put decorative ropes where they look like a collision boundary.

---

## What NOT to Build Yet

| Feature | Why deferred |
|---|---|
| Sea foam particle system | CPUParticles risk for MVP — use shader instead |
| Dynamic cloud movement | Not visible in runner gameplay — low ROI |
| Lighthouse rotating beacon | Fun but low priority |
| Fish jumping from water | Complex — needs careful Y placement |
| Detailed fisherman animation | Not a story character — keep as tiny silhouette |
| Advanced boat physics (rocking side to side) | Simple sin bob is sufficient |
| Crowd of distant people | Performance risk; 1–2 silhouettes are enough |
| Real water reflection | Requires SCREEN_TEXTURE — not mobile/web safe |

---

## Concept Art Reference

File: `docs/level2/concept_art_harbor_01.png` (owner-provided, 2026-07-01)

Key composition notes from concept art:
- Jomana is on the LEFT side of the screen, matching Level 1's runner position (X≈220)
- Pink crystal collectibles form a readable arc in mid-screen
- Crate stacks and rope piles are in the FOREGROUND pier layer, well-separated from boats
- 3 boats visible: one large (left), two medium (mid/right) — good depth composition
- The breakwater runs horizontally at a low Y, separating sea from harbour interior
- Seagulls appear at Y 80–180, well above gameplay
- Palm tree is decorative RIGHT edge, not blocking gameplay lane
