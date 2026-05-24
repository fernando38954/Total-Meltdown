extends BaseEventButton
class_name JobFairEventButton

var recruitable_developers_list: Array = []

func initialize_data():
	recruitable_developers_list = DeveloperManager.prepare_random_developers()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_job_fair_screen(recruitable_developers_list)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			map_screen.current_active_event_button = self
			map_screen.open_job_fair_screen(recruitable_developers_list)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			map_screen.close_event_button(self)
