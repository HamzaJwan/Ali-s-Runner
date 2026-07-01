## level2_audio_manager.gd — Level 2 Marsa soundscape.
## All audio local to Level 2. Never modifies Level 1 AudioManager.
## Missing files never crash — push_warning once, then silence.
extends Node

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

const SEA_VOLUME_DB        := -24.0
const MUSIC_VOLUME_DB      := -20.0
const SEAGULL_VOLUME_DB    := -18.0
const PICKUP_VOLUME_DB     := -12.0
const CHECKPOINT_VOLUME_DB := -10.0
const RETRY_VOLUME_DB      := -14.0
const JUMP_VOLUME_DB       := -14.0
const FOOTSTEP_VOLUME_DB   := -22.0

const SEAGULL_MIN_SEC := 12.0
const SEAGULL_MAX_SEC := 25.0

var _ambience:   AudioStreamPlayer
var _theme:      AudioStreamPlayer
var _seagull:    AudioStreamPlayer
var _sfx:        AudioStreamPlayer
var _jump:       AudioStreamPlayer

var _seagull_timer: float = 0.0
var _seagull_next:  float = 0.0
var _warned: Dictionary = {}          # keys of warnings already pushed once
var _level1_audio = null              # injected Level 1 audio manager (fallback)


func setup(parent: Node, level1_audio_manager = null) -> void:
	_level1_audio = level1_audio_manager
	_seagull_next = randf_range(SEAGULL_MIN_SEC, SEAGULL_MAX_SEC)

	_ambience = _make_player(parent, "L2Ambience", SEA_VOLUME_DB, true)
	_theme    = _make_player(parent, "L2Theme",    MUSIC_VOLUME_DB, true)
	_seagull  = _make_player(parent, "L2Seagull",  SEAGULL_VOLUME_DB, false)
	_sfx      = _make_player(parent, "L2SFX",      PICKUP_VOLUME_DB, false)
	_jump     = _make_player(parent, "L2Jump",     JUMP_VOLUME_DB, false)

	_load_stream_to(_ambience, "sea_ambience", looping=true)
	_load_stream_to(_seagull, "seagull")
	# Theme and jump streams pre-loaded but not played yet.
	_load_stream_to(_theme, "theme", looping=true)
	_load_stream_to(_jump, "jump")

	_print_status()
	# Sea ambience starts softly on Level 2 open (menu + gameplay).
	if is_instance_valid(_ambience) and _ambience.stream != null:
		_ambience.play()


func _process(delta: float) -> void:
	if not is_instance_valid(_seagull) or _seagull.stream == null:
		return
	_seagull_timer += delta
	if _seagull_timer >= _seagull_next:
		_seagull_timer = 0.0
		_seagull_next  = randf_range(SEAGULL_MIN_SEC, SEAGULL_MAX_SEC)
		if not _seagull.playing:
			_seagull.play()


# ── Public events ─────────────────────────────────────────────────────────

func play_gameplay_music() -> void:
	if is_instance_valid(_theme) and _theme.stream != null and not _theme.playing:
		_theme.play()


func play_pickup() -> void:
	_play_sfx("pickup", PICKUP_VOLUME_DB)


func play_checkpoint() -> void:
	_play_sfx("checkpoint", CHECKPOINT_VOLUME_DB)


func play_retry() -> void:
	_play_sfx("retry", RETRY_VOLUME_DB)


func play_jump() -> void:
	if is_instance_valid(_jump) and _jump.stream != null and not _jump.playing:
		_jump.play()


func stop_all() -> void:
	for p: AudioStreamPlayer in [_ambience, _theme, _seagull, _sfx, _jump]:
		if is_instance_valid(p) and p.playing:
			p.stop()


func fade_out_music(duration: float = 1.0) -> void:
	if is_instance_valid(_theme) and _theme.playing:
		var tw := _theme.create_tween()
		tw.tween_property(_theme, "volume_db", -80.0, duration)
		tw.tween_callback(_theme.stop)


# ── Internal helpers ──────────────────────────────────────────────────────

func _play_sfx(audio_id: String, vol: float) -> void:
	if not is_instance_valid(_sfx):
		return
	var path := MANIFEST.get_audio_path(audio_id)
	if path.is_empty():
		_warn_once(audio_id, "SFX not found: " + audio_id)
		if _level1_audio != null:
			_l1_fallback(audio_id)
		return
	var stream := load(path) as AudioStream
	if stream == null:
		_warn_once(audio_id, "Failed to load: " + path)
		return
	_sfx.volume_db = vol
	_sfx.stream = stream
	_sfx.play()


func _load_stream_to(player: AudioStreamPlayer, audio_id: String, looping: bool = false) -> void:
	if not is_instance_valid(player):
		return
	var path := MANIFEST.get_audio_path(audio_id)
	if path.is_empty():
		_warn_once(audio_id, "[L2Audio] Missing: " + audio_id)
		return
	var stream := load(path) as AudioStream
	if stream == null:
		_warn_once(audio_id, "[L2Audio] Cannot load: " + path)
		return
	if looping and stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	player.stream = stream


func _make_player(parent: Node, node_name: String, vol: float, _loop: bool) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	p.volume_db = vol
	p.autoplay = false
	parent.add_child(p)
	return p


func _l1_fallback(audio_id: String) -> void:
	if _level1_audio == null:
		return
	match audio_id:
		"pickup":     if _level1_audio.has_method("play_shard_pickup"): _level1_audio.play_shard_pickup()
		"checkpoint": if _level1_audio.has_method("play_checkpoint"):   _level1_audio.play_checkpoint()
		"retry":      if _level1_audio.has_method("play_game_over"):    _level1_audio.play_game_over()


func _warn_once(key: String, msg: String) -> void:
	if not _warned.has(key):
		push_warning(msg)
		_warned[key] = true


func _print_status() -> void:
	var checks := {
		"sea_ambience":  is_instance_valid(_ambience) and _ambience.stream != null,
		"theme":         is_instance_valid(_theme) and _theme.stream != null,
		"seagull":       is_instance_valid(_seagull) and _seagull.stream != null,
		"pickup":        not MANIFEST.get_audio_path("pickup").is_empty(),
		"checkpoint":    not MANIFEST.get_audio_path("checkpoint").is_empty(),
		"retry":         not MANIFEST.get_audio_path("retry").is_empty(),
		"jump":          is_instance_valid(_jump) and _jump.stream != null,
		"footstep":      not MANIFEST.get_audio_path("footstep").is_empty(),
	}
	print("\nLEVEL2_AUDIO status:")
	for k: String in checks:
		print("  %s  %s" % ["OK" if checks[k] else "--", k])
