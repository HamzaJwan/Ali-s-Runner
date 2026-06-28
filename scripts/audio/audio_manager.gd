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

var _players: Dictionary = {}
var _missing_logged: Dictionary = {}


func setup(parent_node: Node) -> void:
	for sound_name: String in SOUND_PATHS:
		_load_sound(parent_node, sound_name)


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
