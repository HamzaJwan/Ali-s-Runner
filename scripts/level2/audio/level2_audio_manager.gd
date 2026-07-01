## level2_audio_manager.gd — Level 2 audio wrapper.
## Detects Level 2 audio files; plays them when present.
## Falls back to Level 1 audio or silence when missing.
## NEVER modifies the global Level 1 AudioManager.
##
## Public release blocker: any file without a docs/AUDIO_CREDITS.md entry is
## marked INTERNAL_TEST_ONLY and must NOT be distributed publicly.
extends Node

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

# Adjust these if needed for mixing with Level 1 audio.
const VOL_AMBIENCE  := -24.0   # dB — very quiet background
const VOL_THEME     := -20.0   # dB — calm music
const VOL_SEAGULL   := -18.0   # dB — occasional call
const VOL_PICKUP    := -12.0   # dB — clear feedback
const VOL_CHECKPOINT := -10.0  # dB — moment of attention
const SEAGULL_MIN_INTERVAL := 10.0
const SEAGULL_MAX_INTERVAL := 20.0

var _ambience_player: AudioStreamPlayer
var _theme_player: AudioStreamPlayer
var _seagull_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _seagull_timer: float = 0.0
var _seagull_next: float = 0.0
var _level1_audio_manager = null   # injected from playable controller

# Parent node reference for AudioStreamPlayer nodes.
var _parent: Node


func setup(parent: Node, level1_audio_manager) -> void:
	_parent = parent
	_level1_audio_manager = level1_audio_manager
	_seagull_next = randf_range(SEAGULL_MIN_INTERVAL, SEAGULL_MAX_INTERVAL)

	_ambience_player = _make_player("L2Ambience", VOL_AMBIENCE, true)
	_theme_player    = _make_player("L2Theme",    VOL_THEME, true)
	_seagull_player  = _make_player("L2Seagull",  VOL_SEAGULL, false)
	_sfx_player      = _make_player("L2SFX",      VOL_PICKUP, false)

	_try_start_ambience()
	_try_start_theme()


func _process(delta: float) -> void:
	# Occasional seagull calls.
	if _seagull_player == null or _seagull_player.stream == null:
		return
	_seagull_timer += delta
	if _seagull_timer >= _seagull_next:
		_seagull_timer = 0.0
		_seagull_next = randf_range(SEAGULL_MIN_INTERVAL, SEAGULL_MAX_INTERVAL)
		_seagull_player.play()


func play_pickup() -> void:
	if _sfx_player == null:
		return
	if _sfx_player.stream != null:
		_sfx_player.play()
	elif _level1_audio_manager != null and _level1_audio_manager.has_method("play_shard_pickup"):
		_level1_audio_manager.play_shard_pickup()


func play_checkpoint() -> void:
	if _sfx_player == null:
		return
	var chime := _load_stream(MANIFEST.get_audio_path("checkpoint"))
	if chime != null:
		_sfx_player.volume_db = VOL_CHECKPOINT
		_sfx_player.stream = chime
		_sfx_player.play()
	elif _level1_audio_manager != null and _level1_audio_manager.has_method("play_checkpoint"):
		_level1_audio_manager.play_checkpoint()


func stop_all() -> void:
	for p: AudioStreamPlayer in [_ambience_player, _theme_player, _seagull_player, _sfx_player]:
		if is_instance_valid(p) and p.playing:
			p.stop()


# ── Internal ──────────────────────────────────────────────────────────────

func _try_start_ambience() -> void:
	var stream := _load_stream(MANIFEST.get_audio_path("sea_ambience"))
	if stream != null:
		_ambience_player.stream = stream
		_ambience_player.play()
		print("[L2Audio] Sea ambience started — INTERNAL_TEST_ONLY until CC0 documented")


func _try_start_theme() -> void:
	var stream := _load_stream(MANIFEST.get_audio_path("theme"))
	if stream != null:
		_theme_player.stream = stream
		_theme_player.play()
		print("[L2Audio] Harbour theme started — INTERNAL_TEST_ONLY until CC0 documented")

	# Pre-load seagull stream.
	var gull := _load_stream(MANIFEST.get_audio_path("seagull"))
	if gull != null:
		_seagull_player.stream = gull


func _load_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	return load(path) as AudioStream


func _make_player(node_name: String, vol: float, looping: bool) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	p.volume_db = vol
	p.autoplay = false
	if _parent != null:
		_parent.add_child(p)
	return p
