extends TextureRect
class_name PostIt

@export var contract_screen: Contract

@onready var bullet_points = $BulletPoints
@onready var footnote = $Footnote

func set_content(bullet_list: Dictionary, footnote_text: String):
	bullet_points.text = "[ul]\n"
	for value in bullet_list.values():
		bullet_points.text += value + "\n"
	bullet_points.text += "[/ul]"
	
	footnote.text = footnote_text

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		contract_screen.hide_selector_panel()
