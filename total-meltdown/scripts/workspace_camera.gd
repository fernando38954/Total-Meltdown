extends Camera2D

var default_zoom
var default_position
var tween: Tween

func _ready() -> void:
	default_zoom = zoom
	default_position = global_position

func zoom_to_point(target_global_position: Vector2, target_zoom: Vector2, duration: float = 0.3):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_global_position, duration)
	tween.tween_property(self, "zoom", target_zoom, duration)

func return_default_setting(duration: float = 0.3):
	zoom_to_point(default_position, default_zoom, duration)
