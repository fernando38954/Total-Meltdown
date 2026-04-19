extends BaseItemPanel
class_name StudySessionPanel

var studiable_patterns_list: Array = []

func set_studiable_list(new_patterns_list: Array):
	studiable_patterns_list = new_patterns_list

func get_items() -> Array:
	return studiable_patterns_list

func _ready_prerequisites():
	GlobalSignal.study_pattern.connect(_on_receive_study_pattern)
	while !PatternManager.creation_finished:
		await get_tree().process_frame

func _on_receive_study_pattern(pattern_index):
	PatternManager.study_pattern(studiable_patterns_list, studiable_patterns_list[pattern_index])
	GlobalSignal.emit_signal("current_map_event_finished")
