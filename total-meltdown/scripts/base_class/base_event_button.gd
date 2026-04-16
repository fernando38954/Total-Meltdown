@abstract
extends TextureButton
class_name BaseEventButton

var map_screen: MapScreen
var target_scale

@abstract func initialize_data()

func initialize(p_position: Vector2, p_scale: float, p_map: MapScreen):
	position = p_position
	scale = Vector2.ZERO
	target_scale = p_scale * Vector2.ONE
	map_screen = p_map
	initialize_data()

func appear(duration: float = 0.3):
	var tween: Tween
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, duration)
