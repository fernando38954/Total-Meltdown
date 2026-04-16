extends BaseItemPanel
class_name JobFairPanel

var recruitable_developers_list: Array = []

func set_recruitable_list(new_developer_list: Array):
	recruitable_developers_list = new_developer_list

func get_items() -> Array:
	return recruitable_developers_list

func _ready_prerequisites():
	GlobalSignal.hire_developer.connect(_on_receive_hire_developer)
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame

func _on_receive_hire_developer(dev_index):
	DeveloperManager.hire_developer(recruitable_developers_list, recruitable_developers_list[dev_index])
	GlobalSignal.emit_signal("current_map_event_finished")
