extends CanvasLayer
class_name CreditPopup

@onready var credit_page = $CreditPage

@export_category("SFX")
@export var credit_open_SFX: AudioStream
@export var credit_close_SFX: AudioStream

var tween: Tween

#region Animation
func rescale_panel(target_credit_page_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.tween_property(credit_page, "scale", target_credit_page_scale, duration)

func close_panel(duration: float = 0.5):
	AudioManager.play_sfx(credit_close_SFX)
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	AudioManager.play_sfx(credit_open_SFX)
	rescale_panel(Vector2.ONE, duration)

func close_popup(duration: float = 0.5):
	close_panel()
	await tween.finished
	queue_free()
#endregion

func _ready() -> void:
	credit_page.scale = Vector2.ZERO
	open_panel()

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_popup()

func _on_return_button_pressed() -> void:
	close_popup()
