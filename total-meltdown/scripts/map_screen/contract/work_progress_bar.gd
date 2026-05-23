extends TextureProgressBar
class_name WorkProgressBar

var contract_key: String
var contract_data: ContractData = null
var claim_button: TextureButton
var bug_event_button: TextureButton

func _ready() -> void:
	value = 0
	GlobalSignal.timer_update.connect(update_status)

func set_contract(_contract_key, _claim_button, _bug_event_button):
	contract_key = _contract_key
	claim_button = _claim_button
	bug_event_button = _bug_event_button
	contract_data = ContractManager.get_contract_by_key(contract_key)
	update_status()

func update_status():
	if contract_data != null:
		value = contract_data.progress
		bug_event_button.set_visible(contract_data.bug_active)
		bug_event_button.set_disabled(contract_data.bug_solve_tried)
		if value >= 100:
			claim_button.set_disabled(false)
