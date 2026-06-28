class_name EncounterController
extends RefCounted

const ENCOUNTER_DATA := preload("res://scripts/story/encounter_data.gd")
const ASSET_UTILS := preload("res://scripts/asset_utils.gd")

var character_id := ENCOUNTER_DATA.NONE
var config: Dictionary = {}
var dialogue_step_index := 0
var _triggered := {}


func reset_for_run(checkpoint_id: int) -> void:
	_triggered = {
		ENCOUNTER_DATA.FATIMA: checkpoint_id >= ENCOUNTER_DATA.FATIMA,
		ENCOUNTER_DATA.ZAINAB: checkpoint_id >= ENCOUNTER_DATA.ZAINAB,
		ENCOUNTER_DATA.JOMANA: checkpoint_id >= ENCOUNTER_DATA.JOMANA,
		ENCOUNTER_DATA.FATHER: false,
	}
	clear_active()


func get_pending_for_score(score: int) -> int:
	var candidate := ENCOUNTER_DATA.get_encounter_for_score(score)
	if candidate == ENCOUNTER_DATA.NONE or _triggered.get(candidate, false):
		return ENCOUNTER_DATA.NONE
	return candidate


func begin(next_character_id: int) -> bool:
	var next_config := ENCOUNTER_DATA.get_encounter(next_character_id)
	if next_config.is_empty():
		return false
	character_id = next_character_id
	config = next_config
	dialogue_step_index = 0
	_triggered[character_id] = true
	return true


func current_step() -> Dictionary:
	var steps: Array = config.get("dialogue_steps", [])
	if dialogue_step_index < 0 or dialogue_step_index >= steps.size():
		return {}
	return steps[dialogue_step_index]


func advance_dialogue() -> bool:
	if is_final_step():
		return false
	dialogue_step_index += 1
	return true


func is_final_step() -> bool:
	var steps: Array = config.get("dialogue_steps", [])
	return steps.is_empty() or dialogue_step_index >= steps.size() - 1


func speaker_name(role: int) -> String:
	match role:
		ENCOUNTER_DATA.ROLE_ALI:
			return "علي"
		ENCOUNTER_DATA.ROLE_REWARD:
			return "النظام"
		ENCOUNTER_DATA.ROLE_HELPER:
			return config.get("speaker_name", "")
	return ""


func apply_optional_character_texture(
		character: int,
		panel_texture: TextureRect,
		panel_placeholder: CanvasItem,
		npc_sprite: Sprite2D,
		npc_placeholder: CanvasItem
) -> bool:
	var character_config := ENCOUNTER_DATA.get_encounter(character)
	var texture := ASSET_UTILS.load_texture_with_fallback(
		character_config["asset_path"]
	)
	if texture == null:
		panel_texture.texture = null
		panel_texture.visible = false
		panel_placeholder.visible = true
		npc_sprite.texture = null
		npc_sprite.visible = false
		npc_placeholder.visible = true
		print("[checkpoint] character=", character,
			" helper missing; using placeholder")
		return false

	panel_texture.texture = texture
	panel_texture.visible = true
	panel_placeholder.visible = false
	npc_sprite.texture = texture
	npc_sprite.visible = true
	ASSET_UTILS.fit_sprite_visible_to_height(
		npc_sprite, character_config["visual_height"]
	)
	ASSET_UTILS.align_sprite_visible_bottom(npc_sprite, 0.0)
	npc_placeholder.visible = false
	print("[checkpoint] character=", character, " helper texture loaded")
	return true


func clear_active() -> void:
	character_id = ENCOUNTER_DATA.NONE
	config = {}
	dialogue_step_index = 0
