extends TextureRect
class_name DrawingBoard

@export var contract_screen: Contract

@export_category("Radar Chart")
@export var radar_chart: RadarChart
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18
var final_attribute: Dictionary = {}

@export_category("Option Box")
@export var pattern_box: OptionBox
@export var developer_boxes: OptionBoxSet

@export_category("Submit Button")
@export var submit_button: Button

func reset_content():
	pattern_box.reset_box_content()
	developer_boxes.reset_boxes_data()
	submit_button.disabled = true

func update_radar_chart():
	var base_attribute = pattern_box.get_attribute_data()
	var developer_attribute = developer_boxes.get_attribute_data()
	final_attribute = multiply_dicts(base_attribute, developer_attribute)
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(base_attribute, final_attribute)
	submit_button.set_disabled(final_attribute.is_empty())

func multiply_dicts(dict_a: Dictionary, dict_b: Dictionary):
	if dict_a.is_empty() or dict_b.is_empty(): return {}
	var result = {}
	for key in dict_a:
		result[key] = dict_a[key] * dict_b.get(key, 0.0)
	return result

func get_pattern_data() -> Dictionary:
	return pattern_box.get_box_item_data()

func get_developer_data_list() -> Array:
	return developer_boxes.get_developer_data_list()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		contract_screen.hide_selector_panel()
