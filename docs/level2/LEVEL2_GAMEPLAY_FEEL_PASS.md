# Level 2 Gameplay Feel Pass

Status: IMPLEMENTED / OWNER F6 GAMEPLAY-FEEL REVIEW REQUIRED

## Implemented

- Mouse input is handled in the central `_input()` path during active gameplay.
- Touch uses the same gameplay gate; Space remains in `_unhandled_input()`.
- Menu, checkpoint, countdown, Game Over, and ending states reject jump input.
- Runtime smoke covers 10 mouse jumps, touch, Space, and checkpoint click safety.
- The HUD always shows progress and shards: `الأثر: N   ✦ N`.
- Obstacle skins scale by target height and per-type maximum width. Their actual
  scaled height controls bottom alignment; visual height is capped at collision
  height + 20px, while collisions remain unchanged.
- LAND starts from the grounded signal and lasts 0.10s. A quick new jump cannot
  be overwritten with RUN while airborne.
- Existing Player dust emitters are retuned only on the Level 2 instance and
  shifted to Jomana's feet. Shared Level 1 code is unchanged.
- Transparent harbor boats were raised by 34px and keep their gentle bob.
- Placeholder emojis were removed from Level 2 fallback character names.

## Honest Motion Budget

| Layer | Status | Motion |
|---|---|---|
| Sky | ACTIVE | Fixed |
| Harbor buildings | ACTIVE | Fixed; opaque and non-seamless |
| Pier ground | ACTIVE | Fixed gameplay surface |
| Transparent boats | ACTIVE | Gentle bob, corrected waterline |
| Flags | ACTIVE | Gentle sway in anchored composition |
| Seagulls | ACTIVE | Crossing sky motion |
| Jomana dust | ACTIVE | Run trail and contact burst |
| Opaque sea/breakwater plate | DISABLED | Creates strip seams |
| Opaque boats-mid plate | DISABLED | Replaced by transparent boats |
| Hanging rope | DISABLED | No believable anchor in current art |
| Fishing net pile | ACTIVE DECOR | Kept behind gameplay readability |

## Validated Obstacle Skin Sizes

| Type | Rendered size |
|---|---|
| block | 76×48px |
| barrier | 90×49px |
| cone / pier chunk | 66×34px |
| crate | 64×72px |
| sign / pier chunk | 70×36px |

Runtime smoke verifies width limits, the height-to-collision fairness cap, and
bottom alignment for all five definitions.

## True Parallax Limitation

The current large background plates contain opaque sky/water pixels and are not
seamless. Horizontal drift would reveal a join, so harbor buildings remain fixed.
True multi-layer parallax requires transparent RGBA cutouts or genuinely seamless
wide plates for sea, buildings, and boats.

## Owner F6 Review

1. Repeat mouse jump ten times and test touch/Space.
2. Confirm every obstacle looks compact and fair without changed collision feel.
3. Confirm LAND appears only at contact and does not linger on obstacle tops.
4. Confirm `الأثر` and `✦` counters both update and survive checkpoints.
5. Confirm dust sits under Jomana's feet and boats remain above the curb.
6. Complete a checkpoint and confirm collectibles/obstacles resume normally.

Do not deploy until the owner approves this visual/gameplay-feel review.
