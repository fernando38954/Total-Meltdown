extends BaseItemPanel
class_name DeveloperPanel

#region Abstract Override Functions
func get_items() -> Array:
	return DeveloperManager.all_developers

func _ready_prerequisites():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
#endregion

#region Override Functions
#endregion
