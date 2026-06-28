extends CanvasLayer
class_name ExitPopup

@onready var exit_page = $ExitPage

@export_category("SFX")
@export var exit_open_SFX: AudioStream
@export var exit_close_SFX: AudioStream

var tween: Tween

#region Animation
func rescale_panel(target_exit_page_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.tween_property(exit_page, "scale", target_exit_page_scale, duration)

func close_panel(duration: float = 0.5):
	AudioManager.play_sfx(exit_close_SFX)
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	AudioManager.play_sfx(exit_open_SFX)
	rescale_panel(Vector2.ONE, duration)

func close_popup(duration: float = 0.5):
	close_panel()
	await tween.finished
	queue_free()
#endregion

func _ready() -> void:
	exit_page.scale = Vector2.ZERO
	open_panel()

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_popup()

func _on_no_button_pressed() -> void:
	close_popup()

func _on_yes_button_pressed() -> void:
	close_panel()
	AudioManager.stop_bgm()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")
	await Fade.fade_in().finished
	queue_free()
