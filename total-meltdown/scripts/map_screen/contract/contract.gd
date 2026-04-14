extends CanvasLayer
class_name Contract

signal rescale_animation_finished

@export_category("Drawing Board")
@export var drawing_board: Sprite2D
@export var drawing_board_show_position = Vector2(2029.0, 806.5)
@export var drawing_board_hide_position = Vector2(2029.0, -700.5)

@export_category("Post-It")
@export var post_it: PostIt
@export var post_it_show_scale = Vector2(1, 1)
@export var post_it_hide_scale = Vector2(2, 2)

@export_category("Quest Panel")
@export var quest_panel: QuestPanel
@export var quest_panel_show_position = Vector2(690, 780.5)
@export var quest_panel_hide_position = Vector2(-480.0, 780.5)

var tween: Tween

func _ready():
	hide_panel(0)
	await get_tree().create_timer(1).timeout
	set_content(QuestManager.quests[0])
	show_panel()

func set_content(quest_data: Dictionary):
	quest_panel.set_content(quest_data.title, quest_data.icon, quest_data.description)
	post_it.set_content(quest_data.bullet_point, quest_data.footnote)

#region Panel Action
func move_panel_content(target_drawing_board_pos: Vector2, target_post_it_scale: Vector2, target_post_it_alpha: float, target_quest_panel_pos: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(drawing_board, "position", target_drawing_board_pos, duration)
	tween.tween_property(post_it, "scale", target_post_it_scale, duration/2).set_delay(duration/2)
	tween.tween_property(post_it, "modulate", Color(1,1,1,target_post_it_alpha), duration/2).set_delay(duration/2)
	tween.tween_property(quest_panel, "position", target_quest_panel_pos, duration).set_delay(duration/5)
	tween.tween_callback(rescale_animation_finished.emit)

func hide_panel(duration: float = 0.5):
	move_panel_content(drawing_board_hide_position, post_it_hide_scale, 0, quest_panel_hide_position, duration)

func show_panel(duration: float = 0.5):
	move_panel_content(drawing_board_show_position, post_it_show_scale, 1, quest_panel_show_position, duration)
#endregion
