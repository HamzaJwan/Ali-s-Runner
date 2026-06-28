class_name DialogueBubbleHelper
extends RefCounted

const ENCOUNTER_DATA := preload("res://scripts/story/encounter_data.gd")
const BUBBLE_SIZE := Vector2(480.0, 160.0)
const VERTICAL_OFFSET := 32.0
const VIEWPORT_MARGIN := 24.0
const VIEW_SIZE := Vector2(1152.0, 648.0)
const REWARD_BANNER_Y := 110.0


static func get_position(
		role: int,
		ali_visual_top: Vector2,
		helper_visual_top: Vector2
) -> Vector2:
	if role == ENCOUNTER_DATA.ROLE_REWARD:
		return _clamp_position(Vector2(
			(VIEW_SIZE.x - BUBBLE_SIZE.x) / 2.0,
			REWARD_BANNER_Y
		))

	var speaker_visual_top := ali_visual_top
	if role == ENCOUNTER_DATA.ROLE_HELPER:
		speaker_visual_top = helper_visual_top
	var position := Vector2(
		speaker_visual_top.x - BUBBLE_SIZE.x / 2.0,
		speaker_visual_top.y - BUBBLE_SIZE.y - VERTICAL_OFFSET
	)
	if position.y < VIEWPORT_MARGIN:
		# A top subtitle is safer than allowing the card to cover a face.
		position.y = VIEWPORT_MARGIN
	return _clamp_position(position)


static func _clamp_position(position: Vector2) -> Vector2:
	return Vector2(
		clampf(
			position.x,
			VIEWPORT_MARGIN,
			VIEW_SIZE.x - BUBBLE_SIZE.x - VIEWPORT_MARGIN
		),
		clampf(
			position.y,
			VIEWPORT_MARGIN,
			VIEW_SIZE.y - BUBBLE_SIZE.y - VIEWPORT_MARGIN
		)
	)
