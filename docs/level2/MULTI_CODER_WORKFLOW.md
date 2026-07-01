# Level 2 Multi-Coder Workflow — خطوات الخير
# مرسى زليتن — Parallel Development Lanes

## Core Rules (All Coders)

1. **Never edit Level 1 files** (`scenes/Main.tscn`, `scripts/main.gd`,
   `scripts/player.gd`, etc.) without explicit owner approval and a task assignment.
2. **One coder per lane.** Do not work in another coder's lane without agreement.
3. **Feature branches per lane.** Branch from `autopilot/v1-level1-20260628-1842`
   (or the designated Level 2 base branch once it exists).
   Name pattern: `level2/<lane>/<feature>`.
4. **Do not change physics constants.** Gravity, jump velocity, road surface Y, etc.
   are immutable and documented in `docs/STORY_PLAN.md`.
5. **Placeholders before finals.** Commit working placeholder code/art first.
   Replace with final assets in a follow-up commit after owner approval.
6. **Run validation before commit.** At minimum: headless boot (`--quit`) must exit 0.
7. **Stable NodePaths.** Agree on node names before wiring. Renaming a node breaks
   all scripts that reference it by path.
8. **No direct `main.gd` edits.** The Level 2 controller is `scripts/level2/level2_marsa.gd`
   (separate script, separate scene). Anything shared must be discussed first.

---

## Lane Definitions

### 🎨 Lane 1 — Character
**One coder only.**

**Responsible for:**
- Jomana sprite sheets (idle, run 1–8, jump, land, hurt, victory, dialogue)
- Story NPC appearances (Ali, Fatima, Zainab, Father at harbor — may reuse Level 1 assets)
- Foot alignment calibration
- Character scene: `scenes/level2/character/`

**Allowed paths:**
```
assets/level2/marsa/characters/
scenes/level2/character/
scripts/level2/character/
```

**DO NOT touch:**
- `assets/characters/ali/` (Level 1 assets)
- `scripts/player.gd`, `scripts/player_visual.gd`
- Any Level 1 scene

---

### 🌊 Lane 2 — Environment
**One coder only.**

**Responsible for:**
- 5 parallax background layers (sky, sea/breakwater, far buildings, boats/mid, foreground pier)
- Pier ground texture and stone details
- Horizon composition and lighting feel
- Parallax scroll factors

**Allowed paths:**
```
assets/level2/marsa/backgrounds/
scenes/level2/environment/
scripts/level2/environment/
```

**DO NOT touch:**
- `assets/backgrounds/mantarha/` (Level 1 backgrounds)
- Level 1 `BG` node in `scenes/Main.tscn`

---

### 🐦 Lane 3 — Ambient Life
**One coder only.**

**Responsible for:**
- Seagulls (AnimatedSprite2D or procedural, no collision, no attack)
- Boat bob (sin motion, small amplitude)
- Wind sway (ropes, flags, palms)
- Water shimmer shader (`water_shimmer.gdshader`)
- Distant decorative silhouettes (fisherman/passerby far in background)

**Allowed paths:**
```
assets/level2/marsa/ambient/
scenes/level2/ambient/
scripts/level2/ambient/
```

**RULES for this lane:**
- Zero collision on ambient actors.
- Nothing covers the gameplay lane (Y > 390).
- No hostile seagulls. No attack behavior. No enemy AI.
- All ambient must be easily disabled without breaking the scene.
- Use `CPUParticles2D`, not `GPUParticles2D` (mobile/web compatibility).

---

### 🎵 Lane 4 — Audio
**One coder only.**

**Responsible for:**
- Sea ambience loop (`sea_ambience_soft_loop.ogg` — source CC0)
- Gentle harbor music track (source/license required before integration)
- Seagull sound effects
- Checkpoint encounter SFX (can reuse Level 1 checkpoint.wav)
- أثر pickup sound (can reuse Level 1 shard_pickup.wav or source new)

**Allowed paths:**
```
assets/level2/marsa/audio/
docs/level2/audio/
```

**RULES for this lane:**
- Every audio file needs a credits entry before integration.
- Do not integrate owner-authorized-only files for public release.
- Do not edit `scripts/audio/audio_manager.gd` (Level 1 shared) —
  create `scripts/level2/audio/level2_audio_manager.gd` instead.

---

### 📷 Lane 5 — Camera
**One coder only.**

**Responsible for:**
- Level 2 cinematic camera controller (`scripts/level2/camera/`)
- Establishing harbor reveal (zoom-out → settle into gameplay frame)
- Look-ahead during gameplay (camera leads slightly forward)
- Checkpoint micro-focus (gentle zoom-in on encounter)
- Ending pier reveal

**Allowed paths:**
```
scenes/level2/camera/
scripts/level2/camera/
```

**RULES for this lane:**
- No aggressive zoom — keep obstacles readable at all times.
- Camera framing must not cause motion sickness (gentle easing only).
- Do not modify `level_camera.gd` (LookDev preview) during production — create new.
- Final zoom factor must be agreed with the Gameplay Dressing lane.

---

### 🏗️ Lane 6 — Gameplay Dressing
**One coder only.**

**Responsible for:**
- Harbor obstacle visuals (concrete block, crate stack, bollard/rope, stone chunk)
- أثر collectible visuals and arc placement
- Checkpoint encounter dressing (NPC position, dialogue bubble placement)
- Obstacle collision silhouette testing (must match Level 1 obstacle collision sizes)

**Allowed paths:**
```
assets/level2/marsa/obstacles/
assets/level2/marsa/collectibles/
scenes/level2/gameplay/
scripts/level2/gameplay/
```

**RULES for this lane:**
- Do NOT change `scripts/gameplay/obstacle_spawner.gd` (Level 1 shared).
- Obstacle visual sizes must remain readable at runner speed.
- Fishing nets/ropes go in background decoration, NOT the gameplay lane.
- Collectible arcs must be spaced so they're readable (not cluttered).

---

## Communication Contract

Before wiring any two lanes together:

1. **Agree on node name.** Example: Jomana's sprite node must be called `JomanaSprite`
   in both the Character lane scene and the Level 2 controller script.
2. **Agree on signal names.** If the obstacle spawner emits a new signal for Level 2,
   document it in a shared contract comment before both lanes use it.
3. **Agree on Z-index.** Environment uses z-index < 0; gameplay lane = 0;
   UI uses CanvasLayer.
4. **Post a note** in the Discord/chat/PR before merging any cross-lane dependency.

---

## Validation Checklist (Before Any Commit)

```bash
# Must exit 0 — Level 1 still boots
Godot_v4.7-stable_win64_console.exe --headless --path . --quit

# Must pass — all Level 1 constants / UI / checkpoints unchanged
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/rc_smoke_check.gd

# Level 2 LookDev should also load cleanly
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/lookdev/Level2_Marsa_LookDev.tscn --quit
```

No commit goes in if Level 1 is broken.
