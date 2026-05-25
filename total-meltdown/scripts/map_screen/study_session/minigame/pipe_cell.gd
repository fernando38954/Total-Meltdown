extends TextureButton
class_name PipeCell

#region Constants
# Godot's coordinate system is the inverse of the row-and-column system
const DIR_UP = Vector2i(-1, 0)
const DIR_DOWN = Vector2i(1, 0)
const DIR_LEFT = Vector2i(0, -1)
const DIR_RIGHT = Vector2i(0, 1)

const connection_dict = {
	"O": {DIR_UP: false, DIR_DOWN: false, DIR_LEFT: false, DIR_RIGHT: false},
	"Q": {DIR_UP: true, DIR_DOWN: false, DIR_LEFT: false, DIR_RIGHT: false},
	"I": {DIR_UP: true, DIR_DOWN: true, DIR_LEFT: false, DIR_RIGHT: false},
	"L": {DIR_UP: true, DIR_DOWN: false, DIR_LEFT: false, DIR_RIGHT: true},
	"T": {DIR_UP: true, DIR_DOWN: false, DIR_LEFT: true, DIR_RIGHT: true},
	"+": {DIR_UP: true, DIR_DOWN: true, DIR_LEFT: true, DIR_RIGHT: true}
}

const appearance: Dictionary[String, ButtonAppearance] = {
	"O_inactive": preload("res://assets/resource/button_appearance/O_inactive.tres"),
	"Q_inactive": preload("res://assets/resource/button_appearance/Q_inactive.tres"),
	"I_inactive": preload("res://assets/resource/button_appearance/I_inactive.tres"),
	"L_inactive": preload("res://assets/resource/button_appearance/L_inactive.tres"),
	"T_inactive": preload("res://assets/resource/button_appearance/T_inactive.tres"),
	"+_inactive": preload("res://assets/resource/button_appearance/+_inactive.tres"),
	"O_active": preload("res://assets/resource/button_appearance/O_active.tres"),
	"Q_active": preload("res://assets/resource/button_appearance/Q_active.tres"),
	"I_active": preload("res://assets/resource/button_appearance/I_active.tres"),
	"L_active": preload("res://assets/resource/button_appearance/L_active.tres"),
	"T_active": preload("res://assets/resource/button_appearance/T_active.tres"),
	"+_active": preload("res://assets/resource/button_appearance/+_active.tres"),
}
#endregion

# Status
var connection: Dictionary
var pipe_type: String
var pipe_rotation_degree: int

# Appearance
var actived_sprite: ButtonAppearance
var inactived_sprite: ButtonAppearance
var is_actived: bool

@onready var pattern_description = $PatternDescription
@export var active_text_color: Color = Color(0.85, 0.85, 0.85)
@export var inactive_text_color: Color = Color(0.05, 0.16, 1)
var text_rotation_degree: int

@export_category("SFX")
@export var cell_rotate_SFX : AudioStream

# External
var pipe_game: PipeGame
var tween: Tween

#region Initialization
func _init():
	connection = get_base_connections("O")

func initialize():
	pattern_description.text = ""
	connection = get_base_connections(pipe_type)
	pipe_rotation_degree = 0
	text_rotation_degree = 0
	var actived_sprite_key = pipe_type + "_active"
	var inactived_sprite_key = pipe_type + "_inactive"
	actived_sprite = appearance[actived_sprite_key]
	inactived_sprite = appearance[inactived_sprite_key]
	set_active(false)

func random_initial_state():
	initialize()
	rotate(randi() % 4)
#endregion

#region Assign Functions
func assign_game(_pipe_game: PipeGame):
	pipe_game = _pipe_game

func set_description(description: String):
	pattern_description.text = description

func copy(target_cell: PipeCell):
	self.pipe_type = target_cell.pipe_type
	random_initial_state()
#endregion

#region Map Generation Functions
func get_base_connections(type: String) -> Dictionary:
	return connection_dict[type].duplicate()

func count_connection() -> int:
	var counter = 0
	for existence in connection.values():
		if existence:
			counter += 1
	return counter

func deduce_type():
	var connection_number = count_connection()
	match connection_number:
		1: pipe_type = "Q"
		2:
			if (connection[DIR_UP] and connection[DIR_DOWN]) or (connection[DIR_LEFT] and connection[DIR_RIGHT]):
				pipe_type = "I"
			else:
				pipe_type = "L"
		3: pipe_type = "T"
		4: pipe_type = "+"
		_: pipe_type = "O"
#endregion

#region Game flow
func set_texture():
	if is_actived:
		pattern_description.add_theme_color_override("default_color", active_text_color)
		texture_normal = actived_sprite.normal
		texture_pressed = actived_sprite.pressed
		texture_hover = actived_sprite.hover
	else:
		pattern_description.add_theme_color_override("default_color", inactive_text_color)
		texture_normal = inactived_sprite.normal
		texture_pressed = inactived_sprite.pressed
		texture_hover = inactived_sprite.hover

func set_active(status: bool):
	is_actived = status
	set_texture()

func rotate(rotation_number: int):
	if tween and tween.is_running():
		# Await current rotation finish to start another
		return
	
	# Perform connection rotation
	var directions = [DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT]
	var rotated = {}
	for i in range(4):
		var original_dir = directions[i]
		var new_dir = directions[(i + rotation_number) % 4]
		rotated[new_dir] = connection[original_dir]
	connection = rotated
	
	# Play rotation animation
	pipe_rotation_degree += 90 * rotation_number
	text_rotation_degree -= 90 * rotation_number
	tween = create_tween().set_parallel()
	tween.tween_property(self, "rotation_degrees", pipe_rotation_degree, 0.1).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(pattern_description, "rotation_degrees", text_rotation_degree, 0.1).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	
	# Check connectivity
	if pipe_game != null:
		pipe_game.update_active_status()
	
	# Clamp rotation value
	pipe_rotation_degree = pipe_rotation_degree % 360
	text_rotation_degree = text_rotation_degree % 360
	rotation_degrees = pipe_rotation_degree
	pattern_description.rotation_degrees = text_rotation_degree
#endregion

func _on_pressed() -> void:
	rotate(1)
	AudioManager.play_sfx(cell_rotate_SFX)
