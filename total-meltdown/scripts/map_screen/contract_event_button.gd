extends BaseEventButton
class_name ContractEventButton

var actived_quest: String

func initialize_data():
	actived_quest = QuestManager.prepare_random_quest()

func _on_pressed() -> void:
	GlobalSignal.emit_signal("start_tutorial", "Contract")
	map_screen.current_active_event_button = self
	map_screen.open_contract_screen(actived_quest)
