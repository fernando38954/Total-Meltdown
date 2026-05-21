extends TextureProgressBar
class_name ContractProgressBar

var map_screen: MapScreen
var contract_key: String
var contract_data: ContractData = null

@onready var icon = $ContractIcon
@onready var claimable_mark = $ClaimableMark

func _ready() -> void:
	value = 0
	claimable_mark.hide()
	GlobalSignal.timer_update.connect(update_status)

func set_map_screen(_map_screen):
	map_screen = _map_screen

func set_contract(_contract_key):
	contract_key = _contract_key
	contract_data = ContractManager.get_contract_by_key(contract_key)
	icon.texture = QuestManager.get_quest_by_key(contract_data.quest_key).icon

func mark_claimable():
	claimable_mark.show()

func update_status():
	if contract_data != null:
		value = contract_data.progress

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		map_screen.open_contract_screen(contract_key, true)
