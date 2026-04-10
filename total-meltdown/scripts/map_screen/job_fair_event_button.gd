extends EventButton
class_name JobFairEventButton

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	if DeveloperManager.remaining_developers.size() > 0:
		map_screen.open_job_fair_screen()
	else:
		map_screen.close_event_button(self)
