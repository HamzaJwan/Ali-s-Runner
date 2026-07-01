## level2_family_checkpoint_visuals.gd — Level 2 checkpoint NPC sprite loader.
## Loads family checkpoint PNG from the manifest and positions it on the NPC node.
## Falls back to placeholder emoji label if art is missing. Never crashes.
##
## Checkpoint order: Ali(15) → Zainab(35) → Fatima(60) → Father(90)
extends RefCounted

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

const NPC_VISUAL_HEIGHT := 90.0   # target height for checkpoint NPC on screen


## Apply art to encounter_npc_node for the given character_id.
## Adds a Sprite2D child; removes any previous one.
## Returns true if real art was applied; false = placeholder text stays.
func apply_npc_art(npc_node: Node2D, character_id: int) -> bool:
	if npc_node == null:
		return false

	# Remove previous art sprite if any.
	var old := npc_node.get_node_or_null("CheckpointArt")
	if old != null:
		old.queue_free()

	var tex := MANIFEST.get_family_checkpoint_texture(character_id)
	if tex == null:
		return false

	var sprite := Sprite2D.new()
	sprite.name = "CheckpointArt"
	sprite.texture = tex
	sprite.centered = true

	# Scale to visual height target.
	var raw_h := float(tex.get_height())
	if raw_h > 0.0:
		var s := NPC_VISUAL_HEIGHT / raw_h
		sprite.scale = Vector2(s, s)
		# Align bottom to y=0 on the npc node (feet on pier).
		sprite.position.y = -(NPC_VISUAL_HEIGHT / 2.0)

	npc_node.add_child(sprite)
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
