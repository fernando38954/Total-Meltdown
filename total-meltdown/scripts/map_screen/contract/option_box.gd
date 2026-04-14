extends TextureRect
class_name OptionBox

@onready var icon = $Icon

func _can_drop_data(at_position: Vector2, data):
	return true

func _drop_data(at_position: Vector2, data):
	icon.texture = data.icon.texture
