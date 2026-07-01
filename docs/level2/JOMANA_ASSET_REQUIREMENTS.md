# Jomana Asset Requirements — جمانة — Level 2 Character

**Character:** جمانة — Ali's older, wisest sister
**Level:** 2 — مرسى زليتن
**Role:** Playable runner hero (replaces Ali in Level 2)
**Value she embodies:** الكلمة الطيبة، الحكمة، الصبر

---

## Canvas and Scale Rules

Copy Ali's exact conventions (see `assets/characters/ali/`) so the same spawn system works:

| Parameter | Value |
|---|---|
| Canvas size | Same as Ali (transparent PNG, any square ≥ 256×256) |
| Visible height target | ~190px at menu, ~160px during gameplay (same scale pipeline) |
| Foot alignment | Visible bottom of sprite = ROAD_SURFACE_Y − PLAYER_COLLISION_HALF_HEIGHT |
| Orientation | Facing right (runner direction) |
| Style | Warm, realistic illustration, child-friendly, family-friendly |

---

## Required Poses (MVP)

All poses go in `assets/level2/marsa/characters/jomana/`

| Filename | Description | Priority |
|---|---|---|
| `jomana_idle.png` | Standing calm, slight smile | **MUST HAVE** |
| `jomana_run_1.png` — `jomana_run_8.png` | 8-frame run cycle (right-facing) | **MUST HAVE** |
| `jomana_jump.png` | Airborne pose | **MUST HAVE** |
| `jomana_fall.png` | Falling/descending (optional, can reuse jump) | NICE-TO-HAVE |
| `jomana_land.png` | Just-landed crouch | NICE-TO-HAVE |
| `jomana_hurt.png` | Hit/stumble (child-safe, no blood, no pain) | MUST HAVE |
| `jomana_victory.png` | Hands up, big smile, end-of-run celebration | NICE-TO-HAVE |
| `jomana_dialogue.png` | Thoughtful/speaking pose for checkpoint panels | NICE-TO-HAVE |
| `jomana_companion.png` | Small portrait for companion ribbon (Level 1 ribbon) | FUTURE |

---

## Story NPC Poses (for Level 2 checkpoints)

These NPCs appear at score 15, 35, 60 checkpoints. Each needs one calm, warm pose.

| Filename | Character | Priority |
|---|---|---|
| `fisherman_helper.png` | Elderly fisherman — صياد — patience | MUST HAVE |
| `child_helper.png` | Young child — طفل — kind words | MUST HAVE |
| `elder_helper.png` | Village elder — شيخ — wisdom | MUST HAVE |

Same canvas rules as Level 1 helper assets.

---

## Style Guide

- **Color palette:** Warm sandy, teal/blue sea tones, coral accents — see `docs/level2/LEVEL2_MOCKUP_PROMPT.md`
- **Hijab:** Jomana wears a hijab (light teal/green, casual style — not formal)
- **Dress:** Long, comfortable, practical — colors from the harbor palette
- **Expression:** Calm, confident, wise, kind — never aggressive, never scared
- **Age:** Older than Zainab, younger than the fisherman
- **Silhouette:** Slightly taller than Zainab, shorter than Ali's story sprite

---

## DO NOT

- Do not draw Jomana without a hijab
- Do not draw her in aggressive or combat poses
- Do not use very bright neon colors (keep warm, realistic Mediterranean feel)
- Do not add HP bars, weapons, or attack animations
- Do not draw blood or injury

---

## Integration Path

1. Drop assets into `assets/level2/marsa/characters/jomana/`
2. Add credits entry to `docs/level2/audio/` (or create `docs/level2/ASSET_CREDITS_L2.md`)
3. Wire into `scripts/level2/character/jomana_visual.gd` (to be created by Character Lane coder)
4. Test with headless boot — no parse errors
5. Owner F6 visual review before any commit to main
