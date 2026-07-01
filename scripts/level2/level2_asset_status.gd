## level2_asset_status.gd
## Prints a one-time asset status report when Level 2 starts.
## Attach to the Level2MarsaPlayable scene or call from _ready().
## Only prints once; does not spam; does not crash.
extends Node

## Set false in production to suppress the report.
@export var enabled: bool = true


func _ready() -> void:
	if not enabled:
		return
	# Defer one frame so all loaders have run first.
	call_deferred("_print_report")


func _print_report() -> void:
	Level2AssetManifest.print_asset_status()
	var missing := Level2AssetManifest.get_missing_required_assets()
	if missing.size() > 0:
		push_warning(
			"[Level2] %d required asset(s) missing. Drop them and reimport. See docs/level2/LEVEL2_ASSET_DROP_GUIDE.md"
			% missing.size()
		)
