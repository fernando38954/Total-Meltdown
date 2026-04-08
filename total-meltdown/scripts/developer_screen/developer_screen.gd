extends CanvasLayer
class_name DeveloperScreen

signal rescale_animation_finished

@onready var screen_sprite = null #$Sprite2D
@onready var developer_panel = $DeveloperPanel

var open_scale = Vector2(0.65, 0.65)
var hide_scale = Vector2(0, 0)
var tween: Tween

func _ready():
	close_panel(0)

#region Book Action
func rescale_panel(target_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(developer_panel, "scale", target_scale, duration)
	tween.tween_callback(rescale_animation_finished.emit)

func close_panel(duration: float = 0.5):
	rescale_panel(hide_scale, duration)

func open_panel(duration: float = 0.5):
	developer_panel.close_developer_detail()
	rescale_panel(open_scale, duration)
#endregion
