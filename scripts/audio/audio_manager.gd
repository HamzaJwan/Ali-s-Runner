class_name AudioManager
extends RefCounted

const SOUND_PATHS := {
	"button_click": "res://assets/audio/ui/button_click.wav",
	"dialogue_blip": "res://assets/audio/ui/dialogue_blip.wav",
	"jump": "res://assets/audio/player/jump.wav",
	"land": "res://assets/audio/player/land.wav",
	"hit": "res://assets/audio/gameplay/hit.wav",
	"checkpoint": "res://assets/audio/story/checkpoint.wav",
	"reward_star": "res://assets/audio/story/reward_star.wav",
	"reward_heart": "res://assets/audio/story/reward_heart.wav",
	"reward_key": "res://assets/audio/story/reward_key.wav",
	"game_over": "res://assets/audio/story/game_over.wav",
	"victory": "res://assets/audio/story/victory.wav",
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

const MUSIC_PATH := "res://assets/audio/music/main_theme_soft_loop.ogg"
const MUSIC_VOLUME_DB := -22.0
const MUSIC_DUCK_DB := -32.0
const MUSIC_FADE_TIME := 0.6

var _players: Dictionary = {}
var _missing_logged: Dictionary = {}
var _music_player: AudioStreamPlayer
var _music_loaded := false
var _music_volume_tween: Tween


func setup(parent_node: Node) -> void:
	for sound_name: String in SOUND_PATHS:
		_load_sound(parent_node, sound_name)
	_load_music(parent_node)


func _load_sound(parent_node: Node, sound_name: String) -> void:
	var path: String = SOUND_PATHS[sound_name]
	if not ResourceLoader.exists(path, &"AudioStream"):
		_log_missing_once(sound_name, path, "missing")
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


func _log_missing_once(sound_name: String, path: String, reason: String) -> void:
	if _missing_logged.get(sound_name, false):
		return
	_missing_logged[sound_name] = true
	print("[audio] ", reason, " (skipped, no crash): ", sound_name, " -> ", path)


func _load_music(parent_node: Node) -> void:
	if not ResourceLoader.exists(MUSIC_PATH, &"AudioStream"):
		_log_missing_once("music", MUSIC_PATH, "missing")
		return

	var stream := load(MUSIC_PATH) as AudioStream
	if stream == null:
		_log_missing_once("music", MUSIC_PATH, "failed to load")
		return

	# HUMAN_AUDIO_REVIEW_REQUIRED: license verified (CC0 1.0, OpenGameArt
	# "Icy Heights", see docs/AUDIO_CREDITS.md), but tone/loudness/fit have
	# not been approved by ear yet. Keep this flagged until that review.
	if stream is AudioStreamOggVorbis:
		stream.loop = true

	_music_player = AudioStreamPlayer.new()
	_music_player.stream = stream
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.bus = "Master"
	parent_node.add_child(_music_player)
	_music_loaded = true
	print("[audio] music loaded (HUMAN_AUDIO_REVIEW_REQUIRED): ", MUSIC_PATH,
		" volume_db=", MUSIC_VOLUME_DB, " loop=true")


func start_music() -> void:
	if not _music_loaded or _music_player == null:
		return
	if _music_player.playing:
		return
	_kill_music_tween()
	_music_player.volume_db = MUSIC_VOLUME_DB
	_music_player.play()


func stop_music() -> void:
	if not _music_loaded or _music_player == null:
		return
	_kill_music_tween()
	_music_player.stop()


func duck_music() -> void:
	if not _music_loaded or _music_player == null or not _music_player.playing:
		return
	_kill_music_tween()
	_music_volume_tween = _music_player.create_tween()
	_music_volume_tween.tween_property(
		_music_player, "volume_db", MUSIC_DUCK_DB, MUSIC_FADE_TIME
	)


func unduck_music() -> void:
	if not _music_loaded or _music_player == null or not _music_player.playing:
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
