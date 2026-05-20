extends BaseEventButton
class_name JobFairEventButton

var recruitable_developers_list: Array = []

func initialize_data():
	recruitable_developers_list = DeveloperManager.prepare_random_developers()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_job_fair_screen(recruitable_developers_list)
