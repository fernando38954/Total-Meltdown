extends TextureRect
class_name QuestPanel

@export var contract_screen: Contract

@onready var title = $Title
@onready var icon = $Icon
@onready var description = $Description

func set_content(title_text: String, icon_sprite: Texture2D, description_list: Dictionary):
	title.text = title_text
	icon.texture = icon_sprite
	var paragraphs = []
	for value in description_list.values():
		paragraphs.append(value)
	description.text = "\n\n".join(paragraphs)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		contract_screen.hide_selector_panel()
