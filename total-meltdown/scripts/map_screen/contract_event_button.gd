extends EventButton
class_name ContractEventButton

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.close_event_button(self)
