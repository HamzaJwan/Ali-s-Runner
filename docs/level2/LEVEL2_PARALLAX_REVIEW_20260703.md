# Level 2 Parallax Review - 2026-07-03

## Verdict

**PARTIAL: motion feel improved; visual seam cleanup and owner F6 approval remain required.**

Branch: `level2/jomana-marsa-mvp-20260701`

Reviewed sequence:

| Commit | Change | Review |
|---|---|---|
| `318d131` | Level 1 completion UI, direct Level 2 button, boats-mid drift, boat Y correction | Flow exists; background plate introduced a visual regression |
| `abdbf97` | Corrected drift target from `sea_layer` to `boats_layer` | Correct node, but the source plate remained opaque |
| `fe35f4c` | Faster boats/buildings drift and top fade | Top fade softens horizontal edge only; it cannot remove vertical tile joins |
| `101bdfe` | Ground 60%, boats 12%, buildings 4%, gameplay zoom 1.28 | Stronger and more convincing running motion; owner screenshots show repeated vertical joins |

## What Improved

- The implementation uses manual runner parallax rather than Camera2D tracking.
- Pier/ground at 60% of world speed is a strong near-field motion cue.
- Boats at 12% and buildings at 4% create a readable depth hierarchy.
- Gameplay zoom 1.28 makes Jomana and obstacles easier to read.
- Scroll state resets on the start screen.
- Background movement pauses outside active gameplay.
- Level 1 physics constants remain unchanged.

This is the correct architectural direction for a fixed-X endless runner. Jomana stays near
`PLAYER_START_X`; obstacles and scenery move left. A Camera2D following Jomana's X would have a
constant target and would not create travel.

## Remaining Visual Problem

All supplied Level 2 background plates are opaque RGB images, not transparent or guaranteed
seamless textures. Two copies placed edge-to-edge therefore expose their unmatched left/right edges.

At base speed 225 px/s:

| Layer | Scroll speed | Approximate repeat period |
|---|---:|---:|
| Pier/ground | 135 px/s | 8.5 seconds |
| Boats-mid | 27 px/s | 42.7 seconds |
| Buildings | 9 px/s | 128 seconds |

At the editor's 1.5x playback speed, the ground join repeats approximately every 5.7 seconds.
The visible vertical cuts in the owner screenshots are therefore expected from the current assets;
they are not fixed by the per-sprite wrap logic or the top-fade shader.

`mg_boats_mid.png` is also an opaque 1058x233 plate containing its own water/background. It can
visually dominate or duplicate the harbor composition when layered over `bg_harbor_buildings.png`.

## Recommended Next Patch

Keep:

- fixed runner camera
- zoom 1.28 as an owner-review candidate
- ground-dominant motion principle
- transparent ambient boat props and their corrected waterline
- Level 1 -> Level 2 button, pending flow validation

Change:

1. Do not scroll `bg_harbor_buildings.png`; keep it fixed and seam-safe.
2. Disable the full opaque `mg_boats_mid.png` plate in the active composition.
3. Move only transparent ambient boats horizontally at about 10-12% speed and wrap each prop
   independently after it is fully offscreen.
4. Preserve 60% near-field motion, but make the pier source genuinely seamless before tiling, or
   use a narrow seam-safe motion-cue overlay rather than repeating the full photographic plate.
5. If the existing pier must be retained temporarily, use overlap plus edge feathering and require a
   90-second F6 seam review. This is mitigation, not a true seamless fix.
6. Add smoke coverage for Level 1 Father -> completion card -> Chapter 2 scene load.
7. Update debug output so it reports the real mode and factors; the current log still says the harbor
   and pier are fixed.

## Asset Requirements for True Parallax

Best long-term output:

- `bg_sky_marsa.png`: static full-screen sky
- `bg_harbor_buildings.png`: wide or horizontally seamless skyline, preferably RGBA
- `mg_boats_mid.png`: transparent RGBA boats-only cutout, no sky/water rectangle
- `fg_pier_ground.png`: horizontally seamless/tileable foreground

Until those are available, transparent moving props provide safer depth than repeating opaque plates.

## Validation Run

Godot 4.7 validation on commit `101bdfe`:

| Check | Result |
|---|---|
| Headless boot | PASS, exit 0 |
| Level 1 RC smoke | PASS, 20/20 |
| Level 2 scene boot | PASS, exit 0 |
| Level 2 runtime smoke | PASS |
| Input smoke | PASS, mouse 10/10, touch, Space, UI gated |
| Checkpoint resume smoke | PASS, obstacles and collectibles resume |

Known ObjectDB/resource shutdown warnings remain non-blocking. Automated checks do not evaluate
visual tile seams.

## Release Gate

**DO NOT DEPLOY YET.** Owner F6 must approve:

- no visible vertical joins during at least 90 seconds of active running
- start screen composition
- zoom 1.28 readability and reaction time
- all four encounters at the new zoom
- Father completion -> Chapter 2 transition
- retry/restart after both normal death and checkpoint flow

