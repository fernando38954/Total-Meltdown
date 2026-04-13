extends BaseEventButton
class_name StudySessionEventButton

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	if SwebokManager.remaining_chapters.size() > 0:
		map_screen.open_study_session_screen()
	else:
		map_screen.close_event_button(self)
