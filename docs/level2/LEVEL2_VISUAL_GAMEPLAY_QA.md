# Level 2 Visual + Gameplay QA Report
# Reviewer: Sonnet | Date: 2026-07-02 | Commit reviewed: c8ce6e9

---

## 1. Start Screen Composition

**Observation:** The harbor scene is genuinely beautiful. The mosque silhouette, harbor buildings,
seagulls, and Jomana idle create a strong visual identity. The boats (transparent props) are visible
but appear partially submerged beneath the pier edge. Flags are visible but hang without visible poles.

**Root cause — boats:**
Transparent boat props are at world Y=452-458. Pier foreground (z=-5) draws over them (boat z=-8).
The pier layer starts at CURB_TOP_Y=470, which means boats at Y=452-458 are 12-18 world units above
the pier top. At zoom 1.18, that's ~14-21 screen pixels above the pier top edge. The top portion of
the boat PNG renders above the pier, bottom is occluded. If the boat art has most of its body in the
lower half of the PNG canvas, it will appear to "sink."

**Root cause — flags:**
Flags at world Y=435 (above pier). No visible pole/post anchor. The flag art shows a horizontal
bunting line with colorful triangles — the rope endpoints are at the PNG edges, but there are no posts
in the scene that could anchor them.

**Recommended fix:**
- Boats: move world Y from 452 → 425-435 so more of the boat hull is visible above the pier.
  The pier will occlude the very bottom — which looks correct (boat floating, pier in foreground).
- Flags: move X from 935 → position behind pier wall edge where an ambient post/bollard would logically
  exist, OR accept the visual as "ropes tied between boats" which is believable harbor decor.
  Lower confidence anchor is better than no anchor.

**File:** `scripts/level2/level2_marsa_playable.gd` → `_build_ambient_props()`

**Risk:** LOW — visual-only, no gameplay impact.

**Acceptance:** Boats visible from body upward. Pier occludes only the bottom 10-20%.

---

## 2. Jomana IDLE → RUN Transition

**Observation:** When the owner presses "ابدئي الرحلة," Jomana snaps directly from IDLE pose to RUN
frame 0. The abruptness is noticeable because:
- Idle frames show Jomana in a relaxed weight-shift stance
- Run frame 0 shows full forward lean
- AnimatedSprite2D switches instantly with no cross-fade

**Root cause:** GDScript's AnimatedSprite2D has no built-in blend/interpolation between animations.
`_play_anim(RUN)` calls `_anim.play("run")` which hard-cuts. The `set_pose(RUN)` in `_on_play_pressed`
is called before the 1.4s camera tween, so Jomana starts running while the camera is still transitioning.

**Recommended fix:** Do NOT attempt cross-fade (requires Skeleton2D or shader). Instead:
1. Ensure `set_pose(RUN)` is called at the exact moment gameplay speed > 0, not before the camera tween.
2. Let `_play_harbor_reveal()` finish (1.4s) before setting RUN — Jomana stays IDLE during the reveal.
3. Set RUN only when camera tween completes.

Change in `_on_play_pressed()`:
```gdscript
# Instead of setting RUN immediately:
_jomana_vis.set_pose(_jomana_vis.Pose.IDLE)  # stay idle during reveal
_play_harbor_reveal()
# In _play_harbor_reveal, on tween.finished:
#   _jomana_vis.set_pose(_jomana_vis.Pose.RUN)
```

This means Jomana waits idly while the harbor reveals, then starts running — which is more cinematic
and eliminates the snap (the camera movement distracts from the animation cut).

**File:** `scripts/level2/level2_marsa_playable.gd` → `_on_play_pressed()`, `_play_harbor_reveal()`

**Risk:** LOW — animation-only, does not affect physics or score.

**Acceptance:** Owner sees Jomana idle → harbor pans → Jomana begins running. No jarring snap visible.

---

## 3. Obstacle Fairness and Visual Width

**Observation:** Some obstacles appear too wide. The player may visually appear to have cleared an
obstacle while still being in collision range, or may appear to clip into the art while the collision
hasn't triggered yet. This creates confusion about whether the obstacle was "fair."

**Root cause — aspect ratio mismatch:**
The Level 2 obstacle PNGs are landscape images (wide-and-short), but the Level 1 collision boxes
are portrait-proportioned (taller-than-wide). Scaling by target height makes the visuals extremely wide.

| Obstacle | PNG | Col W | Visual W at current scale | Ratio |
|---|---|---|---|---|
| block (obs_concrete_block_01) | 303×193 | 30px | ~138px | 4.6× too wide |
| barrier (obs_bollard_rope_01) | 402×218 | 68px | ~147px | 2.2× too wide |
| cone (obs_broken_pier_chunk_01) | 309×161 | 30px | ~154px | 5.1× too wide |
| crate (obs_crate_stack_01) | 283×316 | 48px | ~86px | 1.8× — acceptable |
| sign (obs_broken_pier_chunk_01) | 309×161 | 38px | ~138px | 3.6× too wide |

**Impact:** Landscape obstacles appear wide as "scenery." The concrete block and bollard rope look like
floor decorations rather than jumpaable barriers. Critically, the collision box is NARROWER than the
visual by 50-100px on each side — the player is colliding with invisible air while the art still looks
clear.

**Recommended fix — double-scale constraint:**
In `level2_obstacle_visuals.gd::apply_skin()`, apply min(scale_by_height, scale_by_max_width):

```gdscript
# Max visual width per type (world units), keyed to collision_width for fairness
const MAX_VISUAL_WIDTHS: Dictionary = {
    "block":   72.0,   # 2.4× collision_width=30 — looks solid, not floor-wide
    "barrier": 100.0,  # 1.5× collision_width=68
    "cone":    60.0,   # 2× collision_width=30
    "crate":   80.0,   # 1.7× collision_width=48 — crate is already portrait, leave room
    "sign":    72.0,   # 1.9× collision_width=38
}

# In apply_skin():
var s_h := vis_h / raw_h
var raw_w := float(tex.get_width())
var max_w: float = MAX_VISUAL_WIDTHS.get(obstacle_type, vis_h * 1.5)
var s_w := max_w / raw_w
var s := minf(s_h, s_w)   # use smaller scale factor — constrains both height and width
```

This makes the concrete block look like a solid compact cube (better visual) and prevents landscape
images from spreading sideways across the pier.

**File:** `scripts/level2/gameplay/level2_obstacle_visuals.gd`

**Risk:** LOW — no physics change. Visual scale only.

**Acceptance:** Obstacle visual width is proportional. Player can see the obstacle, judge its width,
and jump over it. No art extends more than ~80px beyond the collision box on each side.

---

## 4. Collectible Lane Readability

**Observation:** Collectibles are clearer at 48px. Pattern cycling (LOW_LINE → SMALL_ARC → FULL_ARC)
is implemented. Main remaining issue: collectibles may appear directly adjacent to obstacles when
the clearance zone is insufficient, making patterns look random rather than teaching jump behavior.

**Root cause:**
Clearance zone was increased from 260 → 420px in the latest Codex commit. This helps but the
SMALL_ARC and FULL_ARC spawns place collectibles at Y=435-455 which overlaps with where the ambient
boat props are positioned (Y=425-458). Players may confuse collectible shards with boat debris.

**Recommended fix:**
- Keep current clearance zone (420px).
- SMALL_ARC spawn Y: ensure it is distinctly between run height and full jump height.
- FULL_ARC spawn Y: ensure it is visually above the buildings silhouette line (~30% of screen).
- Move ambient boat props slightly left so they do not overlap with collectible spawn X zones.
  Boats at fixed world positions (X=520, 790) may coincide with collectible patterns.

**File:** `scripts/level2/gameplay/level2_collectible_spawner.gd`

**Risk:** LOW.

**Acceptance:** Three clearly distinct visual bands: run-level, mid-air, high-arc. Player can see
each pattern and understand what jump depth is required.

---

## 5. Background Layer Usage

**Observation:** Background is mostly static. The 3-plate composition (sky + buildings + pier) is
clean and coherent. The building photograph already contains a rich harbor scene (boats, sea, mosque).
No additional opaque plates are needed. Current ambient props (seagulls, boat, flags) add life.

**Assessment of opaque disabled plates:**
- `bg_sea_breakwater.png`: The harbor photograph already shows sea and breakwater. Adding the separate
  plate would create a seam and add no meaningful depth.
- `mg_boats_mid.png`: Same. The photograph already shows mid-ground boats. Separate plate adds nothing.

**Verdict: keep both plates disabled.** The harbor photograph is the sea/boat layer.

**Improvement needed:**
The background feels static because the camera is fixed. Seagulls add movement but are small.
A slow foreground parallax scrolling using the pier stone texture would improve running feel,
but this requires the pier PNG to tile or a separate repeating foreground element.

See LEVEL2_BACKGROUND_COMPOSITION_STRATEGY.md for full strategy.

---

## 6. Parallax / Running Feel

**Observation:** The current experience: Jomana runs in place (camera fixed), obstacles approach
from the right. The harbor background is completely still. Seagulls and boats create ambient life
but not the sense of "running through" a place.

**Why camera-based parallax won't help:**
In a fixed-camera runner, the camera world position does not change during gameplay.
Godot's Parallax2D / ParallaxBackground uses `scroll_offset` driven by the camera viewport position.
With a fixed camera, scroll offset = constant = no movement. True parallax requires camera motion.

**Recommended approach — ambient motion only (safe, no seams):**
The correct motion budget for Level 2:

| Element | Motion | Implementation |
|---|---|---|
| Sky | FIXED | Camera-relative position update |
| Harbor buildings | FIXED | No drift (avoids seam on opaque non-seamless plate) |
| Pier ground | FIXED | Camera-relative |
| Transparent boats | Vertical bob only | HarborAmbientBob (already working) |
| Transparent flags | Horizontal micro-sway | HarborAmbientSway (already working) |
| Seagulls | Cross-screen flight | SeagullLoop (already working) |
| Water shimmer | Shader animation | Disabled (sea plate disabled) |
| Foreground stone | Optional: very slow scroll LEFT at 0.5–1.5 px/s | Only if using a seamless foreground tile |

**Do NOT add horizontal drift to any opaque plate.** Non-seamless images create seams at the copy join.

**For a stronger running feel without parallax:** increase seagull speed slightly and add a third
ambient element at the pier edge (e.g., animated wave splash at the base of the pier wall using a
CPUParticles2D or a scrolling water shimmer shader on a narrow ColorRect).

---

## 7. Boats / Flags / Net Prop Logic

**Observation:**
- Boats: visible but appear partially sunk (bottom portion occluded by pier at wrong Y)
- Flags: colorful and attractive but no visible poles/anchors on either side
- Net pile: ground-level prop, not visually problematic

**Recommended positions:**

| Prop | Current World Y | Recommended World Y | Reason |
|---|---|---|---|
| HarborBoatBlue | 452 | 425 | Show more hull above pier line |
| HarborBoatSmall | 458 | 430 | Same |
| HarborFlags | 435 | 430 | Bring slightly higher, anchor to pier top visual |
| HarborNet | 490 | 488 | Fine as-is |

**For flags:** Accept the "harbor bunting without visible poles" as a deliberate art choice —
it is common in real harbor scenes where ropes tie between boats/bollards off-screen.
Add a comment in code explaining this is intentional to avoid future "fix."

---

## 8. Family Portraits Integration Plan

**Assets confirmed on disk (RGBA, transparent background):**

| Character | File | Raw Size | Score |
|---|---|---|---|
| Ali (brother) | ali_checkpoint_01.png | 642×1254 | 15 |
| Zainab (sister) | zainab_checkpoint_01.png | 639×1254 | 35 |
| Fatima (mother) | fatima_checkpoint_01.png | 738×1254 | 60 |
| Father | father_checkpoint_01.png | 660×1254 | 90 |
| Family ending | family_ending_01.png | 1008×1003 | Ending panel |

**Code that handles this:** `level2_family_checkpoint_visuals.gd::apply_npc_art()` already:
1. Calls `MANIFEST.get_family_checkpoint_texture(character_id)`
2. Finds the non-transparent bounding rect via `ASSET_UTILS.get_texture_visible_rect()`
3. Scales to `NPC_VISUAL_HEIGHTS[char_id]` and bottom-aligns the feet

**NPC_VISUAL_HEIGHTS** (current values in the script):
- Ali: 150px
- Zainab: 140px
- Fatima: 105px (intentionally smallest — she's a toddler)
- Father: 190px

These values are appropriate for the character relative sizes seen in the portrait images.
Fatima at 105px renders as a young child (~50% of Father's height) — correct.

**What Codex must do:**
1. `git add assets/level2/marsa/characters/family/` — commit the PNGs
2. Verify `_build_npc_card()` calls `_family_vis.apply_npc_art()` first (it already does)
3. After portrait loads, the color-coded text card is NOT shown (portrait replaces it)
4. For the ending: `apply_ending_art(ending_node)` in `level2_family_checkpoint_visuals.gd`
   scales `family_ending_01.png` to half viewport width (576px). Verify this looks right.
5. Ensure the ending node is positioned correctly in the scene.

**Concern:** The ending panel currently reuses `$UI/GameOverPanel` with modified text.
`apply_ending_art(ending_node)` expects a Node2D positioned for the ending presentation.
If the ending is shown inside GameOverPanel, the Sprite2D art needs to be added to the Panel,
not a freestanding Node2D. Codex must check where `ending_node` is passed from.

---

## 9. Mouse / Touch / Keyboard Input

**Observation:** Keyboard Space triggers jump correctly. Mouse click does NOT trigger jump.
This breaks the expected Web experience where mouse click is the primary jump input.

**Root cause — likely:** During gameplay, `_unhandled_input` is used for jump. The `_unhandled_input`
handler only receives events not consumed by any other Node. If any Control node (including `score_label`)
has `mouse_filter != MOUSE_FILTER_IGNORE`, it may consume mouse clicks, preventing them from reaching
`_unhandled_input` in the scene root.

In Godot 4.x, Label nodes have `mouse_filter = MOUSE_FILTER_STOP` by default even though they don't
visually respond to clicks. The score label at the top-left corner is visible during gameplay and
may be consuming left-click events.

**Recommended fix (safest — no scene edit required):**
Move jump input from `_unhandled_input` to `_input` with explicit state guard:

```gdscript
# Remove from _unhandled_input:
#   (event is InputEventMouseButton and event.pressed)
#   (event is InputEventScreenTouch and event.pressed)

# Add to _input (before checkpoint check):
func _input(event: InputEvent) -> void:
    # Jump input — handle before checkpoint check
    if started and not game_over and not checkpoint_active and not countdown_active:
        if (event is InputEventMouseButton and event.pressed
                and event.button_index == MOUSE_BUTTON_LEFT):
            player.jump()
            get_viewport().set_input_as_handled()
            return
        if event is InputEventScreenTouch and event.pressed:
            player.jump()
            get_viewport().set_input_as_handled()
            return
    # Existing checkpoint dialogue advance logic follows...
```

Keep Space/keyboard in `_unhandled_input` (ui_accept already works there).

**Alternative fix (scene edit):** Set `mouse_filter = Control.MOUSE_FILTER_IGNORE` on:
- `$UI/ScoreLabel`
- Any other Label/Panel visible during gameplay that has no click behavior

**File:** `scripts/level2/level2_marsa_playable.gd` → `_input()` and `_unhandled_input()`

**Risk:** LOW. Careful state guard prevents double-jump and checkpoint-advance conflicts.

**Acceptance:** Left mouse click triggers jump during gameplay. Checkpoint dialogue advance still
works via tap/click when checkpoint_active is true.

---

## 10. Game Over, Retry, Checkpoint, and Ending Flow

**Assessment:** All flows work correctly per code review. No logic errors found.

| Flow | Status |
|---|---|
| Hit obstacle → Game Over panel | ✅ |
| Retry from last checkpoint | ✅ |
| Restart from score 0 | ✅ |
| Ali checkpoint at score 15 | ✅ |
| Zainab at 35 | ✅ |
| Fatima at 60 | ✅ |
| Father at 90 → ending | ✅ |
| Ending panel: "أحسنتِ يا جمانة" | ✅ |
| Return to menu button | ✅ |
| Replay chapter button | ✅ |
| Countdown 3-2-1 after checkpoint | ✅ |
| Speed progression 225→240→255→270 | ✅ |

**One pending item:** Family portrait PNGs are untracked. Once committed, the color-coded text card
will be replaced by the actual portrait art. Codex must verify the portrait Sprite2D is sized and
positioned so it does NOT cover the dialogue text panel at the same time.
