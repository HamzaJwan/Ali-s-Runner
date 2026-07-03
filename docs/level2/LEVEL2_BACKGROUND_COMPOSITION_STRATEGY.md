# Level 2 Background Composition Strategy
# جمانة وأثر الكلمة — مرسى زليتن
# Last updated: 2026-07-02

---

## The Core Constraint

The Level 2 gameplay camera is **fixed** — it does not move horizontally during play.
The camera has ONE world position baked at scene start (`_gameplay_cam_pos`) and stays there.

This means:
- Godot's `Parallax2D` / `ParallaxBackground` driven by camera viewport offset will show **zero movement**
- Horizontal drift of opaque background plates creates seams at the image copy-join
- True parallax depth requires either (A) a moving camera, or (B) manually driven scroll layers

---

## Asset Inventory and Composition Role

### All 5 Background PNGs — Raw Properties

| File | Size | Format | Notes |
|---|---|---|---|
| bg_sky_marsa.png | 1058×371 | RGB (opaque) | Mediterranean sky with soft horizon glow |
| bg_harbor_buildings.png | 1058×253 | RGB (opaque) | Rich harbor photograph — city + boats + sea + mosque |
| bg_sea_breakwater.png | 1058×341 | RGB (opaque) | Sea band with stone breakwater |
| mg_boats_mid.png | 1058×233 | RGB (opaque) | Boats at mid-ground water level |
| fg_pier_ground.png | 1058×282 | RGB (opaque) | Stone pier / playable floor |

**Critical fact:** All 5 PNGs are 24-bit RGB (no alpha channel). They cannot be composited with
true transparency. Stacking them creates solid horizontal bands — any gap or overlap shows a seam.

---

## Why bg_harbor_buildings.png Does Most of the Work

The harbor buildings photograph is a rich, detailed composition that ALREADY contains:
- Sky and horizon (in its upper portion, faded by the top-fade shader)
- Sea and water visible behind the breakwater
- Multiple boats moored in the harbor
- Mosque minaret and city architecture
- Palm trees and Mediterranean vegetation

This single photograph delivers what the 5-plate stack was trying to achieve individually.
The `bg_top_fade.gdshader` (55px fade at top) blends it into the sky plate seamlessly.

**Conclusion: bg_sea_breakwater.png and mg_boats_mid.png add no visual value when the harbor
photograph is present.** They would only create seams. They remain disabled.

---

## Active Layer Stack (Current)

```
Z = -99  SkyFill ColorRect (solid sky blue)        ← eliminates any transparency gap
Z = -30  L2_SkyLayer: bg_sky_marsa.png             ← CAMERA-FIXED, no drift
Z = -18  L2_FarBuildingsLayer: bg_harbor_buildings ← FIXED X, no drift, top-fade shader
Z = -12  AmbientLife: boats, flags, net            ← transparent PNGs, animated
Z = -8   AmbientLife: seagulls                     ← transparent, cross-screen flight
Z = -5   L2_ForegroundPierLayer: fg_pier_ground    ← CAMERA-FIXED, 72% screen height
Z =  0   Player + Obstacles + Collectibles
Z = 10   UI
```

---

## Disabled Plates (and Why)

### bg_sea_breakwater.png — DISABLED
- Opaque RGB, 341px tall
- Positioned between buildings and pier, it would create a hard horizontal edge at its top and bottom
- The harbor photograph already shows sea and breakwater at the correct depth
- **Re-enable only if:** re-authored as RGBA with alpha at top and bottom to blend naturally

### mg_boats_mid.png — DISABLED
- Opaque RGB, 233px tall
- The harbor photograph already shows these boats at correct proportions
- As a separate layer it would double-draw boats at a fixed world depth with no parallax benefit
- **Re-enable only if:** re-authored as RGBA cutout (boats with transparent water/sky)

---

## Ambient Motion Strategy (Camera-Fixed Runner)

Since the camera is fixed, all "running feel" comes from:

### 1. Obstacle Approach
Obstacles spawn at world X=1292 and scroll left at gameplay speed. This is the primary motion cue
that communicates "Jomana is running through space."

### 2. Seagull Flight
3 seagulls cross screen in either direction. Each has a random speed (55–83 px/s).
This creates the strongest sense of environmental life in the sky area.

### 3. Boat Bob
2 transparent boat props bob vertically (amplitude 3.5px, period 2.6s each).
This animates the water area behind the pier wall.

### 4. Flag Sway
1 transparent flag bunting sways horizontally (small amplitude, ~2px).
This adds wind-like ambient motion at the pier level.

### 5. DO NOT add time-based horizontal drift to opaque plates
The buildings plate drift bug (B2) was fixed exactly because this creates a visible seam.
The harbor photograph is NOT seamlessly tileable and will show a hard vertical cut at the copy join.

---

## What Would Improve Running Feel (Safe Options)

These enhancements can be added WITHOUT creating seams:

### Option A: Foreground Stone Parallax Tile (requires seamless art)
If a separate seamless stone-tile strip (~60-80px tall) is created for the pier foreground edge,
it could scroll left at full gameplay speed. This would strongly enhance the running sensation.
**Requires:** A seamless tileable stone strip PNG (authoring task for owner or Gemini).

### Option B: Water Shimmer at Pier Base
A narrow ColorRect (15-20px tall) with a GLSL wave shader placed at the water line between the
pier wall and the harbor photograph. This animates without any tiling/seam issue.
`water_shimmer.gdshader` already exists in the project.
**Position:** World Y ≈ 465-470 (just above pier top), behind pier (z=-6).

### Option C: Subtle Building Haze (Shader on buildings layer)
A very gentle UV offset animation in the buildings plate shader — slow UV wobble of 0.2-0.5px
creates a heat-haze shimmer on the city architecture.
**Risk:** May cause subtle strobe on repeated play. Test carefully.

### Option D: More / Faster Seagulls
Add a 4th or 5th seagull at a slightly lower Y (closer to the buildings roofline). At higher
speed (100-120 px/s) it sweeps across quickly. This is the lowest-risk enhancement.

---

## Deployment Decision Grid

| Asset | Use in production? | Condition |
|---|---|---|
| bg_sky_marsa.png | YES | No change needed |
| bg_harbor_buildings.png | YES | Fixed X, no drift, top-fade shader retained |
| fg_pier_ground.png | YES | No change needed |
| bg_sea_breakwater.png | NO | Would need RGBA re-authoring first |
| mg_boats_mid.png | NO | Would need RGBA re-authoring first |
| boat_blue_01.png | YES | Move Y 452→425 for better visibility |
| boat_small_02.png | YES | Move Y 458→430 |
| small_flags_line_01.png | YES | Keep at Y=435 |
| rope_hanging_01.png | NO | No anchor context |
| deco_fishing_net_pile_01.png | YES | Ground level, fine |
| seagull_fly_sheet_4f.png | YES | No change needed |

---

## For Future Transparent Assets

If the owner or Gemini generates transparent versions of:
- Sea layer (RGBA, water only, buildings cut out)
- Boats layer (RGBA, boat hulls only, water/sky cut out)

These CAN be added back with a horizontal scroll at slow speed (5-10% of gameplay speed)
without seams, because transparent edges hide the copy join. Until then, the harbor photograph
handles all of this compositing within its single frame.
