extends Node

#region Tutorial Manager
const TUTORIAL_DIR = "res://contents/tutorial/"

var all_tutorials: Dictionary = {}
var unstarted_tutorials: Array = []
var actived_tutorials: Array = []
var completed_tutorials: Array = []
var creation_finished = false

func _ready():
	load_tutorials()
	initialize()
	GlobalSignal.game_start.connect(initialize)
	GlobalSignal.start_tutorial.connect(call_tutorial)
	close_dialgue_box(0)

#region Load Data
func load_tutorials():
	all_tutorials.clear()
	var dir = DirAccess.open(TUTORIAL_DIR)
	if not dir:
		creation_finished = true
		push_error("Error on opening the directory:", TUTORIAL_DIR)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var path = TUTORIAL_DIR + file_name
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var error = json.parse(json_text)
				if error == OK:
					var data = json.data
					var key = data.get("key", "Unknown")
					all_tutorials[key] = {
						"key": key,
						"dialogue": data.get("dialogue", {}),
					}
				else:
					creation_finished = true
					push_error("Failed to parse JSON：", file_name)
					return
				file.close()
		file_name = dir.get_next()
	
	creation_finished = true
	print_debug("Number of tutorials loaded：", all_tutorials.size())

func initialize():
	unstarted_tutorials = all_tutorials.keys()
	actived_tutorials.clear()
	completed_tutorials.clear()
#endregion

#region Array Operation
func get_tutorial_by_key(key: String) -> Dictionary:
	return all_tutorials.get(key, {})

func start_tutorial(target_tutorial_key: String):
	if target_tutorial_key in unstarted_tutorials:
		unstarted_tutorials.erase(target_tutorial_key)
		actived_tutorials.append(target_tutorial_key)
		var tutorial_data = get_tutorial_by_key(target_tutorial_key)
		current_tutorial_key = target_tutorial_key
		dialogue_start(tutorial_data.dialogue.values())
	else:
		push_error("start_tutorial: No tutorial with key " + target_tutorial_key + " found in unstarted_tutorials")

func finish_tutorial(target_tutorial_key: String):
	if target_tutorial_key in actived_tutorials:
		actived_tutorials.erase(target_tutorial_key)
		completed_tutorials.append(target_tutorial_key)
	else:
		push_error("finish_tutorial: No tutorial with key " + target_tutorial_key + " found in actived_tutorials")
#endregion
#endregion

#region Tutorial Scene
@onready var portraits: Dictionary[String, Texture] = {
	"admiring": preload("res://assets/sprites/tutorial/Clipper_admiring.png"),
	"confused": preload("res://assets/sprites/tutorial/Clipper_confused.png"),
	"normal": preload("res://assets/sprites/tutorial/Clipper_normal.png"),
	"surprised": preload("res://assets/sprites/tutorial/Clipper_surprised.png"),
	"sweating": preload("res://assets/sprites/tutorial/Clipper_sweating.png"),
}

@onready var dialogue_box = $DialogueBox
@onready var portrait = $DialogueBox/Portrait
@onready var dialogue = $DialogueBox/Dialogue

@export var open_position: Vector2 = Vector2(484.0, 1625.0)
@export var close_position: Vector2 = Vector2(484.0, 2259.0)

var tutorial_active: bool = false
var current_tutorial_key: String = ""
var dialogue_list: Array
var current_dialogue_idx: int

var tween: Tween

#region Dialogue
func call_tutorial(target_tutorial_key: String):
	if target_tutorial_key in unstarted_tutorials:
		start_tutorial(target_tutorial_key)

func move_dialgue_box(target_position: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(dialogue_box, "position", target_position, duration)

func close_dialgue_box(duration: float = 0.5):
	move_dialgue_box(close_position, duration)

func open_dialgue_box(duration: float = 0.5):
	move_dialgue_box(open_position, duration)

func dialogue_start(_dialogue_list: Array):
	tutorial_active = true
	dialogue_list = _dialogue_list
	current_dialogue_idx = -1
	open_dialgue_box()
	advance_to_next()

func dialogue_finish():
	tutorial_active = false
	dialogue_list = []
	current_dialogue_idx = -1
	close_dialgue_box()

func advance_to_next() -> void:
	if current_dialogue_idx < dialogue_list.size() - 1:
		current_dialogue_idx += 1
		var current_dialogue = dialogue_list[current_dialogue_idx]
		portrait.texture = portraits[current_dialogue.portrait]
		dialogue.start_typing(current_dialogue.phrase)
	else:
		dialogue_finish()
#endregion

func _input(event: InputEvent):
	if tutorial_active:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
			# If dialogue not finished yet, proceed dialogue
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if dialogue.is_typing:
					dialogue.skip_typing()
				else:
					advance_to_next()
