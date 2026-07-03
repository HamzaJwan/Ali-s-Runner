# Level 2 Obstacle Readability Rules

## Active Obstacles (in gameplay lane — must be jumped over)

| Visual | Color contrast | Silhouette | Status |
|---|---|---|---|
| Low concrete block | ✅ Dark grey against warm pier | Rectangle, low, wide | ✅ Placeholder |
| Crate stack | ✅ Brown, wood texture | Tall rectangle | ✅ Placeholder |
| Short bollard + rope barrier | ✅ Dark post against stone | Upright post + horizontal rope | ✅ Placeholder |
| Broken pier stone chunk | ⚠️ Similar to pier — needs contrast | Low, jagged | Needs dark top highlight |

## Background Decoration (never collision — must NOT look like obstacles)

| Element | Rule |
|---|---|
| Fishing nets | Far background only, transparent/faded — never in the gameplay lane |
| Ropes on walls | Side decoration, hanging — never crossing the horizontal run path |
| Coiled rope piles | Must be clearly off to the side or behind the gameplay lane |
| Anchor / buoy | Background element only |

## Gameplay Lane Definition

The active collision zone is Y range 390–520 (world space).
NOTHING should be placed decoratively in this Y range that looks like it requires a jump.

## Readability Rules

1. Every active obstacle must have a **dark top edge** so it reads against the pale pier.
2. Minimum obstacle visual width: 36px (unreadable below this at runner speed).
3. Minimum obstacle visual height: 20px.
4. Obstacle colour must contrast with `C_PIER = Color(0.68, 0.60, 0.48)`.
5. Use a lighter top face + darker front face — simple 2-tone box reads well at speed.
6. Do NOT use colours that blend with the sea (blue/teal = confusing).

## What NOT to do

- ❌ Fishing net as an active obstacle (too visually complex, player can't read jump timing)
- ❌ Rope pile in the center of the lane (looks like background, not a hazard)
- ❌ Same colour as the pier stone (invisible until too late)
- ❌ Very thin obstacles (< 30px wide) — player can't judge
- ❌ Very short obstacles (< 18px tall) — easy to miss visually
