extends BaseEventButton
class_name StudySessionEventButton

var studiable_chapters_list: Array = []

func initialize_data():
	studiable_chapters_list = SwebokManager.prepare_random_chapters()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_study_session_screen(studiable_chapters_list)
