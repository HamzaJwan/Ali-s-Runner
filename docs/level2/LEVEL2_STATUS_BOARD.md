# Level 2 Status Board — جمانة وأثر الكلمة
# Last updated: 2026-07-01 | Commit: 1218487

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
| Family checkpoint order | Ali(15)→Zainab(35)→Fatima(60)→Father(90) |
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
| Multi-coder workflow | `MULTI_CODER_WORKFLOW.md` |
| Level 1 untouched | Confirmed |
| Docker/deploy untouched | Confirmed |

---

## 🔄 IN PROGRESS

| Item | Owner/Coder | Notes |
|---|---|---|
| Owner F6 camera review | **OWNER** | Open scene → F6 → evaluate camera feel |
| Level 1 Web export | **Codex** (separate worktree) | Templates required |

---

## ⛔ BLOCKED (needs assets or owner action)

| Item | Blocked by | What's needed |
|---|---|---|
| Jomana real run animation | Character art | 8 PNG frames (see `JOMANA_IMAGE_REQUESTS.md`) |
| Jomana idle animation | Character art | 4 PNG frames |
| Jomana jump/land | Character art | 2 PNG frames |
| Jomana story pose | Character art | 1–2 PNG frames |
| 5 real background PNG layers | Environment art | See `LEVEL2_ENVIRONMENT_ASSET_REQUIREMENTS.md` |
| 4 obstacle PNG skins | Obstacle art | See `LEVEL2_OBSTACLE_ASSET_REQUIREMENTS.md` |
| Sea ambience audio | CC0 source | See `LEVEL2_AUDIO_ASSET_REQUIREMENTS.md` |
| Harbour music | CC0 source | Same |
| Seagull SFX | CC0 source | Same |
| NPC sprites at checkpoints | Character art | Ali/Zainab/Fatima/Father harbour poses |

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
