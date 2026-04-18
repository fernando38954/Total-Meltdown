@abstract
extends Panel
class_name BaseDetailCard

var panel: BaseItemPanel = null
var initial_center_position: Vector2
var tween: Tween

func set_panel(p_panel: BaseItemPanel):
	panel = p_panel

func initialize_card(target_center_position: Vector2) -> void:
	scale = Vector2.ZERO
	initial_center_position = target_center_position
	global_position = initial_center_position

@abstract func set_content(item_data: Variant)

#region Animation
func animate_to_center(target_center_position: Vector2, target_scale: Vector2, duration: float, callback: Callable = Callable()):
	if tween and tween.is_running():
		return
	var target_global_pos = target_center_position - size * 0.5 * target_scale * panel.scale
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "global_position", target_global_pos, duration)
	tween.tween_property(self, "scale", target_scale, duration)
	await tween.finished
	if callback.is_valid():
		callback.call()

func open_card(duration: float = 0.2, callback: Callable = Callable()):
	var center = panel.get_center_position()
	animate_to_center(center, Vector2(0.8, 0.8), duration, callback)

func close_card(duration: float = 0.2, callback: Callable = Callable()):
	animate_to_center(initial_center_position, Vector2.ZERO, duration, callback)
#endregion

func _on_return_button_pressed() -> void:
	close_card(0.2, Callable(panel, "close_detail_card"))
