class_name DifficultyManager
extends RefCounted

const ENCOUNTER_DATA := preload("res://scripts/story/encounter_data.gd")
const BASE_SPEED := 225.0
const POST_FATIMA_SPEED := 240.0
const POST_ZAINAB_SPEED := 255.0
const POST_JOMANA_SPEED := 270.0


static func get_speed_for_checkpoint(checkpoint_id: int) -> float:
	var checkpoint_config := ENCOUNTER_DATA.get_checkpoint(checkpoint_id)
	if checkpoint_config.is_empty():
		return BASE_SPEED
	return checkpoint_config["post_speed"]


static func get_chapter_for_speed(obstacle_speed: float) -> int:
	if obstacle_speed >= POST_JOMANA_SPEED:
		return 4
	if obstacle_speed >= POST_ZAINAB_SPEED:
		return 3
	if obstacle_speed >= POST_FATIMA_SPEED:
		return 2
	return 1
