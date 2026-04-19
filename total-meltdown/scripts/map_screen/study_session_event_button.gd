extends BaseEventButton
class_name StudySessionEventButton

var studiable_patterns_list: Array = []

func initialize_data():
	studiable_patterns_list = PatternManager.prepare_random_patterns()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_study_session_screen(studiable_patterns_list)
