extends CanvasLayer
class_name LogSavedPopup

@onready var confirmation_page = $ConfirmationPage
@onready var path_label = $ConfirmationPage/PathLabel

@export_category("SFX")
@export var open_SFX: AudioStream
@export var close_SFX: AudioStream

var tween: Tween

#region Animation
func rescale_panel(target_page_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.tween_property(confirmation_page, "scale", target_page_scale, duration)

func close_panel(duration: float = 0.5):
	AudioManager.play_sfx(close_SFX)
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	AudioManager.play_sfx(open_SFX)
	rescale_panel(Vector2.ONE, duration)

func close_popup(duration: float = 0.5):
	close_panel(duration)
	await tween.finished
	queue_free()
#endregion

func _ready() -> void:
	confirmation_page.scale = Vector2.ZERO
	if OS.get_name() != "Web":
		path_label.text = "Caminho: " + LoggerManager.get_log_path()
	else:
		path_label.text = "O arquivo já disponível para análise"
	open_panel()

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_popup()

func _on_return_button_pressed() -> void:
	close_popup()
