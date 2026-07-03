# Level 2 Gap Audit — Production Roadmap vs Implementation
# Audited against commit 1218487 (level2/jomana-marsa-mvp-20260701)
# Date: 2026-07-01

This table compares the Production Roadmap target with the current implementation.

| Area | Roadmap Target | Current Status | Gap | Next Action |
|---|---|---|---|---|
| **Camera zoom** | 1.38 gameplay, look-ahead 120px | ✅ Implemented (1218487) | None | Owner F6 review |
| **Camera reveal** | 0.95 → 1.38, 1.4s | ✅ Implemented | None | Owner F6 review |
| **Checkpoint zoom** | +5% boost | ✅ Implemented | None | — |
| **Vertical framing** | -18px offset for jump arc | ✅ Implemented | None | — |
| **Jomana animation pipeline** | Auto-detect 8 PNGs, fallback polygon | ✅ Implemented (`jomana_player_visual.gd`) | Real PNG frames missing | Owner generates/sources frames → drop in folder |
| **Jomana idle** | 4 frames | ⬜ Pending (pipeline exists) | 4 PNG files needed | Character Lane Sprint 2 |
| **Jomana jump/land** | 2 frames | ⬜ Pending (pipeline exists) | 2 PNG files needed | Character Lane Sprint 2 |
| **Jomana story pose** | smile_wave + dialogue | ⬜ Pending | 2 PNG files needed | Character Lane Sprint 2 |
| **Jomana Skeleton2D** | Research only (NOT MVP) | Not started | None (intentionally deferred) | R&D after 8-frame test |
| **5-layer backgrounds** | Real PNG files, parallax | ⬜ Procedural placeholder only | 5 PNG background files needed | Environment Lane Sprint 3 |
| **Parallax scrolling** | 5 layers at 0.01/0.05/0.15/0.35/1.0 | ⬜ Static procedural (BackgroundMotion pending) | Real Sprite2D layers needed | Environment Lane Sprint 3 |
| **Water shimmer** | Shader (sin waves, no SCREEN_TEXTURE) | ✅ `water_shimmer.gdshader` active | None | — |
| **Seagulls** | 2–4 birds, looping, no collision | ✅ `seagull_loop.gd`, 3 birds | None | May tune count/speed |
| **Boat bob** | Sin motion, per-boat phase | ✅ `harbor_ambient_bob.gd` | None | — |
| **Wind sway** | Rope/flag/palm rotation | ✅ `harbor_ambient_sway.gd` | None | — |
| **Distant silhouettes** | 1–2 fisherman/passerby | ✅ One fisherman polygon in lookdev | Playable scene could add more | Low priority |
| **Foot dust** | CPUParticles2D, low count | ⬜ Not implemented | Script + node needed | Sprint 4 task |
| **Obstacles** | 4 harbor obstacle types | ✅ Procedural placeholder (concrete, crates, bollard, stone) | Real PNG art missing | Gameplay Dressing Sprint 5 |
| **Obstacle collision** | RectangleShape2D, reuse Level 1 spawner | ✅ Level 1 ObstacleSpawner unchanged | None | — |
| **Fishing nets as decoration** | Background only, not collision | ✅ Documented, not in lane | None | Maintain as policy |
| **Collectibles (أثر shard)** | Pink/gold shard, arc placement | ✅ Level 1 CollectibleSpawner reused | — | — |
| **Collectible patterns** | 3–5 arc above obstacle, 3 road-level reward | ✅ Existing patterns from Level 1 | — | — |
| **Rare collectibles** | Shell, starfish (later only) | Not started | None (correctly deferred) | Future sprint |
| **Checkpoint order** | Ali(15)→Zainab(35)→Fatima(60)→Father(90) | ✅ Fixed in commit 1218487 | None | — |
| **Checkpoint dialogue** | Short Arabic, warm, child-friendly | ✅ Draft text in `level2_encounter_data.gd` | Owner approval pending | Owner must approve wording |
| **Checkpoint NPC art** | Ali/Zainab/Fatima/Father sprites | ⬜ Placeholder emoji/text only | NPC art files needed | Gameplay Dressing Sprint 5 |
| **Progressive difficulty** | 225→240→255→270 | ✅ Implemented via post_speed in encounter data | None | — |
| **Sea ambience audio** | `sea_ambience_loop.ogg` (CC0) | ⬜ Not integrated | File + license needed | Audio Lane Sprint 6 |
| **Harbour music** | `marsa_theme_loop.ogg` (CC0) | ⬜ Not integrated | File + license needed | Audio Lane Sprint 6 |
| **Seagull SFX** | `seagull_distant_01.wav` (CC0) | ⬜ Not integrated | File + license needed | Audio Lane Sprint 6 |
| **أثر pickup SFX** | New or reuse Level 1 shard_pickup | ⬜ Currently reusing Level 1 | — | Audio Lane Sprint 6 |
| **Checkpoint chime** | `checkpoint_chime_01.wav` | ⬜ Currently reusing Level 1 | — | Audio Lane Sprint 6 |
| **Web export** | Compatibility renderer, single-threaded | ⬜ Web build exists (Level 1 only); Level 2 not wired into build yet | Level 2 must be integrated into main menu first | After Sprint 7 |
| **Mobile touch test** | Tap to jump works | ✅ InputEventScreenTouch handled | Owner test needed on real device | Sprint 7 |
| **QA / owner F6** | Full playthrough approval | ⬜ Pending | Owner must play F6 | NOW — first action |
| **Arabic RTL text** | All labels RTL-correct, no overflow | ✅ RTL enforced | May need viewport test | Sprint 7 check |
| **Skeleton2D R&D** | Optional research, NOT MVP | Not started | None (intentionally deferred) | Only after 8-frame test |
| **Level 1 untouched** | No Level 1 file edits | ✅ Confirmed | None | Maintain |
| **Docker/deploy untouched** | No deploy files edited | ✅ Confirmed | None | Maintain |

---

## Summary

| Category | Count Done | Count Pending | Blocked by |
|---|---|---|---|
| Camera/Feel | 5/5 | 0 | Owner F6 review |
| Character animation | 1/7 (pipeline) | 6 (frames) | Art assets |
| Environment layers | 0/5 (art) | 5 | Art assets |
| Ambient life | 5/6 | 1 (foot dust) | Implementation |
| Obstacles | 4/4 (logic) | 4 (art) | Art assets |
| Collectibles | MVP done | Rare types | Intentionally deferred |
| Checkpoints | 4/4 | NPC art, dialogue approval | Art + Owner |
| Audio | 0/6 | 6 | CC0 sources + integration |
| QA/Web | 0/3 | 3 | Owner review + Level 2 web integration (separate from Level 1 web build) |

**Overall:** Gameplay foundation is complete. The project is blocked on art assets and the owner's F6 review, not on code.
