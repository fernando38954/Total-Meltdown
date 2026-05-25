extends BaseItemPanel
class_name JobFairPanel

var recruitable_developers_list: Array = []

func set_recruitable_list(new_developer_list: Array):
	recruitable_developers_list = new_developer_list

func get_items() -> Array:
	return recruitable_developers_list

func open_detail_card(idx: int, initial_center: Vector2):
	if current_detail_card_instance:
		close_detail_card()
	
	open_click_blocker()
	var item = get_item(idx)
	current_detail_card_instance = detail_card_scene.instantiate()
	add_child(current_detail_card_instance)
	current_detail_card_instance.set_panel(self)
	current_detail_card_instance.initialize_card(initial_center, Vector2(1.3, 1.3))
	current_detail_card_instance.set_content(item)
	current_detail_card_instance.open_card()

func _ready_prerequisites():
	GlobalSignal.hire_developer.connect(_on_receive_hire_developer)
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame

func _on_receive_hire_developer(developer_key):
	DeveloperManager.hire_developer(recruitable_developers_list, developer_key)
	GlobalSignal.emit_signal("start_tutorial", "AfterHire")
	GlobalSignal.emit_signal("current_map_event_finished")
