extends Area2D

@export var focus: Marker2D   # posição global predeterminada do zoom
@export var zoom_level: float = 2.0
@export var duration: float = 0.3

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var camera = get_viewport().get_camera_2d()
		if camera and camera.has_method("zoom_para_ponto"):
			camera.zoom_para_ponto(focus.global_position, zoom_level, duration)
