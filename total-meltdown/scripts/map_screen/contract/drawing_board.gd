extends TextureRect
class_name DrawingBoard

@export var contract_screen: Contract

@export_category("Radar Chart")
@export var radar_chart: RadarChart
@export var font = ThemeDB.fallback_font
var final_attribute: Dictionary = {}

@export_category("Option Box")
@export var pattern_box: OptionBox
@export var developer_boxes: OptionBoxSet

@export_category("Level Indicator")
@export var time_level: Container
@export var complexity_level: Container
@export var empty_level_indicator: Texture
@export var full_level_indicator: Texture

@export_category("Submit Button")
@export var submit_button: TextureButton
@export var progress_button: WorkProgressBar

func reset_content():
	radar_chart.reset_values()
	pattern_box.reset_box_content()
	developer_boxes.reset_boxes_data()
	submit_button.disabled = true

func set_content(content_key: String, view_only: bool = false):
	# Content
	if content_key in ContractManager.awaked_contracts:
		var contract_data = ContractManager.get_contract_by_key(content_key)
		pattern_box.assign_box_key(contract_data.pattern_key)
		for idx in range(0, developer_boxes.box_set.size()):
			if idx < contract_data.developers_key.size():
				developer_boxes.box_set[idx].assign_box_key(contract_data.developers_key[idx])
		progress_button.set_contract(content_key)
		update_content()
	
	# Visible
	pattern_box.set_disabled(view_only)
	for idx in range(0, developer_boxes.box_set.size()):
		developer_boxes.box_set[idx].set_disabled(view_only)
	submit_button.set_visible(not view_only)
	progress_button.set_visible(view_only)

func update_content():
	update_radar_chart()
	update_level_indicator()

func update_radar_chart():
	var base_attribute = pattern_box.get_attribute_data()
	var developer_attribute = developer_boxes.get_attribute_data()
	final_attribute = multiply_dicts(base_attribute, developer_attribute)
	radar_chart.set_label_font(font)
	radar_chart.set_attributes(base_attribute, final_attribute)
	submit_button.set_disabled(final_attribute.is_empty())

func update_level_indicator():
	for indicator in time_level.get_children():
		indicator.texture = empty_level_indicator
	for indicator in complexity_level.get_children():
		indicator.texture = empty_level_indicator
		
	var pattern_data = pattern_box.get_box_data()
	if not pattern_data.is_empty():
		time_level.get_children()[pattern_data.time_level - 1].texture = full_level_indicator
		complexity_level.get_children()[pattern_data.complexity_level - 1].texture = full_level_indicator

func multiply_dicts(dict_a: Dictionary, dict_b: Dictionary):
	if dict_a.is_empty() or dict_b.is_empty(): return {}
	var result = {}
	for key in dict_a:
		result[key] = dict_a[key] * dict_b.get(key, 0.0)
	return result

func get_pattern_key() -> String:
	return pattern_box.get_box_key()

func get_developer_key_list() -> Array:
	return developer_boxes.get_developer_key_list()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		contract_screen.hide_selector_panel()
