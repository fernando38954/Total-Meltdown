extends TextureProgressBar
class_name WorkProgressBar

var contract_key: String
var contract_data: ContractData = null
var claim_button: TextureButton

func _ready() -> void:
	value = 0
	GlobalSignal.timer_update.connect(update_status)

func set_contract(_contract_key, _claim_button):
	contract_key = _contract_key
	claim_button = _claim_button
	contract_data = ContractManager.get_contract_by_key(contract_key)
	update_status()

func update_status():
	if contract_data != null:
		value = contract_data.progress
		if value >= 100:
			claim_button.set_disabled(false)
