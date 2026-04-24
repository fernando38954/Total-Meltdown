extends CanvasLayer
class_name BaseScreen

signal rescale_animation_finished

@onready var screen_sprite = null #$Sprite2D
@export var panel: BaseItemPanel

var open_scale = Vector2(0.65, 0.65)
var hide_scale = Vector2(0, 0)
var tween: Tween

func _ready():
	close_panel(0)
	show()

#region Panel Action
func rescale_panel(target_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(panel, "scale", target_scale, duration)
	tween.tween_callback(rescale_animation_finished.emit)

func close_panel(duration: float = 0.5):
	rescale_panel(hide_scale, duration)

func open_panel(duration: float = 0.5):
	panel.close_detail_card()
	panel.build_panel()
	rescale_panel(open_scale, duration)
#endregion
