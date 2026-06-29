class_name AudioManager
extends RefCounted

const SOUND_PATHS := {
	"button_click": "res://assets/audio/ui/button_click.wav",
	"dialogue_blip": "res://assets/audio/ui/dialogue_blip.wav",
	"jump": "res://assets/audio/candidates/player/jump_option_1.wav",
	"land": "res://assets/audio/player/land.wav",
	"hit": "res://assets/audio/candidates/gameplay/hit_option_1.wav",
	"checkpoint": "res://assets/audio/story/checkpoint.wav",
	"reward_star": "res://assets/audio/story/reward_star.wav",
	"reward_heart": "res://assets/audio/story/reward_heart.wav",
	"reward_key": "res://assets/audio/story/reward_key.wav",
	"game_over": "res://assets/audio/story/game_over.wav",
	"victory": "res://assets/audio/story/victory.wav",
}

# Drop-in-replacement safety net: if a preferred SOUND_PATHS candidate is ever
# missing/renamed, _resolve_sound_path() falls back to the original documented
# sound instead of going silent. Swapping a sound later only ever means
# editing SOUND_PATHS (and SOUND_FALLBACK_PATHS if the old file should stay
# as the safety net) - no other code needs to change.
const SOUND_FALLBACK_PATHS := {
	"jump": "res://assets/audio/player/jump.wav",
	"hit": "res://assets/audio/gameplay/hit.wav",
}

const VOLUME_DB := {
	"button_click": -8.0,
	"dialogue_blip": -18.0,
	"jump": -12.0,
	"land": -12.0,
	"hit": -10.0,
	"checkpoint": -8.0,
	"reward_star": -8.0,
	"reward_heart": -8.0,
	"reward_key": -8.0,
	"game_over": -10.0,
	"victory": -8.0,
}

const MUSIC_CALM := "calm"
const MUSIC_GAMEPLAY := "gameplay"

# Only "calm" is wired to a real file. assets/audio/music/level1_exciting_loop.ogg
# exists on disk but has no source/license entry in docs/AUDIO_CREDITS.md
# (docs/AUDIO_DESIGN_PLAN.md explicitly flags it UNVERIFIED_AUDIO_CANDIDATE and
# says not to integrate it until license-verified and owner-approved by ear).
# BLOCKED_BY_AUDIO_DOCUMENTATION: do not add a "gameplay" entry here until that
# documentation exists - play_gameplay_music() safely falls back to calm music
# in the meantime, exactly like a missing-file fallback would.
const MUSIC_TRACK_PATHS := {
	MUSIC_CALM: "res://assets/audio/music/main_theme_soft_loop.ogg",
}
const MUSIC_VOLUME_DB := -22.0
const MUSIC_DUCK_DB := -32.0
const MUSIC_FADE_TIME := 0.6
const MUSIC_CROSSFADE_HALF_TIME := 0.35

var _players: Dictionary = {}
var _missing_logged: Dictionary = {}
var _music_player: AudioStreamPlayer
var _music_streams: Dictionary = {}
var _current_music_key := ""
var _music_volume_tween: Tween


func setup(parent_node: Node) -> void:
	for sound_name: String in SOUND_PATHS:
		_load_sound(parent_node, sound_name)
	_load_music(parent_node)


func _load_sound(parent_node: Node, sound_name: String) -> void:
	var path := _resolve_sound_path(sound_name)
	if path == "":
		_log_missing_once(sound_name, SOUND_PATHS[sound_name], "missing")
		return

	var stream := load(path) as AudioStream
	if stream == null:
		_log_missing_once(sound_name, path, "failed to load")
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = float(VOLUME_DB.get(sound_name, -10.0))
	player.bus = "Master"
	parent_node.add_child(player)
	_players[sound_name] = player
	print("[audio] loaded: ", sound_name, " -> ", path,
		" volume_db=", player.volume_db)


func _resolve_sound_path(sound_name: String) -> String:
	var preferred: String = SOUND_PATHS[sound_name]
	if ResourceLoader.exists(preferred, &"AudioStream"):
		return preferred

	var fallback: String = SOUND_FALLBACK_PATHS.get(sound_name, "")
	if fallback != "" and ResourceLoader.exists(fallback, &"AudioStream"):
		print("[audio] preferred sound missing for ", sound_name,
			"; using documented fallback -> ", fallback)
		return fallback

	return ""


func _log_missing_once(sound_name: String, path: String, reason: String) -> void:
	if _missing_logged.get(sound_name, false):
		return
	_missing_logged[sound_name] = true
	print("[audio] ", reason, " (skipped, no crash): ", sound_name, " -> ", path)


func _load_music(parent_node: Node) -> void:
	for key: String in MUSIC_TRACK_PATHS:
		var path: String = MUSIC_TRACK_PATHS[key]
		if not ResourceLoader.exists(path, &"AudioStream"):
			_log_missing_once("music_" + key, path, "missing")
			continue

		var stream := load(path) as AudioStream
		if stream == null:
			_log_missing_once("music_" + key, path, "failed to load")
			continue

		# HUMAN_AUDIO_REVIEW_REQUIRED: license verified (see docs/AUDIO_CREDITS.md),
		# but tone/loudness/fit have not been approved by ear yet for any track.
		if stream is AudioStreamOggVorbis:
			stream.loop = true

		_music_streams[key] = stream
		print("[audio] music track loaded (HUMAN_AUDIO_REVIEW_REQUIRED): ", key,
			" -> ", path, " loop=true")

	if _music_streams.is_empty():
		return

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.bus = "Master"
	parent_node.add_child(_music_player)


## Calm state: main menu, intro, checkpoint/story dialogue, Game Over, Father
## ending, any paused/non-running state.
func play_calm_music() -> void:
	_switch_music(MUSIC_CALM)


## Active-gameplay state. Falls back to calm music if the "gameplay" track is
## not registered (currently BLOCKED_BY_AUDIO_DOCUMENTATION) - this is
## intentional graceful degradation, not a bug, and logged once.
func play_gameplay_music() -> void:
	if _music_streams.has(MUSIC_GAMEPLAY):
		_switch_music(MUSIC_GAMEPLAY)
		return
	_log_missing_once(
		"music_" + MUSIC_GAMEPLAY,
		"res://assets/audio/music/level1_exciting_loop.ogg",
		"BLOCKED_BY_AUDIO_DOCUMENTATION (no AUDIO_CREDITS.md entry); using calm music"
	)
	_switch_music(MUSIC_CALM)


func _switch_music(key: String) -> void:
	if _music_player == null:
		return
	var stream: AudioStream = _music_streams.get(key)
	if stream == null:
		return
	if key == _current_music_key and _music_player.playing:
		return

	_kill_music_tween()
	if not _music_player.playing:
		_music_player.stream = stream
		_music_player.volume_db = MUSIC_VOLUME_DB
		_music_player.play()
		_current_music_key = key
		return

	# Already playing a different track: crossfade out, swap, fade back in.
	var next_stream := stream
	_music_volume_tween = _music_player.create_tween()
	_music_volume_tween.tween_property(
		_music_player, "volume_db", MUSIC_DUCK_DB, MUSIC_CROSSFADE_HALF_TIME
	)
	_music_volume_tween.tween_callback(func() -> void:
		_music_player.stream = next_stream
		_music_player.play()
	)
	_music_volume_tween.tween_property(
		_music_player, "volume_db", MUSIC_VOLUME_DB, MUSIC_CROSSFADE_HALF_TIME
	)
	_current_music_key = key


func stop_music() -> void:
	if _music_player == null:
		return
	_kill_music_tween()
	_music_player.stop()
	_current_music_key = ""


func duck_music() -> void:
	if _music_player == null or not _music_player.playing:
		return
	_kill_music_tween()
	_music_volume_tween = _music_player.create_tween()
	_music_volume_tween.tween_property(
		_music_player, "volume_db", MUSIC_DUCK_DB, MUSIC_FADE_TIME
	)


func unduck_music() -> void:
	if _music_player == null or not _music_player.playing:
		return
	_kill_music_tween()
	_music_volume_tween = _music_player.create_tween()
	_music_volume_tween.tween_property(
		_music_player, "volume_db", MUSIC_VOLUME_DB, MUSIC_FADE_TIME
	)


func _kill_music_tween() -> void:
	if _music_volume_tween != null and _music_volume_tween.is_valid():
		_music_volume_tween.kill()
	_music_volume_tween = null


func _play(sound_name: String) -> void:
	var player: AudioStreamPlayer = _players.get(sound_name)
	if player == null:
		return
	player.play()


func play_button_click() -> void:
	_play("button_click")


func play_dialogue_blip() -> void:
	_play("dialogue_blip")


func play_jump() -> void:
	_play("jump")


func play_land() -> void:
	_play("land")


func play_hit() -> void:
	_play("hit")


func play_checkpoint() -> void:
	_play("checkpoint")


func play_reward_star() -> void:
	_play("reward_star")


func play_reward_heart() -> void:
	_play("reward_heart")


func play_reward_key() -> void:
	_play("reward_key")


func play_game_over() -> void:
	_play("game_over")


func play_victory() -> void:
	_play("victory")
