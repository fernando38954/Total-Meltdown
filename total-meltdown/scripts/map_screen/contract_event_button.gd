extends BaseEventButton
class_name ContractEventButton

var actived_quest: Dictionary = {}

func initialize_data():
	actived_quest = QuestManager.prepare_random_quest()

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	map_screen.open_contract_screen(actived_quest)
