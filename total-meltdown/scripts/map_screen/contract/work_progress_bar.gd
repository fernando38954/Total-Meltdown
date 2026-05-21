extends TextureProgressBar
class_name WorkProgressBar

var contract_key: String
var contract_data: ContractData = null

func _ready() -> void:
	value = 0
	GlobalSignal.timer_update.connect(update_status)

func set_contract(_contract_key):
	contract_key = _contract_key
	contract_data = ContractManager.get_contract_by_key(contract_key)
	update_status()

func update_status():
	if contract_data != null:
		value = contract_data.progress

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and value >= 100:
		ContractManager.claim_contract(contract_key)
		GlobalSignal.emit_signal("current_map_event_finished")
