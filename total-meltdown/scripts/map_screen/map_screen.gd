extends Node2D
class_name MapScreen

@export var game_map: Sprite2D
@export var spawn_area: ColorRect
@export var event_button_list: Array[PackedScene] = []
@export var min_distance: float = 100.0
@export var spawn_interval: float = 1.0
@export var max_spawn_attempts: int = 50

var current_event_buttons: Array[EventButton] = []
var valid_region: Rect2
var button_size: Vector2
var button_pivot_offset: Vector2

func _ready() -> void:
	spawn_area.hide()
	initialize_parameters()
	
	while true: # Para teste
		await get_tree().create_timer(spawn_interval).timeout
		if current_event_buttons.size() < 3:
			create_event_button()

func initialize_parameters():
	valid_region = spawn_area.get_rect()
	
	var temp_button = event_button_list[0].instantiate()
	button_size = temp_button.texture_normal.get_size()
	button_pivot_offset = temp_button.get_pivot_offset()
	temp_button.queue_free()

func create_event_button():
	var rand_type = randi_range(0, event_button_list.size() - 1)
	var rand_scale = randf_range(0.5, 1.0)
	var rand_position = get_rand_position(rand_scale * Vector2.ONE)
	if rand_position == -1 * Vector2.ONE:
		return
	
	var button_instance = event_button_list[rand_type].instantiate()
	current_event_buttons.append(button_instance)
	button_instance.initialize(rand_position, rand_scale, self)
	add_child(button_instance)
	button_instance.appear()

func get_rand_position(button_scale: Vector2) -> Vector2:
	var magic_number = button_pivot_offset * (Vector2.ONE-button_scale)
	var scaled_size = button_size * button_scale
	var min_center = valid_region.position - magic_number
	var max_center = valid_region.position + valid_region.size - scaled_size - magic_number
	
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
	for button in current_event_buttons:
		if p_position.distance_to(button.position) < min_distance:
			return false
	return true

func delete_event_button(event_button: EventButton):
	current_event_buttons.erase(event_button)
	event_button.queue_free()
