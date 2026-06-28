extends CanvasLayer
class_name ConfigPopup

@onready var config_page = $ConfigPage

@export_category("Slider")
@export var volume_slider: Slider
@export var typing_speed_slider: Slider

@export_category("SFX")
@export var config_open_SFX: AudioStream
@export var config_close_SFX: AudioStream

@export_category("Tester")
@export var SFX_tester: AudioStream
@export var text_tester: AutoTypingRichTextLabel

var tween: Tween

#region Animation
func rescale_panel(target_config_page_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween().set_parallel()
	tween.tween_property(config_page, "scale", target_config_page_scale, duration)

func close_panel(duration: float = 0.5):
	AudioManager.play_sfx(config_close_SFX)
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	AudioManager.play_sfx(config_open_SFX)
	rescale_panel(Vector2.ONE, duration)

func close_popup(duration: float = 0.5):
	close_panel()
	await tween.finished
	queue_free()
#endregion

func _ready() -> void:
	config_page.scale = Vector2.ZERO
	volume_slider.value = GlobalResource.volume_level
	typing_speed_slider.value = GlobalResource.typing_speed_level
	open_panel()

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	GlobalResource.update_volume_level(volume_slider.value)
	await get_tree().process_frame
	AudioManager.play_sfx(SFX_tester)

func _on_typing_speed_slider_drag_ended(value_changed: bool) -> void:
	GlobalResource.update_typing_speed_level(typing_speed_slider.value)
	await get_tree().process_frame
	text_tester.skip_typing(false)
	await get_tree().process_frame
	text_tester.start_typing()

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_popup()

func _on_return_button_pressed() -> void:
	close_popup()
