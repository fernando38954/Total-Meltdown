extends CanvasLayer
class_name Contract

signal rescale_animation_finished

@export_category("Drawing Board")
@export var drawing_board: Sprite2D
@export var drawing_board_show_position = Vector2(2029.0, 806.5)
@export var drawing_board_hide_position = Vector2(5100.0, 950.0)

@export_category("Post-It")
@export var post_it: Sprite2D
@export var post_it_show_position = Vector2(2015.0, 950.0)
@export var post_it_hide_position = Vector2(5100.0, 950.0)

@export_category("Quest Panel")
@export var quest_panel: Sprite2D
@export var quest_panel_show_position = Vector2(2015.0, 950.0)
@export var quest_panel_hide_position = Vector2(5100.0, 950.0)

var tween: Tween

func _ready():
	hide_panel(0)
	await get_tree().create_timer(1).timeout
	show_panel()

#region Panel Action
func move_panel_content(target_drawing_board_pos: Vector2, target_post_it_pos: Vector2, target_quest_panel_pos: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(drawing_board, "position", target_drawing_board_pos, duration)
	tween.tween_property(post_it, "position", target_post_it_pos, duration).set_delay(0.2)
	tween.tween_property(quest_panel, "position", target_quest_panel_pos, duration).set_delay(0.2)
	tween.tween_callback(rescale_animation_finished.emit)

func hide_panel(duration: float = 0.5):
	move_panel_content(drawing_board_hide_position, post_it_hide_position, quest_panel_hide_position, duration)

func show_panel(duration: float = 0.5):
	move_panel_content(drawing_board_show_position, post_it_show_position, quest_panel_show_position, duration)
#endregion
