extends Node2D
class_name MapScreen

@export var game_map: Sprite2D
@export var spawn_area: ColorRect
@export var event_button_list: Array[PackedScene] = []
@export var min_distance: float = 1000.0
@export var spawn_interval: float = 1.0
@export var max_spawn_attempts: int = 50

@export_category("Event Screen")
@export var click_blocker: ColorRect
@export var event_blocker: ColorRect
@export var job_fair_screen: JobFairScreen
@export var study_session_screen: StudySessionScreen

var current_event_button_list: Array[EventButton] = []
var current_active_event_button: EventButton = null
var current_active_screen: BaseScreen
var valid_region: Rect2
var button_size: Vector2
var button_pivot_offset: Vector2

func _ready() -> void:
	spawn_area.color = Color.TRANSPARENT
	initialize_parameters()
	close_click_blocker()
	GlobalSignal.hire_developer.connect(_on_receive_hire_developer)
	GlobalSignal.study_chapter.connect(_on_receive_study_chapter)
	
	while true: # Para teste
		await get_tree().create_timer(spawn_interval).timeout
		if current_event_button_list.size() < 3:
			create_event_button()

func initialize_parameters():
	valid_region = spawn_area.get_rect()
	
	var temp_button = event_button_list[0].instantiate()
	button_size = temp_button.texture_normal.get_size()
	button_pivot_offset = temp_button.get_pivot_offset()
	temp_button.queue_free()

#region Event Button
func create_event_button():
	var rand_type = get_rand_type()
	if rand_type == -1:
		return
	var rand_scale = randf_range(0.5, 1.0)
	var rand_position = get_rand_position(rand_scale * Vector2.ONE)
	if rand_position == -1 * Vector2.ONE:
		return
	
	var button_instance = event_button_list[rand_type].instantiate()
	current_event_button_list.append(button_instance)
	button_instance.initialize(rand_position, rand_scale, self)
	spawn_area.add_child(button_instance)
	button_instance.appear()

func get_rand_type() -> int:
	var rand_type = randi_range(0, event_button_list.size() - 1)
	for i in range(3):
		var idx = (rand_type + i) % 3
		var button_type = event_button_list[idx].get_state().get_node_name(0)
		if button_type == "JobFairEventButton" and DeveloperManager.remaining_developers.size() > 0:
			return idx
		elif button_type == "StudySessionEventButton" and SwebokManager.remaining_chapters.size() > 0:
			return idx
		elif button_type == "ContractEventButton":
			return idx
	return -1

func get_rand_position(button_scale: Vector2) -> Vector2:
	var pivot_offset_scale_fix = button_pivot_offset * (Vector2.ONE-button_scale)
	var scaled_size = button_size * button_scale
	var min_center = - pivot_offset_scale_fix
	var max_center = valid_region.size - scaled_size - pivot_offset_scale_fix
	
	if min_center.x > max_center.x or min_center.y > max_center.y:
		push_error("Invalid spawn region: It`s too small!")
		return -1 * Vector2i.ONE
	
	var attempts = 0
	while attempts < max_spawn_attempts:
		var candidate = Vector2i(
			randi_range(min_center.x, max_center.x),
			randi_range(min_center.y, max_center.y)
		)
		if check_position_validity(candidate):
			return candidate
		attempts += 1
	
	return -1 * Vector2i.ONE

func check_position_validity(p_position: Vector2) -> bool:
	for button in current_event_button_list:
		if p_position.distance_to(button.position) < min_distance:
			return false
	return true

func close_event_button(event_button: EventButton):
	current_event_button_list.erase(event_button)
	event_button.queue_free()
	current_active_event_button = null
#endregion

#region Event Screen
func open_click_blocker():
	click_blocker.show()

func close_click_blocker():
	click_blocker.hide()

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_event_screen(current_active_screen)
		current_active_event_button = null
		close_click_blocker()

func enable_event_blocker():
	event_blocker.show()

func disable_event_blocker():
	event_blocker.hide()

func close_event_screen(event_screen: BaseScreen = current_active_screen):
	if event_screen != null:
		event_screen.close_panel()
	current_active_screen = null
	close_click_blocker()

func open_job_fair_screen():
	open_click_blocker()
	job_fair_screen.open_panel()
	current_active_screen = job_fair_screen

func open_study_session_screen():
	open_click_blocker()
	study_session_screen.open_panel()
	current_active_screen = study_session_screen

func finish_current_event():
	close_event_button(current_active_event_button)
	close_event_screen(current_active_screen)

func _on_receive_hire_developer(developer_file_name):
	DeveloperManager.hire_developer(developer_file_name)
	finish_current_event()

func _on_receive_study_chapter(chapter_file_name):
	SwebokManager.study_chapter(chapter_file_name)
	finish_current_event()
#endregion
