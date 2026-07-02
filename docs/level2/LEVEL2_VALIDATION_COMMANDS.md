# Level 2 Validation Commands
# Last updated: 2026-07-02
# Run these before any commit, staging deployment, or owner handoff.

---

## Prerequisites

Godot 4.7 stable console executable must be in your PATH or specified with full path.
All commands run from the project root: `D:\GODOT\test1\test`

Replace `Godot_v4.7-stable_win64_console.exe` with the full path if needed:
`D:\GODOT\Godot_v4.7-stable_win64_console.exe`

---

## Command 1 — Project Boot Check

```
Godot_v4.7-stable_win64_console.exe --headless --path . --quit
```

**PASS:** Exit code 0. No `SCRIPT ERROR` or `Parse Error` lines in stdout.

**FAIL:** Exit code non-zero OR any parse error printed.

**What this checks:** The project's `scenes/Main.tscn` (Level 1) loads cleanly.
All autoloads (MobileRotateOverlay, etc.) parse and initialize without error.

**What this does NOT check:** Visual output, gameplay, Level 2 scene, audio playback.

---

## Command 2 — General RC Smoke

```
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/rc_smoke_check.gd
```

**PASS:** Exit code 0. Prints summary of scene count and autoload count.

**FAIL:** Exit code non-zero OR missing required autoloads.

**What this checks:** Project structure is intact, key scenes and autoloads are registered.

---

## Command 3 — Level 2 Scene Load

```
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/Level2_Marsa_Playable.tscn --quit
```

**PASS:** Exit code 0. No `SCRIPT ERROR` or `Parse Error`. No `Invalid call.` errors.

**FAIL:** Exit code non-zero OR any GDScript error in output.

**What this checks:** `Level2_Marsa_Playable.tscn` parses and `_ready()` runs without crashing.
It also prints `[L2 framing]`, `[L2 parallax]`, `[L2 Env]`, `[L2 ambient]` debug lines confirming
which assets loaded.

**What to look for in output:**
- `[L2 Env] loaded L2_SkyLayer` → sky PNG loaded
- `[L2 Env] loaded L2_FarBuildingsLayer` → buildings PNG loaded
- `[L2 Env] loaded L2_ForegroundPierLayer` → pier PNG loaded
- `[L2 ambient] active=HarborBoatBlue` → boat props active
- `[L2 obstacle] hidden Level 1 node 'ObstacleSprite'` → B1 fix confirmed (after patch)
- `[L2 framing] player_screen_x=200 road_screen_y=... ground_share=28%` → camera correct

**Red flags in output:**
- `Invalid call. Expected 2 arguments.` → B1 obstacle skin bug still present
- `Missing textures (procedural fallback)` → PNG not found, fallback used
- `SCRIPT ERROR` + line number → parse/runtime error

---

## Command 4 — Level 2 Asset Check

```
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
```

**PASS:** Exit code 0 always (this tool never exits with error by design).
Look for asset status table in stdout.

**Output format:**
```
╔══════════════════════════════════════╗
║  LEVEL 2 ASSET STATUS                ║
╠══════════════════════════════════════╣
║  ✅  jomana_run      8/8
║  ✅  jomana_idle     4/4
║  ✅  backgrounds     3/5    ← 3 of 5 present (2 disabled, OK)
║  ✅  obstacles       4/4
║  ⬜  family          0/4    ← portraits not generated yet (OK)
║  ✅  audio           6/6
╚══════════════════════════════════════╝
```

**What this checks:** Which required asset files exist on disk per the manifest.

**Expected status for current build:**
- jomana_run: 8/8 ✅
- jomana_idle: 4/4 ✅
- backgrounds: 5/5 present on disk (2 disabled in code — that is OK) ✅
- obstacles: 4/4 ✅
- family: 0/4 (portraits not generated — expected, use text card fallback) ⬜
- audio: 8/8 ✅

**What this does NOT check:** Whether the assets look correct, whether the
code actually loads them successfully, or whether visuals are rendering properly.
Owner F6 visual review is still required.

---

## Command 5 — Level 2 Runtime Smoke

```
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd
```

**PASS:** Exit code 0. Prints `LEVEL2_RUNTIME_SMOKE=PASS`.

**FAIL:** Exit code non-zero OR prints `LEVEL2_RUNTIME_SMOKE=FAIL`.

**What this checks:** The Level 2 scene instanciates, `_ready()` completes,
and `debug_start_gameplay_for_smoke()` can be called without error.
Confirms the Play button path does not crash or deadlock.

**What this does NOT check:** Visual output, animation frames loading correctly,
audio playback, obstacle skins, collectible visuals, or anything requiring
the rendering engine.

---

## Level 1 Regression Check (Always Run Before Any Commit)

```
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
```

**PASS:** Exit code 0. No parse errors. Level 1 production scene is unaffected.

**FAIL:** Any exit non-zero or error output.

This is the most important check. Level 1 is live at game.juanspace.org.
No Level 2 commit should ever break Level 1.

---

## Full Pre-Commit Checklist

Run all 5 in sequence. All must pass:

```
Godot_v4.7-stable_win64_console.exe --headless --path . --quit
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/rc_smoke_check.gd
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/level2/Level2_Marsa_Playable.tscn --quit
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_runtime_smoke.gd
```

Then verify Level 1 is still clean:
```
Godot_v4.7-stable_win64_console.exe --headless --path . scenes/Main.tscn --quit
```

---

## Important: What Automated Checks Cannot Replace

Automated headless checks verify that code parses, scenes load, and key paths do not crash.
They cannot verify:

- Visual composition (background plates, seams, framing)
- Animation correctness (Jomana run cycle looks smooth, no frame pops)
- Obstacle skin visual (harbor PNG is showing, not L1 red barrier)
- Collectible size (shard is visible and proportional)
- Arabic text rendering and RTL direction
- Checkpoint dialogue advances correctly
- Audio plays at the right moments
- Overall game feel matches the design intent

**Owner F6 visual review is always required before staging or production deployment.**
