extends BaseItemPanel
class_name DeveloperPanel

func get_items() -> Array:
	return DeveloperManager.owned_developers

func _ready_prerequisites():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
