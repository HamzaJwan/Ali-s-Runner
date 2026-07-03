# Level 2 Visual + Story QA — Owner F6 Review Analysis
# Reviewer: Sonnet | Date: 2026-07-02 | Based on owner F6 screenshots and code review

---

## 1. Start Screen Composition

**Status: PASS (with minor issues)**

| Item | Assessment |
|---|---|
| Harbor background photograph | ✅ Beautiful — mosque, buildings, sea, boats visible |
| Sky layer | ✅ Clean Mediterranean blue |
| Boats visible behind pier wall | ⚠️ Partially sunk — Y position too low (fix in Codex P4 pass) |
| Flags without poles | ⚠️ Acceptable artistic choice — harbor bunting between boats |
| Jomana idle on pier | ✅ Correct position and pose |
| Title text readable | ✅ "جمانة وأثر الكلمة" clear |
| Seagulls | ✅ Visible in sky |
| No rope prop floating | ✅ Fixed |
| No background seam | ✅ Fixed (HARBOR_DRIFT_SPEED=0) |

**Recommended Codex action:** Move boat props from Y=452/458 → Y=420/426 (more hull visible above pier).

---

## 2. Jomana Animation States

**Status: PARTIAL — transition issue remains**

| State | When | Status |
|---|---|---|
| IDLE | Menu / start screen | ✅ Working |
| RUN | During gameplay | ✅ Working |
| JUMP | During jump | ✅ Working |
| LAND | On landing | ✅ Working (returns to RUN after 0.2s) |
| STORY | During checkpoints | ✅ Jomana waves |

**Issue:** IDLE → RUN transition snaps on play press.
Jomana is set to RUN immediately when play is pressed, BEFORE the 1.4s camera tween.
The camera tween visually distracts from the character but doesn't fully hide the snap.

**Recommended Codex action:** Keep Jomana in IDLE during the harbor reveal. Switch to RUN only when `_cam_tween.finished` fires. (See `docs/level2/LEVEL2_CODEX_GAMEPLAY_FEEL_PASS.md` — P2.)

---

## 3. Obstacle Fairness

**Status: PARTIAL — visually improved but width needs tuning**

| Item | Assessment |
|---|---|
| Harbor PNG textures loading | ✅ No more Level 1 red barrier |
| obs_concrete_block_01 visible | ✅ Gray concrete block |
| obs_bollard_rope_01 visible | ✅ Black bollards with rope |
| obs_crate_stack_01 visible | ✅ Stacked crates |
| obs_broken_pier_chunk_01 visible | ✅ Stone pier chunk |
| Obstacle sitting on pier ground | ✅ Bottom-aligned correctly |
| Obstacle visual width | ⚠️ Landscape PNG images scale too wide (bollard 402×218 → 147px wide vs 68px collision) |
| Jump arc clears obstacle | ✅ Physics unchanged — should clear |

**Recommended Codex action:** Add `MAX_VISUAL_WIDTHS` constraint to `apply_skin()` so landscape images
don't extend more than 2× collision width. (See `docs/level2/LEVEL2_CODEX_GAMEPLAY_FEEL_PASS.md` — P3.)

---

## 4. Checkpoint Encounter Composition

**Status: BROKEN — panels cover characters**

### What owner sees
The `CheckpointPanel/Card` is positioned at screen Y=382-602 on a 644px viewport.
The `DimBG` is a full-screen dark overlay at 72% opacity.
Both Jomana and the NPC character are at screen Y≈370-640 (pier level).
Result: characters are completely obscured by the dimmed overlay and/or the card.

### What is working (confirmed by screenshots)
The second owner screenshot shows both Jomana (waving pose) and Ali (standing with flag)
visible SIDE BY SIDE on the pier BEFORE the checkpoint_panel becomes fully visible.
This is the cinematic moment we want. The composition is correct — the panel is the problem.

### What needs fixing

| Issue | Current value | Recommended fix |
|---|---|---|
| Card Y position | offset_top=382 (bottom of screen) | Move to offset_top=12 (top of screen) |
| Card height | 220px | Reduce to ~148px (1 line of text + button) |
| Card width | 540px | Increase to 730px (subtitle style) |
| DimBG opacity | 0.72 (very dark) | Reduce to 0.30 (characters visible through dim) |

### Acceptance criteria
After fix: characters (Jomana + NPC portrait) fill the bottom 60% of screen.
Dialogue text appears as a subtitle strip at the top. DimBG creates gentle atmosphere,
not a full blackout. The encounter feels like a living harbor scene, not a text screen.

**Codex action:** Edit `scenes/level2/Level2_Marsa_Playable.tscn` — move Card offsets, reduce DimBG color alpha.

---

## 5. Character Portraits at Checkpoints

**Status: READY TO COMMIT — code working, assets untracked**

| Asset | Exists on disk | Committed to git | Code ready |
|---|---|---|---|
| ali_checkpoint_01.png (642×1254 RGBA) | ✅ | ❌ | ✅ |
| zainab_checkpoint_01.png (639×1254 RGBA) | ✅ | ❌ | ✅ |
| fatima_checkpoint_01.png (738×1254 RGBA) | ✅ | ❌ | ✅ |
| father_checkpoint_01.png (660×1254 RGBA) | ✅ | ❌ | ✅ |
| family_ending_01.png (1008×1003 RGBA) | ✅ | ❌ | ✅ |

`level2_family_checkpoint_visuals.gd::apply_npc_art()` already handles RGBA PNGs.
It finds non-transparent bounds, scales to `NPC_VISUAL_HEIGHTS`, bottom-aligns feet.
Once Codex runs `git add assets/level2/marsa/characters/family/`, portraits will load.

**Scale check:** NPC_VISUAL_HEIGHTS (150 / 140 / 105 / 190 world units) produce natural proportions:
- Ali: slightly shorter than adult, consistent with Level 1 game art
- Fatima: 105 units = ~55% of Father height = baby proportion ✅
- Father: tallest at 190 units = ~224px screen ✅

---

## 6. NPC Persist After Checkpoint

**Status: BROKEN — NPC stays on pier after "تابع"**

In `_on_continue_pressed()`, there is no code to move `encounter_npc` off screen.
The NPC portrait (and its colored panel card) remains visible during countdown and next gameplay.

**Impact:** During resume gameplay, Ali (or Zainab/Fatima/Father) is still standing on the pier,
overlapping with obstacles and collectibles. Score label shows 20 (or 36/61/91) and gameplay
resumes, but a large NPC portrait is still visible in the right half of the screen.

**Fix:** In `_on_continue_pressed()`, after `checkpoint_active = false`, slide NPC off right:
```gdscript
var npc_tween := create_tween()
npc_tween.tween_property(encounter_npc, "position:x", 1350.0, 0.35).set_trans(Tween.TRANS_SINE)
npc_tween.finished.connect(func() -> void:
    for child in encounter_npc.get_children():
        if child.name != "NPCLabel":
            child.queue_free()
    npc_label.visible = false
, CONNECT_ONE_SHOT)
```

**Acceptance criteria:** After pressing "تابع", the NPC slides off to the right within 0.35s.
Countdown starts. No NPC visible during countdown or next gameplay segment.

---

## 7. Speaker Name Per Dialogue Step

**Status: BROKEN — speaker always shows character name, even for ROLE_JOMANA**

`cp_speaker.text = enc.get("speaker_name", "")` is called once per `_show_enc_step()`.
It uses the encounter's `speaker_name` (e.g., "علي") regardless of whether the current step
is ROLE_HELPER (character speaking) or ROLE_JOMANA (Jomana speaking).

**Impact:** During Ali checkpoint:
- Step 1 (Ali speaks): speaker = "علي" ✅
- Step 2 (Jomana speaks): speaker = "علي" ❌ (should be "جمانة")

**Fix in `_show_enc_step()`:**
```gdscript
match role:
    Level2EncounterData.ROLE_HELPER:
        cp_speaker.text = enc.get("speaker_name", "")
    Level2EncounterData.ROLE_JOMANA:
        cp_speaker.text = "جمانة"
    Level2EncounterData.ROLE_REWARD:
        cp_speaker.text = ""
```

---

## 8. Family Ending Screen

**Status: CODE READY — not yet integrated**

`level2_family_checkpoint_visuals.gd::apply_ending_art(ending_node)` exists.
It loads `family_ending_01.png` and scales to half viewport width (576px).

**Integration check needed:**
`_show_level2_ending()` currently reuses `$UI/GameOverPanel` with modified text.
Codex must confirm `apply_ending_art()` is called with a correct `ending_node` reference
that can display the family portrait inside or adjacent to the panel.

`family_ending_01.png` is 1008×1003 RGBA. At 576px wide: ~575px tall on screen.
If the panel is only 220px tall, the image won't fit. Codex must either:
- Resize the ending panel to ~600px tall (only for the ending state), or
- Add the portrait as a CanvasLayer sprite above the panel UI

**Acceptance criteria:** After Father checkpoint, family ending shows:
"أحسنتِ يا جمانة!" + "كل كلمة طيبة تترك أثرًا" + family group portrait visible.

---

## 9. Ambient Props Readability

| Prop | Status | Assessment |
|---|---|---|
| Seagulls | ✅ Correct | 3 birds, cross-screen flight, right direction |
| Boat blue | ⚠️ Partially sunk | Move Y 452→420 |
| Boat small | ⚠️ Partially sunk | Move Y 458→426 |
| Flags | ✅ Acceptable | Harbor bunting without posts — artistically valid |
| Net pile | ✅ Correct | Ground level, non-intrusive |
| Rope | ✅ Disabled | Correct — no anchor context |

---

## 10. Collectible Lane Readability

**Status: PASS (with minor spacing note)**

| Item | Assessment |
|---|---|
| Shard visual at 48px | ✅ Clearly visible |
| LOW_LINE pattern (run height) | ✅ Collectible without jumping |
| SMALL_ARC pattern (light jump) | ✅ Low arc |
| FULL_ARC pattern (full jump) | ✅ High arc |
| Clearance from obstacles (420px zone) | ✅ Improved in c8ce6e9 |
| No Level 1 visual (star/heart) | ✅ Correctly hidden |

**Note:** First shard appears a few seconds after checkpoint resume (expected timer behavior).
Not a bug — this is a natural breathing moment after the emotional checkpoint. No fix needed.

---

## 11. Camera Behavior

| State | Camera | Assessment |
|---|---|---|
| Menu | Default zoom (1.0) | ✅ |
| Harbor reveal | 0.88 → 1.18 over 1.4s | ✅ Cinematic |
| Gameplay | Fixed at 1.18 | ✅ No drift |
| Checkpoint | +5% boost → gameplay pos | ✅ |
| Game Over | Default zoom | ✅ |

**Note:** Checkpoint camera boost (+5%) is very subtle at 1.235 vs 1.18.
A more pronounced zoom (1.35 centered between Jomana and NPC) would feel more cinematic,
but this is a nice-to-have, not a blocker.

---

## Summary — Owner F6 Gate Status

| Category | Status | Blocker? |
|---|---|---|
| Start screen composition | ✅ PASS | No |
| Jomana animation | ⚠️ PARTIAL — snap on start | No (minor) |
| Obstacles (harbor PNGs) | ✅ PASS | No |
| Obstacle width | ⚠️ Too wide | No (minor) |
| Mouse click jump | ❌ BROKEN | YES |
| Checkpoint panel position | ❌ BROKEN (covers characters) | YES |
| DimBG opacity | ❌ Too dark | YES |
| Speaker name per step | ❌ BROKEN | YES |
| NPC persist after checkpoint | ❌ BROKEN | YES |
| Family portraits on screen | ⚠️ Assets not committed | YES (commit needed) |
| Family ending image | ⚠️ Not integrated | MEDIUM |
| Collectibles | ✅ PASS | No |
| Background composition | ✅ PASS | No |

**DO NOT DEPLOY until all YES blockers are resolved and owner F6 confirms.**
