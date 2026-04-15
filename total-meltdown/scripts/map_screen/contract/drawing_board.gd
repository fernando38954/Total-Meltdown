extends TextureRect
class_name DrawingBoard

@export var contract_screen: Contract

@export_category("Radar Chart")
@export var radar_chart: RadarChart
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

@export_category("Option Box")
@export var pattern_box: OptionBox
@export var developer_boxes: OptionBoxSet

func update_radar_chart():
	var base_attribute = pattern_box.get_attribute_data()
	var developer_attribute = developer_boxes.get_attribute_data()
	var final_attribute = multiply_dicts(base_attribute, developer_attribute)
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(base_attribute, final_attribute)

func multiply_dicts(dict_a: Dictionary, dict_b: Dictionary):
	var result = {}
	for key in dict_a:
		result[key] = dict_a[key] * dict_b.get(key, 0.0)
	return result


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		contract_screen.hide_selector_panel()
