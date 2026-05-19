extends BaseItemPanel
class_name StudySessionPanel

var studiable_patterns_list: Array = []

func set_studiable_list(new_patterns_list: Array):
	studiable_patterns_list = new_patterns_list

func get_items() -> Array:
	return studiable_patterns_list

func open_detail_card(idx: int, initial_center: Vector2):
	if current_detail_card_instance:
		close_detail_card()
	
	open_click_blocker()
	var item = get_item(idx)
	current_detail_card_instance = detail_card_scene.instantiate()
	add_child(current_detail_card_instance)
	current_detail_card_instance.set_panel(self)
	current_detail_card_instance.initialize_card(initial_center, Vector2.ONE)
	current_detail_card_instance.set_content(item)
	current_detail_card_instance.open_card()

func _ready_prerequisites():
	GlobalSignal.study_pattern.connect(_on_receive_study_pattern)
	while !PatternManager.creation_finished:
		await get_tree().process_frame

func _on_receive_study_pattern(pattern_index):
	PatternManager.study_pattern(studiable_patterns_list, studiable_patterns_list[pattern_index])
	GlobalSignal.emit_signal("current_map_event_finished")
