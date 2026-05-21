extends TextureButton
class_name OptionBox

@onready var icon = $Icon
@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

@export var drawing_board: DrawingBoard
@export var option_type: OptionType

var box_key = null
var box_set: OptionBoxSet = null

enum OptionType{
	Pattern, Developer
}

#region Drag and Drop
func _can_drop_data(at_position: Vector2, data):
	if option_type == OptionType.Pattern:
		return data is PatternOptionOverviewCard
	elif option_type == OptionType.Developer:
		return data is DeveloperOptionOverviewCard
	return false

func _drop_data(at_position: Vector2, data):
	if box_set != null:
		box_set.check_set_duplication(self, data.stored_item_key)
	assign_box_key(data.stored_item_key)
#endregion

func assign_box_key(_box_key):
	box_key = _box_key
	refresh_box_data()

func reset_box_content():
	assign_box_key(null)

func assign_box_set(new_box_set: OptionBoxSet):
	box_set = new_box_set

func refresh_box_data():
	clear_box_display()
	drawing_board.update_content()
	if box_key == null:
		return
	var box_data = get_box_data()
	if option_type == OptionType.Pattern:
		icon.texture = box_data.icon
	elif option_type == OptionType.Developer:
		portrait.texture = box_data.portrait
		developer_name.text = box_data.name

func clear_box_display():
	icon.texture = null
	portrait.texture = null
	developer_name.text = ""

func get_box_key() -> String:
	return box_key if box_key != null else ""

func get_box_data() -> Dictionary:
	var box_data = {}
	if box_key != null:
		if option_type == OptionType.Pattern:
			box_data = PatternManager.get_pattern_by_key(box_key)
		elif option_type == OptionType.Developer:
			box_data = DeveloperManager.get_developer_by_key(box_key)
	return box_data

func get_attribute_data() -> Dictionary:
	var box_data = get_box_data()
	return box_data.get("attribute", {}) if box_data != null else {}

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not self.disabled:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing_board.contract_screen.toggle_selector_panel(option_type)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			box_key = null
			refresh_box_data()
