extends BaseScreen
class_name Contract

var actived_quest: Dictionary = {}

@export_category("Drawing Board")
@export var drawing_board: DrawingBoard
@export var drawing_board_show_position = Vector2(1005.0, 416.0)
@export var drawing_board_hide_position = Vector2(1005.0, -1390.5)

@export_category("Post-It")
@export var post_it: PostIt
@export var post_it_default_position = Vector2(2799.0, 518.0)
@export var post_it_show_scale = Vector2(1, 1)
@export var post_it_hide_scale = Vector2(2, 2)

@export_category("Quest Panel")
@export var quest_panel: QuestPanel
@export var quest_panel_show_position = Vector2(240, 500.0)
@export var quest_panel_hide_position = Vector2(-930.0, 500.0)

@export_category("Selector Panel")
@export var selector_panel: SelectorPanel
@export var selector_panel_show_position = Vector2(0, 0)
@export var selector_panel_hide_position = Vector2(0, 660)
var is_selector_panel_open: bool

func _ready():
	close_panel(0)
	#await get_tree().create_timer(1).timeout
	set_content(QuestManager.all_quests[0])
	#open_panel()

func set_content(quest_data: Dictionary):
	actived_quest = quest_data
	quest_panel.set_content(quest_data.title, quest_data.icon, quest_data.description)
	post_it.set_content(quest_data.bullet_point, quest_data.footnote)
	drawing_board.reset_content()

#region Panel Action
func move_panel_content(target_drawing_board_pos: Vector2, target_post_it_scale: Vector2, target_post_it_alpha: float, target_quest_panel_pos: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(drawing_board, "position", target_drawing_board_pos, duration)
	tween.tween_property(post_it, "scale", target_post_it_scale, duration/2).set_delay(duration/2)
	tween.tween_property(post_it, "modulate", Color(1,1,1,target_post_it_alpha), duration/2).set_delay(duration/2)
	tween.tween_property(quest_panel, "position", target_quest_panel_pos, duration).set_delay(duration/5)

func close_panel(duration: float = 0.5):
	is_selector_panel_open = false
	var temporaty_tween = create_tween()
	temporaty_tween.tween_property(selector_panel, "position", selector_panel_hide_position, duration)
	post_it.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_panel_content(drawing_board_hide_position, post_it_hide_scale, 0, quest_panel_hide_position, duration)

func open_panel(duration: float = 0.5):
	post_it.position = post_it_default_position
	post_it.mouse_filter = Control.MOUSE_FILTER_STOP
	move_panel_content(drawing_board_show_position, post_it_show_scale, 1, quest_panel_show_position, duration)
#endregion

#region Selector Panel Action
func translate_panels(direction: Vector2, duration: float = 0.3):
	if tween and tween.is_running():
		return
	
	is_selector_panel_open = not is_selector_panel_open
	tween = create_tween().set_parallel(true)
	tween.tween_property(selector_panel, "position", selector_panel.position + direction, duration)
	tween.tween_property(drawing_board, "position", drawing_board.position + direction/2, duration)
	tween.tween_property(post_it, "position", post_it.position + direction/2, duration)
	tween.tween_property(quest_panel, "position", quest_panel.position + direction/2, duration)

func open_selector_panel(option_type: OptionBox.OptionType, duration: float = 0.3):
	selector_panel.set_option_type(option_type)
	translate_panels(selector_panel_show_position - selector_panel_hide_position, duration)

func hide_selector_panel(duration: float = 0.3):
	if is_selector_panel_open:
		translate_panels(selector_panel_hide_position - selector_panel_show_position, duration)

func switch_selector_panel(option_type: OptionBox.OptionType, duration: float = 0.3):
	if tween and tween.is_running():
		return
	tween = create_tween()
	tween.tween_property(selector_panel, "position", selector_panel_hide_position, duration)
	tween.tween_callback(selector_panel.set_option_type.bind(option_type))
	tween.tween_property(selector_panel, "position", selector_panel_show_position, duration)

func toggle_selector_panel(option_type: OptionBox.OptionType):
	if is_selector_panel_open:
		if selector_panel.option_type != option_type:
			switch_selector_panel(option_type)
		else:
			hide_selector_panel()
	else:
		open_selector_panel(option_type)
#endregion


func _on_submit_button_pressed() -> void:
	QuestManager.complete_quest(actived_quest)
	GlobalSignal.emit_signal("current_map_event_finished")
