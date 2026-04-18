extends TextureRect
class_name OptionBox

@onready var icon = $Icon
@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

@export var drawing_board: DrawingBoard
@export var option_type: OptionType

var box_data = null
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
		box_set.check_set_duplication(self, data.stored_item_data)
	box_data = data.stored_item_data
	refresh_box_data()
#endregion

func reset_box_content():
	box_data = null
	refresh_box_data()

func assign_box_set(new_box_set: OptionBoxSet):
	box_set = new_box_set

func refresh_box_data():
	clear_box_display()
	drawing_board.update_radar_chart()
	if box_data == null:
		return
	if option_type == OptionType.Pattern:
		icon.texture = box_data.icon
	elif option_type == OptionType.Developer:
		portrait.texture = box_data.portrait
		developer_name.text = box_data.name

func clear_box_display():
	icon.texture = null
	portrait.texture = null
	developer_name.text = ""

func get_box_item_data() -> Dictionary:
	return box_data if box_data != null else {}

func get_attribute_data() -> Dictionary:
	return box_data.attribute if box_data != null else {}

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing_board.contract_screen.toggle_selector_panel(option_type)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			box_data = null
			refresh_box_data()
