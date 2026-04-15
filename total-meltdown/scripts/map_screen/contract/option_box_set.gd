extends Node
class_name OptionBoxSet

@export var box_set: Array[OptionBox]

func _ready() -> void:
	for option_box in box_set:
		option_box.assign_box_set(self)

func check_set_duplication(target_option_box: OptionBox, new_box_data: Dictionary):
	for option_box in box_set:
		if option_box != target_option_box and option_box.box_data == new_box_data:
			switch_box_content(option_box, target_option_box)
			return

func switch_box_content(first_option_box: OptionBox, second_option_box: OptionBox):
	var temp_data = first_option_box.box_data
	first_option_box.box_data = second_option_box.box_data
	second_option_box.box_data = temp_data
	first_option_box.refresh_box_data()
	second_option_box.refresh_box_data()

func get_attribute_data() -> Dictionary:
	var result: Dictionary = {}
	for option_box in box_set:
		var attr = option_box.get_attribute_data()
		for key in attr:
			result[key] = result.get(key, 0.0) + attr[key]
	return result
