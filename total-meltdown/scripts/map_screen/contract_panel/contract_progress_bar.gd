extends TextureProgressBar
class_name ContractProgressBar

var map_screen: MapScreen
var contract_key: String
var contract_data: ContractData = null

@onready var icon = $ContractIcon
@onready var bug_mark = $BugMark
@onready var claimable_mark = $ClaimableMark

var last_bug_active: bool = false
var bug_tween: Tween = null

#region Initialization
func _ready() -> void:
	value = 0
	bug_mark.hide()
	claimable_mark.hide()
	GlobalSignal.timer_update.connect(update_status)

func set_map_screen(_map_screen):
	map_screen = _map_screen

func set_contract(_contract_key):
	contract_key = _contract_key
	contract_data = ContractManager.get_contract_by_key(contract_key)
	icon.texture = QuestManager.get_quest_by_key(contract_data.quest_key).icon
	last_bug_active = false
	update_bug_mark_visual(false)
#endregion

#region Game Flow
func mark_claimable():
	claimable_mark.show()

func update_status():
	if contract_data != null:
		value = contract_data.progress
		if contract_data.bug_active != last_bug_active:
			last_bug_active = contract_data.bug_active
			update_bug_mark_visual(last_bug_active)

func update_bug_mark_visual(active: bool):
	if active:
		GlobalSignal.emit_signal("start_tutorial", "Bug")
		if bug_tween and bug_tween.is_running():
			bug_tween.kill()
		bug_tween = create_tween().set_loops()
		bug_mark.modulate.a = 0.0
		bug_mark.show()
		bug_tween.tween_property(bug_mark, "modulate:a", 0.2, 0.8)
		bug_tween.tween_property(bug_mark, "modulate:a", 0.8, 0.8)
	else:
		if bug_tween and bug_tween.is_running():
			bug_tween.kill()
		bug_tween = create_tween()
		bug_tween.tween_property(bug_mark, "modulate:a", 0.0, 0.3)
		bug_tween.tween_callback(bug_mark.hide)
#endregion

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		map_screen.open_contract_screen(contract_key, true)
