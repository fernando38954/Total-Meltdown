extends BaseEventButton
class_name ContractEventButton

var actived_quest: String
@onready var countdown_progress = $CountdownProgress

func _ready() -> void:
	countdown_progress.value = 0
	GlobalSignal.timer_update.connect(update_countdown)

func initialize_data():
	actived_quest = QuestManager.prepare_random_quest()

func update_countdown():
	if GlobalResource.current_quarter >= 2:
		countdown_progress.value += 1
		if countdown_progress.value >= 100:
			map_screen.close_event_button(self)

func _on_pressed() -> void:
	AudioManager.play_sfx(click_event_SFX)
	GlobalSignal.emit_signal("start_tutorial", "Contract")
	map_screen.current_active_event_button = self
	map_screen.open_contract_screen(actived_quest)
