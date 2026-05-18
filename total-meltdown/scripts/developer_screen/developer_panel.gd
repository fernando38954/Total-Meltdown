extends BaseItemPanel
class_name DeveloperPanel

@export var event_blocker: ColorRect

#region Abstract Override Functions
func get_items() -> Array:
	return DeveloperManager.all_developers

func _ready_prerequisites():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
#endregion

func close_current_detail_card():
	if current_detail_card_instance != null:
		current_detail_card_instance.close_card(0.2, Callable(self, "close_detail_card"))

func enable_event_blocker():
	event_blocker.show()

func disable_event_blocker():
	event_blocker.hide()
