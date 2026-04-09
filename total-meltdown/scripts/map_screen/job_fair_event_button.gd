extends EventButton

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_job_fair_screen()
