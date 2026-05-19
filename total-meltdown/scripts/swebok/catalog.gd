extends Control
class_name Catalog

@export var swebok: Swebok = null
var marker_list: Array

@export_category("Marker")
@export var home_mark: TextureButton
@export var attribute_container: Control
@export var pattern_container: Container

func _ready():
	while !PatternManager.creation_finished or !TutorialPageManager.creation_finished:
		await get_tree().process_frame
	initialize()

func initialize():
	var non_attribute_tutorial_page_key_list = TutorialPageManager.get_non_attribute_tutorial_page_key()
	marker_list.append(home_mark)
	home_mark.set_meta("key", non_attribute_tutorial_page_key_list[0])
	home_mark.set_meta("available", true)
	home_mark.pressed.connect(_on_page_selected.bind(0))
	for non_attribute_tutorial_key in non_attribute_tutorial_page_key_list.slice(1):
		var auxiliary_page = Object.new()
		auxiliary_page.set_meta("key", non_attribute_tutorial_key)
		auxiliary_page.set_meta("available", true)
		marker_list.append(auxiliary_page)
	for attribute_marker in attribute_container.get_children():
		marker_list.append(attribute_marker)
		attribute_marker.set_meta("key", attribute_marker.name)
		attribute_marker.set_meta("available", true)
		attribute_marker.pressed.connect(_on_page_selected.bind(marker_list.size() - 1))
	for pattern_marker in pattern_container.get_children():
		marker_list.append(pattern_marker)
		pattern_marker.set_meta("key", pattern_marker.name)
		pattern_marker.set_meta("available", false)
		pattern_marker.pressed.connect(_on_page_selected.bind(marker_list.size() - 1))

func update_catalog():
	for pattern_marker in pattern_container.get_children():
		if PatternManager.owned_patterns.has(pattern_marker.name):
			pattern_marker.show()
			pattern_marker.set_meta("available", true)
		else:
			pattern_marker.hide()
			pattern_marker.set_meta("available", false)

func get_previous_available_marker(current_idx: int) -> int:
	for idx in range(current_idx - 1, -1, -1):
		if marker_list[idx].get_meta("available", false):
			return idx
	return -1

func get_next_available_marker(current_idx: int) -> int:
	for idx in range(current_idx+1, marker_list.size()):
		if marker_list[idx].get_meta("available", false):
			return idx
	return -1

func _on_page_selected(idx: int):
	swebok.turn_to_page(idx)
