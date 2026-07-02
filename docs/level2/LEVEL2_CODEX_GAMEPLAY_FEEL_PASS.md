# Codex Level 2 Gameplay Feel and Composition Pass
# Smooth Jomana States, Mouse Jump, Fair Obstacles, Family Portraits, and Honest Background Motion

Branch: level2/jomana-marsa-mvp-20260701
Workspace: D:\GODOT\test1\test
Base commit: c8ce6e9

────────────────────────────────────────────────────────
GROUND RULES
────────────────────────────────────────────────────────
- Do NOT touch scenes/Main.tscn or Level 1 scripts.
- Do NOT touch Docker, web-deploy, or export settings.
- Do NOT change core physics constants (ROAD_SURFACE_Y, jump force, gravity).
- Do NOT wire Level 2 into the main menu.
- Do NOT deploy anything.
- Do NOT double jump, slide, damage, enemies, or hostile animals.
- Do NOT add sound files — only wire existing ones.
- Work only in: scripts/level2/, scripts/tools/, docs/level2/,
  and assets/level2/marsa/characters/family/ (commit existing files).

────────────────────────────────────────────────────────
STEP 0 — PULL AND VERIFY
────────────────────────────────────────────────────────
git pull origin level2/jomana-marsa-mvp-20260701

Verify family portrait PNGs exist (must NOT be empty):
  assets/level2/marsa/characters/family/ali_checkpoint_01.png        (expected ~642×1254 RGBA)
  assets/level2/marsa/characters/family/zainab_checkpoint_01.png     (expected ~639×1254 RGBA)
  assets/level2/marsa/characters/family/fatima_checkpoint_01.png     (expected ~738×1254 RGBA)
  assets/level2/marsa/characters/family/father_checkpoint_01.png     (expected ~660×1254 RGBA)
  assets/level2/marsa/characters/family/family_ending_01.png         (expected ~1008×1003 RGBA)

If any file is missing or zero bytes: STOP and report. Do not continue.

────────────────────────────────────────────────────────
CHANGE 1 — COMMIT FAMILY PORTRAIT ASSETS
────────────────────────────────────────────────────────
The family PNG files are on disk but untracked. Add them to git:

  git add assets/level2/marsa/characters/family/

After staging, verify with `git diff --cached --stat` that exactly 5 .png and
5 .png.import files are staged (10 total). If .png.import files do not exist yet,
Godot will generate them on next import — that is fine, add the .png files only.

────────────────────────────────────────────────────────
CHANGE 2 — INTEGRATE FAMILY PORTRAITS INTO CHECKPOINTS
────────────────────────────────────────────────────────
File: scripts/level2/story/level2_family_checkpoint_visuals.gd

This file already implements apply_npc_art(npc_node, character_id) and
apply_ending_art(ending_node). The code is already correct. Verify it will
work with the new RGBA portrait PNGs by checking:

a) NPC_VISUAL_HEIGHTS for each character (current values):
   Ali: 150, Zainab: 140, Fatima: 105, Father: 190
   These are WORLD UNITS (not screen pixels). At zoom 1.18 they become:
   Ali: 177px screen, Fatima: 124px screen, Father: 224px screen.
   These sizes are CORRECT for relative character proportions. Keep them.

b) apply_npc_art() calls get_texture_visible_rect() to find non-transparent bounds.
   This is correct for RGBA PNGs. No change needed.

c) apply_ending_art() scales family_ending_01.png to half viewport width (576px).
   Check: the ending is shown via _show_level2_ending() which uses $UI/GameOverPanel.
   The ending portrait must be added to the GameOverPanel/Card node or the panel must
   be made larger/transparent to show the image behind the text.

   In _show_level2_ending() in level2_marsa_playable.gd:
   - Find or create a Node2D/Control anchor inside GameOverPanel/Card for the portrait.
   - Call: _family_vis.apply_ending_art(<anchor_node>)
   - Position the portrait behind the text (low z_index within the card).
   - Ensure the family portrait does NOT cover the "أحسنتِ يا جمانة!" text — place it
     at the bottom half of the card or as a full-card background with slight transparency.

   If the card is too small for the ending image, increase its size ONLY for the ending.
   Do NOT resize the game-over card — restore original size after ending is dismissed.

File also involved: scripts/level2/level2_marsa_playable.gd → _show_level2_ending()

────────────────────────────────────────────────────────
CHANGE 3 — FIX MOUSE CLICK JUMP
────────────────────────────────────────────────────────
File: scripts/level2/level2_marsa_playable.gd

Problem: Left mouse click does not trigger jump. Root cause: _unhandled_input()
only receives events not consumed by UI Control nodes. The ScoreLabel (and possibly
other Controls) have mouse_filter = MOUSE_FILTER_STOP by default, consuming clicks
before they reach _unhandled_input.

Fix: Move mouse and touch jump handling from _unhandled_input() to _input(), with
explicit state guards. Keep Space/keyboard in _unhandled_input().

Current _unhandled_input():
  func _unhandled_input(event: InputEvent) -> void:
      if not started or game_over or checkpoint_active or countdown_active:
          return
      if event.is_action_pressed("ui_accept") \
      or (event is InputEventMouseButton and event.pressed) \
      or (event is InputEventScreenTouch and event.pressed):
          player.jump()

New _unhandled_input() (Space/keyboard only):
  func _unhandled_input(event: InputEvent) -> void:
      if not started or game_over or checkpoint_active or countdown_active:
          return
      if event.is_action_pressed("ui_accept"):
          player.jump()

In _input(), ADD before the checkpoint logic block:
  func _input(event: InputEvent) -> void:
      # Mouse/touch jump — use _input so UI controls don't eat the event
      if started and not game_over and not checkpoint_active and not countdown_active:
          if (event is InputEventMouseButton
                  and event.pressed
                  and event.button_index == MOUSE_BUTTON_LEFT):
              player.jump()
              get_viewport().set_input_as_handled()
              return
          if event is InputEventScreenTouch and event.pressed:
              player.jump()
              get_viewport().set_input_as_handled()
              return

      # Existing checkpoint dialogue advance logic stays here (unchanged):
      if not checkpoint_active:
          return
      ...

IMPORTANT: Do NOT remove the set_input_as_handled() call in the checkpoint dialogue
advance block. Keep everything below the jump guard exactly as it is now.

────────────────────────────────────────────────────────
CHANGE 4 — SMOOTH IDLE → RUN TRANSITION
────────────────────────────────────────────────────────
File: scripts/level2/level2_marsa_playable.gd

Problem: When play is pressed, Jomana snaps from IDLE to RUN instantly.
The 1.4s camera reveal happens while she is already animating in RUN pose —
the snap occurs before any cinematic motion, making it visually jarring.

Fix: Keep Jomana in IDLE during the harbor reveal. Switch to RUN only after
the camera tween finishes.

In _on_play_pressed():
  # Remove: _jomana_vis.set_pose(_jomana_vis.Pose.RUN)   ← delete this line
  # Add to _play_harbor_reveal() tween.finished callback:

In _play_harbor_reveal(), the tween already has a finished.connect callback.
Extend it to also switch Jomana to RUN:

  _cam_tween.finished.connect(
      func() -> void:
          print("[L2 play] camera_transition_done=true")
          if is_instance_valid(_jomana_vis) and started and not game_over:
              _jomana_vis.set_pose(_jomana_vis.Pose.RUN),
      CONNECT_ONE_SHOT
  )

Also in _on_play_pressed(), ensure Jomana is explicitly in IDLE at the start:
  if is_instance_valid(_jomana_vis):
      _jomana_vis.set_pose(_jomana_vis.Pose.IDLE)   # stay idle during reveal

IMPORTANT: The "stuck in IDLE" guard in _process() will detect that Jomana is
in IDLE after the countdown. Ensure the countdown path also sets RUN:
  _finish_countdown() already calls _jomana_vis.set_pose(Pose.RUN) — keep this.
  This is the retry/continue path and must NOT be changed.

────────────────────────────────────────────────────────
CHANGE 5 — FIX OBSTACLE VISUAL WIDTH
────────────────────────────────────────────────────────
File: scripts/level2/gameplay/level2_obstacle_visuals.gd

Problem: Landscape-format PNGs (bollard 402×218, concrete block 303×193, pier chunk 309×161)
scaled by height produce visuals 3-5x wider than their collision boxes.
This makes obstacles look like floor decorations, not jumpaable barriers.

Fix: Add a max visual width constraint. For each obstacle type, define the maximum
world-unit width the visual skin may occupy. Scale by min(scale_from_height, scale_from_max_width).

Add this constant dict after COLLISION_HEIGHTS:

const MAX_VISUAL_WIDTHS: Dictionary = {
    "block":   70.0,
    "barrier": 100.0,
    "cone":    65.0,
    "crate":   90.0,
    "sign":    68.0,
}

In apply_skin(), change the scale calculation from:
  var s := vis_h / raw_h

To:
  var raw_w := float(tex.get_width())
  var s_h := vis_h / raw_h
  var max_w: float = MAX_VISUAL_WIDTHS.get(obstacle_type, vis_h * 1.5)
  var s_w := max_w / raw_w
  var s := minf(s_h, s_w)

The skin.scale = Vector2(s, s) line remains unchanged — just s is now constrained.

Keep all VISUAL_HEIGHTS values (88/80/80/96/72) unchanged. The max-width constraint
takes effect only when the PNG's native aspect ratio would make the visual too wide.
The crate (283×316) is portrait format and will not be constrained (its natural
width is already narrow relative to its height).

────────────────────────────────────────────────────────
CHANGE 6 — BOAT PROP POSITIONS
────────────────────────────────────────────────────────
File: scripts/level2/level2_marsa_playable.gd → _build_ambient_props()

Problem: Boats appear to be sinking — their hulls are partially hidden below the pier edge.
The pier foreground (z=-5) occludes boats (z=-8) below CURB_TOP_Y=470.
Boats at Y=452-458 have only ~12-18 world units visible above the pier edge.

Fix: Move boats upward so more of the hull is visible above the pier wall:

Change:
  _add_ambient_sprite(L2_MANIFEST.AMB_BOAT_BLUE, Vector2(520, 452), 92.0, ...)
  _add_ambient_sprite(L2_MANIFEST.AMB_BOAT_SMALL, Vector2(790, 458), 68.0, ...)

To:
  _add_ambient_sprite(L2_MANIFEST.AMB_BOAT_BLUE, Vector2(520, 420), 92.0, ...)
  _add_ambient_sprite(L2_MANIFEST.AMB_BOAT_SMALL, Vector2(790, 426), 68.0, ...)

At Y=420, boats are 50 world units above CURB_TOP_Y=470. At zoom 1.18, the pier occludes
~59px of screen height from Y=470 downward. The boat hull (at 92px world units tall)
will show approximately 70% above the pier line — visually correct (boat floating, stern
low, mast visible above).

The bob animation (amplitude 3.5px) still applies via HarborAmbientBob script.
No script change needed.

────────────────────────────────────────────────────────
CHANGE 7 — ADD DEBUG CONSTANTS
────────────────────────────────────────────────────────
File: scripts/level2/level2_marsa_playable.gd

Add these constants near the top of the file after the camera constants block:

# Debug switches — set true during local testing only, always false in commits
const DEBUG_LEVEL2_COMPOSITION := false
const DEBUG_L2_INPUT := false

In _input(), after the mouse/touch jump handling:
  if DEBUG_L2_INPUT and (event is InputEventMouseButton or event is InputEventKey):
      print("[L2 input] type=%s pressed=%s" % [event.get_class(), event.is_pressed()])

In _update_background_parallax():
  if DEBUG_LEVEL2_COMPOSITION:
      print("[L2 bg] cam_x=%.0f cam_y=%.0f zoom=%.2f scroll=%.0f" %
          [game_camera.position.x, game_camera.position.y, game_camera.zoom.x, scroll])

────────────────────────────────────────────────────────
VALIDATION
────────────────────────────────────────────────────────
Run ALL of the following. All must pass before committing.

1. Boot check (project-level):
   Godot_v4.7-stable_win64_console.exe --headless --path . --quit
   Expected: exit 0, no SCRIPT ERROR, no parse error.

2. RC smoke:
   Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/rc_smoke_check.gd
   Expected: exit 0.

3. Level 2 scene load:
   Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/Level2_Marsa_Playable.tscn --quit
   Expected: exit 0. Check stdout for:
   - "[L2 Env] loaded" lines for all 3 active plates
   - "[L2 obstacle] type=... legacy_hidden=true" for at least one obstacle type (if smoke spawns one)
   - No "Invalid call" errors
   - "[L2 story] character=1 art=..." confirming Ali portrait loaded

4. Asset check:
   Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
   Expected: family 5/5 (or 4/4 if family_ending counted separately), jomana_run 8/8.

5. Runtime smoke:
   Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd
   Expected: LEVEL2_RUNTIME_SMOKE=PASS.

6. Level 1 regression (MUST pass — production scene):
   Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
   Expected: exit 0, no errors.

If any check fails: fix before committing.

────────────────────────────────────────────────────────
DOCUMENTATION UPDATES
────────────────────────────────────────────────────────
After all code changes are verified:

docs/level2/LEVEL2_STATUS_BOARD.md:
  - Change gate to: OWNER_F6_PENDING - gameplay feel pass complete
  - Add: "P1 mouse jump FIXED", "P2 IDLE→RUN FIXED", "P3 obstacle width FIXED"
  - Add: "P4 boats repositioned", "P5 family portraits committed and active"

docs/level2/LEVEL2_DEPLOY_HANDOFF.md:
  - Update status to: OWNER_F6_PENDING
  - Update family checkpoint table: all 4 characters now show portrait art
  - Add: "family_ending_01.png shown in ending panel"
  - Update boat positions: HarborBoatBlue Y=420, HarborBoatSmall Y=426
  - Keep: DO NOT DEPLOY until owner F6 approval

────────────────────────────────────────────────────────
COMMIT AND PUSH
────────────────────────────────────────────────────────
Stage in this order:

1. Family portrait assets (if not already staged):
   git add assets/level2/marsa/characters/family/

2. Changed scripts:
   git add scripts/level2/level2_marsa_playable.gd
   git add scripts/level2/gameplay/level2_obstacle_visuals.gd
   git add scripts/level2/story/level2_family_checkpoint_visuals.gd   (if changed)

3. Changed docs:
   git add docs/level2/LEVEL2_STATUS_BOARD.md
   git add docs/level2/LEVEL2_DEPLOY_HANDOFF.md

Commit message:
  level2: gameplay feel pass — mouse jump, IDLE delay, obstacle width, boats, family portraits

Push:
  git push origin level2/jomana-marsa-mvp-20260701

────────────────────────────────────────────────────────
DO NOT
────────────────────────────────────────────────────────
- Do NOT deploy to any server
- Do NOT touch scenes/Main.tscn
- Do NOT change physics (jump force, gravity, ROAD_SURFACE_Y)
- Do NOT wire Level 2 into the main menu
- Do NOT modify the web export preset
- Do NOT change Level 1 audio or Level 1 obstacle definitions
- Do NOT merge to main branch
