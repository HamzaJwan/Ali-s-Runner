# Level 2 Camera Tuning Guide

**Scene:** `scenes/level2/Level2_Marsa_Playable.tscn`
**Script:** `scripts/level2/level2_marsa_playable.gd`

---

## Current Camera Settings (v2 — after game feel sprint)

| Constant | Value | Notes |
|---|---|---|
| `GAMEPLAY_ZOOM` | **1.38** | was 1.18 — significantly closer to Jomana |
| `CAMERA_REVEAL_FROM` | 0.95 | cinematic opening zoom start |
| `CAMERA_CHECKPOINT_BOOST` | 0.05 | +5% zoom during checkpoint dialogue |
| `CAM_SCREEN_X` | 238.0 | Jomana's X position on screen (left-third) |
| `CAM_SCREEN_Y` | 498.0 | road surface Y on screen |
| `VERTICAL_OFFSET` | -18.0 | shifts camera up to show jump arc |
| `LOOKAHEAD_X` | 120.0 | px of look-ahead (world space) |
| `FOLLOW_SPEED` | 5.5 | lerp speed for look-ahead |
| `CAM_TRANSITION_TIME` | 0.38 | seconds for camera move transitions |

---

## What Changed from v1

- **Zoom 1.18 → 1.38:** Jomana appears ~17% larger on screen. At 1.38 zoom,
  visible world width = 1152/1.38 ≈ 835px. Obstacles spawn at X=1292 and
  enter the visible zone ~475px ahead of Jomana — plenty of reaction time.
- **Look-ahead:** Camera position.x slides left each frame so the player
  sees more of the track ahead (obstacles, collectibles). Uses lerp to avoid jitter.
- **Vertical offset (-18px):** Camera raised slightly so Jomana's jump apex
  (~92px above ground) stays inside the visible frame.
- **Smoother reveal:** 0.95 → 1.38 over 1.4s (was 0.84 → 1.18 over 1.8s).

---

## Safe Tuning Ranges

| Constant | Safe Min | Sweet Spot | Safe Max | Risk if exceeded |
|---|---|---|---|---|
| `GAMEPLAY_ZOOM` | 1.20 | **1.38** | 1.50 | Obstacles appear too late to react |
| `LOOKAHEAD_X` | 60 | **120** | 200 | Too much lookahead makes Jomana near the left edge |
| `FOLLOW_SPEED` | 3.0 | **5.5** | 12.0 | Too high → jitter; too low → laggy |
| `VERTICAL_OFFSET` | -40 | **-18** | 10 | Negative too large → pier disappears at bottom |

---

## How to Test in F6

1. Open `scenes/level2/Level2_Marsa_Playable.tscn`
2. Press **F6** (not F5)
3. Press **ابدئي الرحلة** to start
4. Check the visual checklist below

---

## Visual Checklist

✅ **Jomana large enough?** — She should take up roughly 18–22% of screen height.
✅ **Obstacles visible early?** — You should see obstacles at least 300px before they reach Jomana.
✅ **Jump arc visible?** — At max jump height, Jomana's head should NOT be cropped.
✅ **Pier always visible?** — Stone pier surface must always be in frame.
✅ **Collectible arcs readable?** — Arcs of gems should be visible 200–400px ahead.
✅ **No jitter?** — Camera should glide smoothly, no sudden jumps.
✅ **Opening reveal smooth?** — Harbor establish shot should feel cinematic, not jarring.
✅ **Checkpoint focus comfortable?** — Slight zoom-in on dialogue should not cause discomfort.

---

## Warning Signs

| Symptom | Likely cause | Fix |
|---|---|---|
| Jomana very small | GAMEPLAY_ZOOM too low | Increase toward 1.45 |
| Obstacles appear too suddenly | GAMEPLAY_ZOOM too high or LOOKAHEAD_X too low | Lower zoom or raise lookahead |
| Camera jitters | FOLLOW_SPEED too high | Lower to 4.0–5.0 |
| Camera too sluggish | FOLLOW_SPEED too low | Raise to 6.0–8.0 |
| Jump cropped at top | VERTICAL_OFFSET not negative enough | Lower by 10px |
| Pier disappears | VERTICAL_OFFSET too negative | Raise by 10px |
| UI labels too large | GAMEPLAY_ZOOM too high (affects CanvasLayer? no) | CanvasLayer is zoom-immune — investigate separately |
