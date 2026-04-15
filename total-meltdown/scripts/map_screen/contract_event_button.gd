extends BaseEventButton
class_name ContractEventButton

func _on_pressed() -> void:
	map_screen.current_active_event_button = self
	if QuestManager.remaining_quests.size() > 0:
		map_screen.open_contract_screen()
	else:
		map_screen.close_event_button(self)
