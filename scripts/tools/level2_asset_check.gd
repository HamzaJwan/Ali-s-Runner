## level2_asset_check.gd — Level 2 asset status headless report.
## Exits 0 always. Missing art is not a build failure.
##
## Run:
## Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/level2_asset_check.gd
extends SceneTree

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

func _init() -> void:
	print("\n══ LEVEL 2 ASSET CHECK ══════════════════════════════")

	# ── Jomana run frames ──────────────────────────────────────────────
	var run_found := 0
	for i: int in MANIFEST.JOMANA_RUN_COUNT:
		var p := MANIFEST.jomana_run_path(i + 1)
		if MANIFEST.file_exists(p):
			run_found += 1
	_report("Jomana run frames", run_found, MANIFEST.JOMANA_RUN_COUNT)

	# ── Jomana idle ───────────────────────────────────────────────────
	var idle_found := 0
	for i: int in MANIFEST.JOMANA_IDLE_COUNT:
		var p := MANIFEST.jomana_idle_path(i + 1)
		if MANIFEST.file_exists(p):
			idle_found += 1
	_report("Jomana idle frames", idle_found, MANIFEST.JOMANA_IDLE_COUNT)

	# ── Jomana single poses ───────────────────────────────────────────
	for info: Array in [
		["Jomana jump",        MANIFEST.JOMANA_JUMP],
		["Jomana land",        MANIFEST.JOMANA_LAND],
		["Jomana wave/story",  MANIFEST.JOMANA_WAVE],
		["Jomana dialogue",    MANIFEST.JOMANA_CLOSE],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Backgrounds ───────────────────────────────────────────────────
	for info: Array in [
		["BG sky",         MANIFEST.BG_SKY],
		["BG sea",         MANIFEST.BG_SEA],
		["BG buildings",   MANIFEST.BG_BUILDINGS],
		["BG boats mid",   MANIFEST.BG_BOATS],
		["BG pier ground", MANIFEST.BG_PIER],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Obstacles ─────────────────────────────────────────────────────
	for info: Array in [
		["Obstacle concrete", MANIFEST.OBS_CONCRETE],
		["Obstacle crates",   MANIFEST.OBS_CRATES],
		["Obstacle bollard",  MANIFEST.OBS_BOLLARD],
		["Obstacle pier chunk", MANIFEST.OBS_PIER],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Family checkpoints ────────────────────────────────────────────
	for info: Array in [
		["Family Ali",       MANIFEST.FAM_ALI],
		["Family Zainab",    MANIFEST.FAM_ZAINAB],
		["Family Fatima",    MANIFEST.FAM_FATIMA],
		["Family Father",    MANIFEST.FAM_FATHER],
		["Family ending",    MANIFEST.FAM_ENDING],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Collectibles ──────────────────────────────────────────────────
	for info: Array in [
		["Collectible shard single", MANIFEST.COL_SHARD_SINGLE],
		["Collectible shard sheet",  MANIFEST.COL_SHARD_SHEET],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Audio ──────────────────────────────────────────────────────────
	for info: Array in [
		["Audio sea ambience",  MANIFEST.AUD_SEA_AMB],
		["Audio harbour theme", MANIFEST.AUD_THEME],
		["Audio seagull SFX",   MANIFEST.AUD_SEAGULL],
		["Audio pickup SFX",    MANIFEST.AUD_PICKUP],
		["Audio checkpoint",    MANIFEST.AUD_CHECKPOINT],
		["Audio retry",         MANIFEST.AUD_RETRY],
		["Audio jump (Jomana)", MANIFEST.AUD_JUMP],
		["Audio footstep",      MANIFEST.AUD_FOOTSTEP],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("──────────────────────────────────────────────────────")

	# ── Ambient props ─────────────────────────────────────────────────────
	for info: Array in [
		["Seagull fly sheet (4f)",   MANIFEST.AMB_SEAGULL_SHEET],
		["Boat blue",                MANIFEST.AMB_BOAT_BLUE],
		["Boat small",               MANIFEST.AMB_BOAT_SMALL],
		["Flags line",               MANIFEST.AMB_FLAGS],
		["Rope hanging",             MANIFEST.AMB_ROPE],
		["Fishing net pile",         MANIFEST.AMB_DECO_NET],
	]:
		_report(info[0] as String, 1 if MANIFEST.file_exists(info[1]) else 0, 1)

	print("══════════════════════════════════════════════════════")
	print("LEVEL2_ASSET_CHECK=DONE  (exit 0 — missing art is not a build failure)")
	print("See docs/level2/LEVEL2_ASSET_DROP_GUIDE.md for next steps.\n")
	quit(0)


func _report(label: String, found: int, total: int) -> void:
	var icon := "✅" if found == total else ("⚠️" if found > 0 else "⬜")
	print("  %s  %-28s  %d/%d" % [icon, label, found, total])
