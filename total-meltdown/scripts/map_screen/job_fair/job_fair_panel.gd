extends BaseItemPanel
class_name JobFairPanel

func get_items() -> Array:
	return DeveloperManager.remaining_developers

func _ready_prerequisites():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
