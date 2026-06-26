extends Node2D

const PHRASES_JSON_PATH := "cutscene/intro.json"

@export var node_sets: Array[Node] = []
var sprites: Array[Sprite2D] = []
var labels: Array[AutoTypingRichTextLabel] = []
var first_set_sprite_counter = 0
var first_set_label_counter = 0

var frames_data: Array[Array] = []
var current_frame_idx: int = -1
var current_phrase_idx: int = 0
var current_label_idx: int = -1
var first_set_hided: bool = false
var first_set_hiding: bool = false
var switching_scene: bool = false
var tween: Tween

func _ready() -> void:
	load_nodes()
	load_phrases()
	hide_all_sprites()
	await get_tree().create_timer(1).timeout
	advance_to_next()

func load_nodes() -> void:
	for node_set in node_sets:
		for child in node_set.get_children():
			if child is Sprite2D:
				sprites.append(child)
				if node_set.name == "FirstSet":
					first_set_sprite_counter += 1
			elif child is AutoTypingRichTextLabel:
				labels.append(child)
				if node_set.name == "FirstSet":
					first_set_label_counter += 1

func load_phrases() -> void:
	var file_path = GlobalResource.get_current_content_path() + PHRASES_JSON_PATH
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Error JSON parse: ", error)
		return
	
	var data = json.data
	for frame_data in data.values():
		var phrases: Array[String] = []
		for phrase in frame_data.values():
			phrases.append(phrase)
		frames_data.append(phrases)

func hide_all_sprites() -> void:
	for sprite in sprites:
		sprite.modulate.a = 0

func hide_all_labels() -> void:
	for label in labels:
		label.modulate.a = 0

func animated_hiding_first_set() -> void:
	first_set_hiding = true
	tween = create_tween().set_parallel()
	for idx in range(first_set_sprite_counter):
		tween.tween_property(sprites[idx], "modulate:a", 0, 0.5)
	for idx in range(first_set_label_counter):
		tween.tween_property(labels[idx], "modulate:a", 0, 0.5)
	await tween.finished
	first_set_hided = true
	first_set_hiding = false
	advance_to_next()

func advance_to_next() -> void:
	if current_frame_idx >= 0 and current_phrase_idx < frames_data[current_frame_idx].size() - 1:
		current_phrase_idx += 1
		current_label_idx += 1
		labels[current_label_idx].modulate.a = 1
		labels[current_label_idx].start_typing(frames_data[current_frame_idx][current_phrase_idx])
	else:
		if current_frame_idx < sprites.size() - 1:
			current_frame_idx += 1
			tween = create_tween()
			tween.tween_property(sprites[current_frame_idx], "modulate:a", 1, 0.5)
			
			current_phrase_idx = 0
			current_label_idx += 1
			labels[current_label_idx].modulate.a = 1
			labels[current_label_idx].start_typing(frames_data[current_frame_idx][current_phrase_idx])
		else:
			switching_scene = true
			await Fade.fade_out().finished  
			get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
			GlobalSignal.emit_signal("game_start")
			Fade.fade_in()

#region Click Handle
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click()

func handle_click() -> void:
	if switching_scene:
		return
	elif labels[current_label_idx].is_typing:
		if tween and tween.is_running():
			tween.kill()
		sprites[current_frame_idx].modulate.a = 1
		labels[current_label_idx].skip_typing()
	elif current_frame_idx >= 4 and not current_phrase_idx < frames_data[current_frame_idx].size() - 1 and not first_set_hided:
		if first_set_hiding:
			if tween and tween.is_running():
				tween.kill()
			hide_all_sprites()
			hide_all_labels()
			first_set_hided = true
			first_set_hiding = false
			advance_to_next()
		else:
			animated_hiding_first_set()
	else:
		advance_to_next()
#endregion
