# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-01 | Commit: (see git log)

Quick reference for owner and coders. Open this file to know exactly where things stand.

---

## ✅ COMPLETED

| Item | Notes |
|---|---|
| Level 2 playable scene (`Level2_Marsa_Playable.tscn`) | F6 to test in Godot |
| Camera zoom 1.38 + smooth look-ahead | LOOKAHEAD_X=120, FOLLOW_SPEED=5.5 |
| Harbor cinematic reveal | 0.95 → 1.38 over 1.4s |
| Checkpoint zoom micro-focus | +5% on dialogue |
| Jomana placeholder (teal polygon) | Foot-aligned to pier |
| Jomana animation pipeline | `jomana_player_visual.gd` — auto-detects PNG frames |
| Family checkpoint order | ✅ Ali(15)→Zainab(35)→Fatima(60)→Father(90) — canonical, confirmed |
| Checkpoint dialogue (draft) | In `level2_encounter_data.gd` |
| Game Over card with Arabic | Animated entrance, warm style |
| Retry / Restart flow | Working correctly |
| Progressive difficulty 225→270 | Matches Level 1 speed progression |
| Water shimmer shader | `water_shimmer.gdshader` (WebGL-safe) |
| Seagulls (3, procedural) | Looping flight, no collision |
| Boat bob (3 boats, phase offset) | `harbor_ambient_bob.gd` |
| Wind sway on ropes | `harbor_ambient_sway.gd` |
| Distant fisherman silhouette | Tiny polygon in LookDev |
| 5-layer background (procedural) | ColorRect placeholder, readable |
| Production Roadmap doc | `LEVEL2_PRODUCTION_ROADMAP.md` |
| Gap Audit doc | `LEVEL2_GAP_AUDIT.md` |
| Asset pipeline docs | Environment, Obstacle, Audio requirements |
| Asset manifest system | `level2_asset_manifest.gd` — single source of truth for all paths |
| Jomana auto-pipeline | `jomana_player_visual.gd` — 8-frame PNG auto-loads, polygon fallback |
| Background auto-pipeline | `level2_environment_visual.gd` — each of 5 layers auto-loads independently |
| Obstacle skin adapter | `level2_obstacle_visuals.gd` — adds Sprite2D skin without touching Level 1 |
| Family checkpoint sprites | `level2_family_checkpoint_visuals.gd` — auto-loads PNG per character |
| Audio wrapper | `level2_audio_manager.gd` — plays L2 audio if present, CC0 gate documented |
| Foot dust | `jomana_foot_dust.gd` — CPUParticles2D, web-safe, easy to disable |
| Asset check tool | `scripts/tools/level2_asset_check.gd` — headless report, exit 0 always |
| Asset drop guide | `docs/level2/LEVEL2_ASSET_DROP_GUIDE.md` — owner guide, no code changes needed |
| Multi-coder workflow | `MULTI_CODER_WORKFLOW.md` |
| Level 1 untouched | Confirmed |
| Docker/deploy untouched | Confirmed |
| Jomana real art integrated | All 16 frames (run/idle/jump/land/story) normalized 384×512, auto-loaded |
| Real backgrounds integrated | All 5 PNG layers loading, parallax positioning fixed |
| Background viewport coverage | `_update_background_parallax()` runs every frame — no gray borders |
| Obstacle visual skins | `level2_obstacle_visuals.gd` wired to `obstacle_spawned` signal |
| Collectible manifest path | `col_light_shard_pink_01.png` correctly mapped |
| Audio 8/8 files integrated | sea/theme/seagull/pickup/checkpoint/retry/jump/footstep |
| Audio manager | `level2_audio_manager.gd` — all events wired, WAV loop support |
| Game chapter flow doc | `docs/GAME_CHAPTER_FLOW.md` — one game, two chapters, future transition plan |

---

## 🔄 IN PROGRESS

| Item | Owner/Coder | Notes |
|---|---|---|
| Owner F6 real-art + audio review | **OWNER** | Open Level2_Marsa_Playable.tscn → F6 → confirm Jomana, backgrounds, audio |
| Chapter transition integration | **After F6 approval** | See docs/GAME_CHAPTER_FLOW.md — safe to implement after owner approves |
| Level 1 Web deployed | **Codex** (separate worktree) | game.juanspace.org live — Level 2 NOT included until approved |

---

## ⛔ BLOCKED (needs assets or owner action)

| Item | Blocked by | What's needed |
|---|---|---|
| NPC sprites at checkpoints | Character art | ali_checkpoint_01.png, zainab_checkpoint_01.png, fatima_checkpoint_01.png, father_checkpoint_01.png |
| Family ending image | Character art | family_marsa_ending_01.png |
| Audio OGG conversion (optional) | Owner decision | WAV works; OGG smaller for web |
| Level 1 → Level 2 transition | Owner F6 approval needed first | See docs/GAME_CHAPTER_FLOW.md |

---

## 👁️ NEEDS OWNER F6 REVIEW

| Item | When ready |
|---|---|
| Camera zoom 1.38 — is Jomana big enough? | NOW — open F6 |
| Camera look-ahead — can you see obstacles early? | NOW |
| Harbor reveal animation — smooth/cinematic? | NOW |
| Checkpoint dialogue Arabic text — approved? | After F6 pass |
| Teal placeholder — is it readable as a character? | NOW |
| Progressive difficulty — feels fair? | NOW |

---

## ⬜ NEEDS AUDIO

| Item | Priority |
|---|---|
| Sea ambience loop | High |
| Harbour music loop | High |
| Seagull distant SFX | Medium |
| أثر pickup SFX (or reuse L1) | Medium |
| Footstep on stone | Low (later) |

---

## 🔮 FUTURE / NOT NOW

| Item | Reason deferred |
|---|---|
| Skeleton2D hair/dress animation | Overengineering risk before 8-frame test |
| Rare collectibles (shell, starfish) | Scope creep for MVP |
| Weather transitions | Not core gameplay |
| Web public release | Export templates + license docs + owner approval |
| Android release | JDK + SDK + templates + Play Store setup |
| Level 2 in main menu | Level 2 not production-ready yet |
| Level 3 (Zainab) | Level 2 must reach production first |
| Full game title change | Owner decision only |

---

## 2026-07-01 Parser Hotfix

- Fixed the Level 2 audio manager preload parse error caused by invalid named-argument syntax.
- Confirmed `Level2_Marsa_Playable.tscn` loads and detects all eight Level 2 audio files.
- Level 2 audio remains local to Level 2; Level 1 audio and gameplay were not changed.
- Escaped the mobile rotate overlay's RTL marks so the project autoload parses in Godot 4.7.
