## level2_asset_manifest.gd
## Single source of truth for ALL Level 2 asset paths.
## Every loader in Level 2 reads from this manifest so filenames
## never drift between docs, code, and the actual files on disk.
##
## Usage: const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")
##        var frames := MANIFEST.get_jomana_run_frames()
##
## Never crashes: every helper returns an empty array/null/false when files
## are missing; callers fall back to placeholders.
class_name Level2AssetManifest
extends RefCounted

# ── Root paths ─────────────────────────────────────────────────────────────
const ROOT          := "res://assets/level2/marsa/"
const ROOT_CHAR     := ROOT + "characters/jomana/"
const ROOT_FAMILY   := ROOT + "characters/family/"
const ROOT_BG       := ROOT + "backgrounds/"
const ROOT_OBS      := ROOT + "obstacles/"
const ROOT_COL      := ROOT + "collectibles/"
const ROOT_AMBIENT  := ROOT + "ambient/"
const ROOT_AUDIO    := ROOT + "audio/"

# ── Jomana character ────────────────────────────────────────────────────────
const JOMANA_RUN_COUNT  := 8
const JOMANA_IDLE_COUNT := 4

static func jomana_run_path(i: int) -> String:
	return ROOT_CHAR + "run/jomana_run_%02d.png" % i

static func jomana_idle_path(i: int) -> String:
	return ROOT_CHAR + "idle/jomana_idle_%02d.png" % i

const JOMANA_JUMP   := ROOT_CHAR + "jump/jomana_jump_01.png"
const JOMANA_LAND   := ROOT_CHAR + "jump/jomana_land_01.png"
const JOMANA_WAVE   := ROOT_CHAR + "story/jomana_smile_wave_01.png"
const JOMANA_CLOSE  := ROOT_CHAR + "story/jomana_dialogue_closeup_01.png"

# ── Background layers ───────────────────────────────────────────────────────
const BG_SKY       := ROOT_BG + "bg_sky_marsa.png"
const BG_SEA       := ROOT_BG + "bg_sea_breakwater.png"
const BG_BUILDINGS := ROOT_BG + "bg_harbor_buildings.png"
const BG_BOATS     := ROOT_BG + "mg_boats_mid.png"
const BG_PIER      := ROOT_BG + "fg_pier_ground.png"

# ── Obstacles ───────────────────────────────────────────────────────────────
const OBS_CONCRETE := ROOT_OBS + "obs_concrete_block_01.png"
const OBS_CRATES   := ROOT_OBS + "obs_crate_stack_01.png"
const OBS_BOLLARD  := ROOT_OBS + "obs_bollard_rope_01.png"
const OBS_PIER     := ROOT_OBS + "obs_broken_pier_chunk_01.png"

# Obstacle type string → path mapping (matches Level 1 OBSTACLE_DEFINITIONS keys)
const OBSTACLE_TEXTURE_MAP: Dictionary = {
	"block":    OBS_CONCRETE,
	"barrier":  OBS_BOLLARD,
	"cone":     OBS_BOLLARD,   # reuse bollard visual until cone art exists
	"crate":    OBS_CRATES,
	"sign":     OBS_PIER,      # reuse pier chunk until sign art exists
}

# ── Collectibles ────────────────────────────────────────────────────────────
const COL_SHARD_SINGLE := ROOT_COL + "col_light_shard_pink_01.png"   # actual filename owner generated
const COL_SHARD_SHEET  := ROOT_COL + "col_athar_shard_sheet_6f.png"  # 6-frame animated

# ── Ambient props ───────────────────────────────────────────────────────────
const AMB_SEAGULL_SHEET  := ROOT_AMBIENT + "seagulls/seagull_fly_sheet_4f.png"
const AMB_SEAGULL_SINGLE := ROOT_AMBIENT + "seagulls/seagull_single_01.png"
const AMB_BOAT_BLUE      := ROOT_AMBIENT + "boats/boat_blue_01.png"
const AMB_BOAT_SMALL     := ROOT_AMBIENT + "boats/boat_small_02.png"
const AMB_FLAGS          := ROOT_AMBIENT + "wind_props/small_flags_line_01.png"
const AMB_ROPE           := ROOT_AMBIENT + "wind_props/rope_hanging_01.png"
const AMB_DECO_NET       := ROOT_AMBIENT + "deco/deco_fishing_net_pile_01.png"

# ── Family checkpoint sprites ───────────────────────────────────────────────
const FAM_ALI        := ROOT_FAMILY + "ali_checkpoint_01.png"
const FAM_ZAINAB     := ROOT_FAMILY + "zainab_checkpoint_01.png"
const FAM_FATIMA     := ROOT_FAMILY + "fatima_checkpoint_01.png"
const FAM_FATHER     := ROOT_FAMILY + "father_checkpoint_01.png"
const FAM_ENDING     := ROOT_FAMILY + "family_marsa_ending_01.png"

# ── Audio ───────────────────────────────────────────────────────────────────
const AUD_SEA_AMB    := ROOT_AUDIO + "sea_ambience_loop.wav"
const AUD_THEME      := ROOT_AUDIO + "marsa_theme_loop.wav"
const AUD_SEAGULL    := ROOT_AUDIO + "seagull_distant_01.wav"
const AUD_PICKUP     := ROOT_AUDIO + "athar_pickup_01.wav"
const AUD_CHECKPOINT := ROOT_AUDIO + "checkpoint_chime_01.wav"
const AUD_RETRY      := ROOT_AUDIO + "retry_soft_01.wav"
const AUD_JUMP       := ROOT_AUDIO + "jomana_jump_01.wav"
const AUD_FOOTSTEP   := ROOT_AUDIO + "footstep_stone_01.wav"

# ── Helper methods ──────────────────────────────────────────────────────────

static func file_exists(path: String) -> bool:
	return ResourceLoader.exists(path)


## Returns array of Texture2D for Jomana run frames (empty if not all 8 present).
static func get_jomana_run_frames() -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for i: int in JOMANA_RUN_COUNT:
		var tex := load(jomana_run_path(i + 1)) as Texture2D
		if tex == null:
			return []   # all-or-nothing for run cycle consistency
		frames.append(tex)
	return frames


## Returns array of Texture2D for idle frames (empty if none found).
static func get_jomana_idle_frames() -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for i: int in JOMANA_IDLE_COUNT:
		var tex := load(jomana_idle_path(i + 1)) as Texture2D
		if tex != null:
			frames.append(tex)
	return frames


## Returns {node_name: path} dict for the 5 background layers.
static func get_background_layers() -> Dictionary:
	return {
		"L2_SkyLayer":              BG_SKY,
		"L2_SeaBreakwaterLayer":    BG_SEA,
		"L2_FarBuildingsLayer":     BG_BUILDINGS,
		"L2_BoatsMidLayer":         BG_BOATS,
		"L2_ForegroundPierLayer":   BG_PIER,
	}


## Returns texture for a given obstacle type, or null if missing.
static func get_obstacle_texture(obs_type: String) -> Texture2D:
	var path: String = OBSTACLE_TEXTURE_MAP.get(obs_type, "")
	if path.is_empty():
		return null
	return load(path) as Texture2D


## Returns texture for family checkpoint sprite, or null if missing.
## character_id matches Level2EncounterData constants.
static func get_family_checkpoint_texture(character_id: int) -> Texture2D:
	var path := ""
	match character_id:
		1: path = FAM_ALI        # Level2EncounterData.ALI
		2: path = FAM_ZAINAB     # Level2EncounterData.ZAINAB
		3: path = FAM_FATIMA     # Level2EncounterData.FATIMA
		4: path = FAM_FATHER     # Level2EncounterData.FATHER
	if path.is_empty():
		return null
	return load(path) as Texture2D


## Returns absolute path to an audio file if it exists on disk.
## Returns empty string if missing (caller should use Level 1 fallback or silence).
static func get_audio_path(audio_id: String) -> String:
	var map: Dictionary = {
		"sea_ambience": AUD_SEA_AMB,
		"theme":        AUD_THEME,
		"seagull":      AUD_SEAGULL,
		"pickup":       AUD_PICKUP,
		"checkpoint":   AUD_CHECKPOINT,
		"retry":        AUD_RETRY,
		"jump":         AUD_JUMP,
		"footstep":     AUD_FOOTSTEP,
	}
	var path: String = map.get(audio_id, "")
	if path.is_empty() or not file_exists(path):
		return ""
	return path


## Lists all required assets and whether they exist.
static func get_missing_required_assets() -> Array[String]:
	var required: Array[String] = []
	for i: int in JOMANA_RUN_COUNT:
		required.append(jomana_run_path(i + 1))
	required.append_array([BG_SKY, BG_SEA, BG_BUILDINGS, BG_BOATS, BG_PIER])
	required.append_array([OBS_CONCRETE, OBS_CRATES, OBS_BOLLARD, OBS_PIER])
	var missing: Array[String] = []
	for p: String in required:
		if not file_exists(p):
			missing.append(p)
	return missing


## Returns dict with counts of found vs total for each category.
static func get_available_assets() -> Dictionary:
	var run_found := 0
	for i: int in JOMANA_RUN_COUNT:
		if file_exists(jomana_run_path(i + 1)):
			run_found += 1
	var idle_found := 0
	for i: int in JOMANA_IDLE_COUNT:
		if file_exists(jomana_idle_path(i + 1)):
			idle_found += 1
	var bg_found := 0
	for p: String in get_background_layers().values():
		if file_exists(p):
			bg_found += 1
	var obs_found := 0
	for p: String in [OBS_CONCRETE, OBS_CRATES, OBS_BOLLARD, OBS_PIER]:
		if file_exists(p):
			obs_found += 1
	var fam_found := 0
	for p: String in [FAM_ALI, FAM_ZAINAB, FAM_FATIMA, FAM_FATHER]:
		if file_exists(p):
			fam_found += 1
	var aud_found := 0
	for p: String in [AUD_SEA_AMB, AUD_THEME, AUD_SEAGULL, AUD_PICKUP, AUD_CHECKPOINT, AUD_RETRY]:
		if file_exists(p):
			aud_found += 1
	return {
		"jomana_run":  {"found": run_found,  "total": JOMANA_RUN_COUNT},
		"jomana_idle": {"found": idle_found, "total": JOMANA_IDLE_COUNT},
		"backgrounds": {"found": bg_found,   "total": 5},
		"obstacles":   {"found": obs_found,  "total": 4},
		"family":      {"found": fam_found,  "total": 4},
		"audio":       {"found": aud_found,  "total": 6},
	}


static func print_asset_status() -> void:
	var data := get_available_assets()
	print("\n╔══════════════════════════════════════╗")
	print("║  LEVEL 2 ASSET STATUS                ║")
	print("╠══════════════════════════════════════╣")
	for key: String in data:
		var d: Dictionary = data[key]
		var found: int = d["found"]
		var total: int = d["total"]
		var ok := "✅" if found == total else ("⚠️ " if found > 0 else "⬜")
		print("║  %s  %-16s  %d/%d" % [ok, key, found, total])
	print("╚══════════════════════════════════════╝\n")
