## level2_family_checkpoint_visuals.gd — Level 2 checkpoint NPC sprite loader.
## Loads family checkpoint PNG from the manifest and positions it on the NPC node.
## Falls back to placeholder emoji label if art is missing. Never crashes.
##
## Checkpoint order: Ali(15) → Zainab(35) → Fatima(60) → Father(90)
extends RefCounted

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")
const ASSET_UTILS := preload("res://scripts/asset_utils.gd")

## Heights enforce the real age hierarchy. Jomana (hero) is 160px.
## Father > Ali > Jomana > Zainab > Fatima (baby).
const NPC_VISUAL_HEIGHTS := {
	1: 192.0, # Ali    — older brother, clearly taller than Jomana (160)
	2: 115.0, # Zainab — younger, clearly shorter than Jomana
	3:  75.0, # Fatima — baby, obviously smallest
	4: 232.0, # Father — adult, tallest of all
}


## Apply art to encounter_npc_node for the given character_id.
## Adds a Sprite2D child; removes any previous one.
## Returns true if real art was applied; false = placeholder text stays.
func apply_npc_art(npc_node: Node2D, character_id: int, fallback_path := "") -> bool:
	if npc_node == null:
		return false

	# Remove previous art sprite if any.
	var old := npc_node.get_node_or_null("CheckpointArt")
	if old != null:
		old.queue_free()

	var tex := MANIFEST.get_family_checkpoint_texture(character_id)
	if tex == null and not fallback_path.is_empty():
		tex = ASSET_UTILS.load_texture_with_fallback(fallback_path)
	if tex == null:
		return false

	var sprite := Sprite2D.new()
	sprite.name = "CheckpointArt"
	sprite.texture = tex
	sprite.centered = true

	# Scale to visual height target.
	var visual_height: float = NPC_VISUAL_HEIGHTS.get(character_id, 130.0)
	var visible_rect := ASSET_UTILS.get_texture_visible_rect(tex)
	if visible_rect.size.y > 0.0:
		var s := visual_height / visible_rect.size.y
		sprite.scale = Vector2(s, s)
		# Align the non-transparent feet, not the source canvas, to y=0.
		var visible_center_x := visible_rect.position.x + visible_rect.size.x / 2.0
		var visible_bottom_y := visible_rect.position.y + visible_rect.size.y
		sprite.position.x = -(visible_center_x - float(tex.get_width()) / 2.0) * s
		sprite.position.y = -(visible_bottom_y - float(tex.get_height()) / 2.0) * s

	npc_node.add_child(sprite)
	print("[L2 story] character=%d art=%s height=%.0f" % [character_id, tex.resource_path, visual_height])
	return true


## Show optional family ending image at the ending node if art exists.
## ending_node: a Node2D positioned for the ending presentation.
## Returns true if the ending image was applied.
func apply_ending_art(ending_node: Node2D) -> bool:
	if ending_node == null:
		return false

	var old := ending_node.get_node_or_null("EndingArt")
	if old != null:
		old.queue_free()

	if not MANIFEST.file_exists(MANIFEST.FAM_ENDING):
		return false

	var tex := load(MANIFEST.FAM_ENDING) as Texture2D
	if tex == null:
		return false

	var sprite := Sprite2D.new()
	sprite.name = "EndingArt"
	sprite.texture = tex
	sprite.centered = true
	# Scale to half viewport width.
	var s := 576.0 / float(tex.get_width())
	sprite.scale = Vector2(s, s)
	ending_node.add_child(sprite)
	return true
