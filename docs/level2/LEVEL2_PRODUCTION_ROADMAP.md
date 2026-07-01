# خطوات الخير — Level 2 Production Roadmap
# جمانة وأثر الكلمة — مرسى زليتن

**Version:** 2.0 (canonicalized from owner design document, 2026-07-01)
**Branch:** level2/jomana-marsa-mvp-20260701
**Status:** READY FOR ASSET PRODUCTION — Owner F6 review of camera/feel required first.

---

## 1. Executive Summary

Level 2 moves "جمانة وأثر الكلمة" from playable MVP to a production-ready level
through clean, parallel coder lanes (Modularity). Six coders can work simultaneously
without conflicts. The core runner identity (one-button jump, same physics as Level 1)
is preserved. Jomana runs through Marsa Zliten harbour, collecting "أثر" shards and
meeting her family, guided by the lesson: **الكلمة الطيبة تفتح الطريق المسكّر.**

---

## 2. Design Pillars

| Pillar | Meaning |
|---|---|
| **أجواء عائلية آمنة** | No violence, no enemies, no water death, no scary tone |
| **هوية مرسى زليتن** | Fishing boats, seagulls, stone pier, Mediterranean light |
| **عالم حي ومقروء** | Living sea/wind/birds — but never distracting from obstacles |
| **بساطة التحكم** | One-button jump, same jump feel as Level 1, no Double Jump or Slide |
| **قصة مبنية على القيم** | الكلمة الطيبة → الصبر → الرفق → التوكل — through family encounters |
| **أداء الويب/الهاتف** | CPUParticles only, lightweight shader, Compatibility renderer |
| **مسارات متوازية** | Six isolated coder lanes, stable NodePaths, no cross-lane edits |

---

## 3. Final Scope

### MVP (must ship)
- Jomana playable with full 8-frame run animation
- One-button jump, same physics as Level 1
- 5-layer parallax harbor background (real PNGs)
- 4 readable obstacle types
- One main collectible: pink/gold أثر shard
- Family checkpoints: Ali (15) → Zainab (35) → Fatima (60) → Father (90)
- Living background: water shimmer, seagulls, boat bob, wind sway
- Basic audio: sea ambience + harbour theme + pickup SFX + checkpoint chime

### Nice-to-Have (later polish)
- Rare collectibles: صدفة (shell), نجمة بحر (starfish)
- Footstep sounds on stone
- Jomana dress/hair secondary animation
- More obstacle variety
- Weather transitions (light cloud cover)
- NPC silhouettes reacting subtly

### MUST NOT Build Now
- Enemies or hostile animals
- Hostile seagulls
- Water death gaps / falling in water
- Double jump
- Slide mechanic
- Moving platforms
- Complex particle systems
- Skeleton2D (research-only, not MVP)
- Multiple playable characters

---

## 4. World / Atmosphere

**Time:** Bright, calm morning. Positive energy, not harsh noon.
**Sea:** Calm with gentle surface shimmer (Shimmering). No waves crashing.
**Sky:** Clear Mediterranean blue, soft scattered clouds.
**Colour palette:** Sea blue, pale sky blue, warm gold (sunlight), warm stone grey (pier).
**Emotional tone:** Hope, openness, family warmth, sea breeze (انشراح، أمل، انطلاق).
**vs Level 1:** Level 1 (Al-Mantarah) = narrow street, nostalgia, enclosed. Level 2 (Marsa) = open horizon, sea air, wider freedom.

**First 10 seconds experience:**
Immediately on level start, the player must hear distant gentle waves + a single faint seagull call, see water shimmer moving on screen, and feel the camera settling into the stone pier. Within 2 seconds they should feel: *"مكان جديد، بحري، هادئ، ومبهج."*

---

## 5. Five-Layer Parallax Plan

| # | Node name | Purpose | Asset path | Ratio | Loop | Notes |
|---|---|---|---|---|---|---|
| L1 | `L2_SkyLayer` | Sky, horizon mood | `assets/level2/marsa/backgrounds/bg_sky_marsa.png` | 0.00–0.01 | Static/slow | Full-width, no transparency |
| L2 | `L2_SeaBreakwaterLayer` | Sea depth, breakwater | `assets/level2/marsa/backgrounds/bg_sea_breakwater.png` | 0.05 | Yes | Sea shimmer shader on top |
| L3 | `L2_FarBuildingsLayer` | Zliten identity, minaret | `assets/level2/marsa/backgrounds/bg_harbor_buildings.png` | 0.15 | Yes | Low contrast (faded) |
| L4 | `L2_BoatsMidLayer` | Harbor life, fishermen | `assets/level2/marsa/backgrounds/mg_boats_mid.png` | 0.35 | Yes | Boat bob applied to this layer |
| L5 | `L2_ForegroundPierLayer` | **Gameplay ground** | `assets/level2/marsa/backgrounds/fg_pier_ground.png` | 1.00 | Yes | Must be solid at bottom edge |

**Asset specs:** PNG, preferred 2304×648 for looping (2× viewport width), min 1152×648 for static.
No gameplay obstacles baked into background art. Pier lane (Y 470–520) must be clean.

---

## 6. Living Background Plan

| Effect | Method | Count/Scale | Web-safe | Implemented? |
|---|---|---|---|---|
| Water shimmer | `water_shimmer.gdshader` (2 sine waves, no SCREEN_TEXTURE) | Full sea rect | ✅ | ✅ Done |
| Seagulls | `seagull_loop.gd` (procedural M-shape + tween) | Max 3 | ✅ | ✅ Done |
| Boat bob | `harbor_ambient_bob.gd` (sin, per-boat phase) | Per boat | ✅ | ✅ Done |
| Wind sway | `harbor_ambient_sway.gd` (rotation tween on Polygon2D) | Ropes/flags/palms | ✅ | ✅ Done |
| Distant silhouettes | Tiny Polygon2D in L3 layer | 1–2 figures | ✅ | ✅ Done (fisherman) |
| Foot dust | `CPUParticles2D`, very low count (6–10) | At feet only | ✅ | ⬜ Pending |
| Sea glints | Part of water shader (shimmer_strength uniform) | Shader only | ✅ | ✅ Done |

**SEAGULL_COUNT = 3 max.** **BOAT_BOB_AMPLITUDE = 2.8 px.** **WIND_SWAY_ANGLE = 3.5°.**
All values tunable via constants in `level2_marsa_playable.gd`.

---

## 7. Camera and Game Feel Plan

### Current settings (commit 1218487)

```gdscript
GAMEPLAY_ZOOM           = 1.38
CAMERA_REVEAL_FROM      = 0.95
CAMERA_CHECKPOINT_BOOST = 0.05
CAM_SCREEN_X            = 238.0
CAM_SCREEN_Y            = 498.0
LOOKAHEAD_X             = 120.0
FOLLOW_SPEED            = 5.5
VERTICAL_OFFSET         = -18.0
```

At GAMEPLAY_ZOOM=1.38, visible world width = 835px. Obstacles at X=1292 enter view
~475px ahead of Jomana — comfortable reaction time for a child.

### Owner F6 review required before locking

If Jomana feels too close / claustrophobic, fall back to:
- `GAMEPLAY_ZOOM = 1.28` (safer, more obstacle visibility)
- `LOOKAHEAD_X = 150` (more look-ahead)

If Jomana feels too small, try:
- `GAMEPLAY_ZOOM = 1.45` (maximum safe — test obstacle readability carefully)

**Camera must NEVER hide upcoming obstacles. Obstacle visibility wins over character size.**

---

## 8. Jomana Character Asset Plan

**Pipeline:** `scripts/level2/character/jomana_player_visual.gd`
Auto-detects PNG frames. Falls back to teal polygon placeholder with `push_warning()`.
**No code change needed to activate real art — just drop PNGs in correct folder.**

| Animation | Files | Path |
|---|---|---|
| Run (8 frames) | `jomana_run_01.png` … `jomana_run_08.png` | `assets/level2/marsa/characters/jomana/run/` |
| Idle (4 frames) | `jomana_idle_01.png` … `jomana_idle_04.png` | `assets/level2/marsa/characters/jomana/idle/` |
| Jump | `jomana_jump_01.png` | `assets/level2/marsa/characters/jomana/jump/` |
| Land | `jomana_land_01.png` | `assets/level2/marsa/characters/jomana/jump/` |
| Story / wave | `jomana_smile_wave_01.png` | `assets/level2/marsa/characters/jomana/story/` |
| Dialogue close-up | `jomana_dialogue_closeup_01.png` | `assets/level2/marsa/characters/jomana/story/` |

**Canvas:** 256×256 px, transparent PNG, same foot baseline in every frame, facing right.

---

## 9. Jomana Advanced Animation R&D (Optional, Do NOT Build in MVP)

**Skeleton2D + dress/hair physics** is documented here as research only.

**Why it's appealing:** Animating hair and dress as separate bone-attached layers
gives realistic secondary motion (hair lags behind on jump, swings on land) without
drawing every frame manually. Godot 4 has built-in Skeleton2D + Polygon2D support.

**Why it's NOT MVP:**
- Requires body → mesh → weight painting workflow (~2–4 weeks)
- Requires separated AI-generated assets (body / hair / dress layers separately)
- Risk of overengineering before the owner has confirmed the basic 8-frame animation feels good

**Recommendation:** Test the 8 PNG frames first. If the owner is satisfied with the
animation, ship it. Only pursue Skeleton2D if there is explicit budget and timeline for it.

**If pursued:** Assets needed — Jomana body without hair/dress (base layer), hair as
separate transparent PNG, dress/skirt as separate transparent PNG. All at 256×256.

---

## 10. Obstacle Plan

| # | Obstacle | Silhouette | Collision | Status |
|---|---|---|---|---|
| 1 | Low concrete block | Wide rectangle, low | RectangleShape2D (smaller than art) | ✅ Procedural placeholder |
| 2 | Crate stack | Tall rectangle, wood | RectangleShape2D | ✅ Procedural placeholder |
| 3 | Bollard + rope | Two uprights + horizontal bar | Simple box covering posts | ✅ Procedural placeholder |
| 4 | Broken pier chunk | Low irregular shape | RectangleShape2D (simplified) | ✅ Procedural placeholder |

**Fishing nets and loose ropes:** Background decoration ONLY. Never in the gameplay lane (Y 390–520).
**Obstacle art:** High contrast with pier. Dark top edge. Silhouette readable in 0.2 seconds.
**Reuse:** `ObstacleSpawner` from Level 1 is reused unchanged. Only obstacle art will differ.

---

## 11. Collectible Plan

**Main collectible:** Pink/gold أثر shard (existing `Collectible.tscn` + `light_shard_sheet.png`)
**Internal filename:** unchanged (`light_shard_*`) — only visible UI uses "الأثر" terminology.

**Placement rules:**
- 3–5 shards in an arc above obstacles (jump guide)
- Arc peak = Jomana's mid-jump height (~92px above ground, world space)
- Road-level reward lines (3 shards, 62px apart) after cleared obstacles
- Never cluttered — max 5 shards on screen at once

**Rare collectibles (later):** صدفة (shell) / نجمة بحر (starfish) / هلال (crescent). Not MVP.

---

## 12. Progressive Difficulty Plan

| Score | Speed | Obstacles | Atmosphere |
|---|---|---|---|
| 0–15 | 225 | Wide spacing, very easy | Sea calm, birds occasional |
| 15–35 | 240 | Occasional double obstacles | Water shimmer increases slightly |
| 35–60 | 255 | Tighter spacing, more variety | Light warmer, seagulls more active |
| 60–90 | 270 | Fast, requires focus | Peak atmosphere — bright, breezy |

**Rules:** Never create impossible jumps. Never punish a child unfairly.
Child-friendly always wins over challenge. Fun > difficulty.

---

## 13. Story and Dialogue Roadmap

### Checkpoint order (owner-confirmed 2026-07-01)

| Score | Character | Value | Draft line (Jomana) |
|---|---|---|---|
| 15 | علي | الكلمة الطيبة بين الأخوة | "كلمة طيبة منك تكفي تشجع اللي معاك يا علي." |
| 35 | زينب | الصبر والتفكير الهادئ | "الصبر والتركيز — شجاعتك دايمًا تقوّيني يا زينب." |
| 60 | فاطمة | الرفق والرحمة | "الرفق يخلي الطريق أخف، والكلمة الحلوة تفرّح القلب." |
| 90 | الأب | التوكل والعمل وخير العائلة | "الأثر ما يكون إلا بالمحاولة والصبر يا بابا." |

**Game Over (before any checkpoint):**
"الكلمة الطيبة تحتاج صبر… جربي مرة تانية يا بطلة!"

**Rules:** Short Arabic (max 2 lines per turn). Warm tone. No lectures. No fear. RTL safe.

---

## 14. Audio Roadmap

| Asset | Path | Format | Loop | License | Status |
|---|---|---|---|---|---|
| Sea ambience | `assets/level2/marsa/audio/sea_ambience_loop.ogg` | OGG | Yes | CC0 required | ⬜ Pending |
| Harbour theme | `assets/level2/marsa/audio/marsa_theme_loop.ogg` | OGG | Yes | CC0 required | ⬜ Pending |
| Seagull SFX | `assets/level2/marsa/audio/seagull_distant_01.wav` | WAV | No | CC0 required | ⬜ Pending |
| أثر pickup | `assets/level2/marsa/audio/athar_pickup_01.wav` | WAV | No | CC0 or reuse L1 | ⬜ Pending |
| Checkpoint chime | `assets/level2/marsa/audio/checkpoint_chime_01.wav` | WAV | No | CC0 or reuse L1 | ⬜ Pending |
| Game Over soft | Reuse Level 1 `game_over.wav` | — | — | ✅ | ✅ Reusing |
| Footstep on stone | `assets/level2/marsa/audio/footstep_stone_01.wav` | WAV | No | CC0 required | Later only |

**Public release blocker:** Every audio file needs a `docs/AUDIO_CREDITS.md` entry before public distribution.

---

## 15. Technical Architecture

```
scenes/level2/
  Level2_Marsa_Playable.tscn    ← main playable scene (F6 to test)
  lookdev/Level2_Marsa_LookDev.tscn
  character/
    JomanaPlaceholder.tscn
    JomanaPlayerVisual.tscn      ← animation pipeline entry point
  environment/
  gameplay/
    obstacles/

scripts/level2/
  level2_marsa_playable.gd       ← main controller
  level2_encounter_data.gd       ← family checkpoint data
  character/
    jomana_player_visual.gd      ← auto-detect frames or placeholder
    jomana_placeholder.gd
  ambient/
    harbor_ambient_bob.gd
    harbor_ambient_sway.gd
    seagull_loop.gd
    water_shimmer.gdshader
  camera/
    level2_camera_controller.gd  ← future camera lane handoff
  environment/
    level2_environment_visual.gd ← PNG auto-detect (see Task E)
  gameplay/
  audio/

assets/level2/marsa/
  backgrounds/    ← 5 PNG layers go here
  characters/jomana/run|idle|jump|story|spritesheets/
  obstacles/      ← 4 obstacle PNGs
  collectibles/
  ambient/
  audio/

docs/level2/      ← all Level 2 docs live here
```

**Stable node contracts:**
- `$Player` = Level 1 Player.tscn instance (physics unchanged)
- `$Background/L2_SkyLayer` etc. = stable names for 5 layers
- `$UI` = CanvasLayer (zoom-immune)

---

## 16. Multi-Coder Sprint Roadmap

### Sprint 1 — Game Feel Foundation ✅ DONE (commit 1218487)
**Goal:** Camera, difficulty, animation pipeline, checkpoint order.
**Deliverables:** GAMEPLAY_ZOOM=1.38, look-ahead, auto-detect animation, family checkpoint order fixed.
**Acceptance:** F6 scene loads, feels closer and cinematic.

### Sprint 2 — Character Lane 🎨 NEXT
**Goal:** Drop real Jomana PNG frames, activate animation pipeline.
**Files touched:** `assets/level2/marsa/characters/jomana/run/` + `idle/` + `jump/` + `story/`
**Acceptance:** Real Jomana runs, no teal polygon visible, foot stays on pier.
**Risk:** AI-generated frames inconsistent across poses.
**Mitigation:** Generate all 8 run frames in one composite image, crop to separate files.

### Sprint 3 — Environment Lane 🌊
**Goal:** Replace procedural ColorRect layers with real 5-layer PNG assets.
**Files touched:** `assets/level2/marsa/backgrounds/*.png`, `scripts/level2/environment/level2_environment_visual.gd`
**Acceptance:** 5 PNG layers scroll correctly, no seam, pier is solid.
**Risk:** PNG file size too large for web.
**Mitigation:** Use 2304×648 (2× viewport for seamless loop). Compress with pngquant.

### Sprint 4 — Ambient Life Lane ✅ MOSTLY DONE
**Goal:** Water shimmer, seagulls, boat bob, wind — all working.
**Status:** Already implemented. May need intensity tuning after real art is in.

### Sprint 5 — Gameplay Dressing Lane 🏗️
**Goal:** Harbor obstacle skins, collectible polish, checkpoint NPC positioning.
**Files touched:** `assets/level2/marsa/obstacles/`, `assets/level2/marsa/collectibles/`
**Acceptance:** All 4 obstacles have real PNG art, readable at runner speed.

### Sprint 6 — Audio Lane 🎵
**Goal:** Sea ambience, harbour music, SFX integration.
**Files touched:** `assets/level2/marsa/audio/`, `scripts/level2/audio/`
**Acceptance:** Sea ambience plays on start. Music switches on checkpoint. All CC0 documented.

### Sprint 7 — QA / Integration 🔍
**Goal:** Full playtesting, owner visual/audio review, web performance check.
**Acceptance:** Owner approves F6 playthrough. 60 FPS on mid-range mobile. No Arabic overflow.
**Gate:** No public release until owner signs off on every open gate.

---

## 17. Asset Production List

### Must-Have MVP
```
backgrounds: bg_sky_marsa.png, bg_sea_breakwater.png, bg_harbor_buildings.png,
             mg_boats_mid.png, fg_pier_ground.png
characters:  jomana_run_01–08.png, jomana_idle_01–04.png,
             jomana_jump_01.png, jomana_land_01.png, jomana_smile_wave_01.png
obstacles:   obs_concrete_block_01.png, obs_crate_stack_01.png,
             obs_bollard_rope_01.png, obs_broken_pier_chunk_01.png
audio:       sea_ambience_loop.ogg, marsa_theme_loop.ogg,
             seagull_distant_01.wav, athar_pickup_01.wav
```

### Nice-to-Have Later
```
collectibles: col_shell_01.png, col_starfish_01.png
audio:        footstep_stone_01.wav
characters:   jomana_dialogue_closeup_01.png
```

### Do NOT Build Now
```
enemies, hostile NPC art, water death effects,
Skeleton2D rig, complex particle systems
```

---

## 18. Risk Register

| Risk | Severity | Mitigation |
|---|---|---|
| AI frames inconsistent | High | Generate all 8 run frames in one composite prompt, crop separately |
| Camera too close/far | Medium | Owner F6 review before final lock. Fallback zoom 1.28. |
| Background hides obstacles | High | Faded far layers. High-contrast obstacles. Procedural test first. |
| Arabic text overflow in checkpoints | Medium | Short lines, autowrap enabled, test at zoom 1.38 |
| Web shader compatibility | Low | Shader uses only UV/TIME/sin — no SCREEN_TEXTURE. Compatibility renderer ✅ |
| Audio licensing | High | CC0-only sources. All documented in AUDIO_CREDITS.md before integration. |
| Git conflicts between lanes | Medium | One coder per lane. Stable NodePaths. Feature branches. |
| Mobile performance | Medium | CPUParticles only. Max 3 seagulls. Boat bob is pure sin math. |
| Skeleton2D overengineering | High | **Do not start Skeleton2D in MVP.** Test 8 PNG frames first. |
| level1_exciting_loop.ogg public license | High (L1) | Already documented as blocker for L1 public release. |

---

## 19. Definition of Done

**Playable Foundation Complete ✅ CURRENT STATE**
- Jomana runs and jumps (placeholder visual)
- Family checkpoints work
- Game Over / Retry / Restart work
- Living harbor effects active
- Camera zoom 1.38 + look-ahead

**Art Integration Complete (Target — Sprint 2–5)**
- Real Jomana 8-frame animation
- Real 5-layer PNG backgrounds scrolling
- Real obstacle art
- Sea ambience + harbour theme playing

**Internal RC Complete (Target — Sprint 6–7)**
- Owner F6 visual + audio pass
- All Arabic dialogue approved
- Web performance verified
- Mobile touch test

**Public Release Ready (Future)**
- All audio CC0 documented
- All art licensed
- Web export templates installed
- Owner signs final release approval

---

## 20. Final Recommendation

**Current status:** `READY_FOR_NEXT_OWNER_F6_REVIEW_AND_ASSET_PRODUCTION`

**Immediate next action:**
1. Owner opens `scenes/level2/Level2_Marsa_Playable.tscn`, presses **F6**.
2. Evaluates: camera feel, Jomana size, checkpoint flow, harbor atmosphere.
3. If camera approved → signal Character Lane to produce Jomana PNG frames.
4. If camera needs adjustment → edit `GAMEPLAY_ZOOM` constant in `level2_marsa_playable.gd` and retest.

**Do NOT start Sprint 3 (real backgrounds) before Sprint 2 (Jomana frames) is at least started.**
The background and character must be designed together to match in tone and scale.
