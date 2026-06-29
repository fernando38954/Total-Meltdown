@abstract
extends Node2D
class_name MangaCutscene

var phrases_json_path

enum MangaAction { NEXT, END }

@export var node_sets: Array[Node] = []
var current_set_idx: int = 0
var current_set_hiding: bool = false

var sprite_sets: Array[Array] = []
var label_sets: Array[Array] = []
var current_label_idx: int = -1

var frame_sets: Array[Array] = []
var current_frame_idx: int = -1
var current_phrase_idx: int = -1

var cutscene_BGM: AudioStream
var switching_scene: bool = false
var tween: Tween



func _ready() -> void:
	initialize_phrases_path()
	ready_setting()
	load_nodes()
	load_phrases()
	force_hide_all_elements()
	AudioManager.play_bgm(cutscene_BGM)
	await get_tree().create_timer(1).timeout
	advance_to_next()

@abstract func initialize_phrases_path()
@abstract func ready_setting()

func load_nodes() -> void:
	for container in node_sets:
		var sprite_list: Array[Sprite2D] = []
		var label_list: Array[AutoTypingRichTextLabel] = []
		for child in container.get_children():
			if child is Sprite2D:
				sprite_list.append(child)
			elif child is AutoTypingRichTextLabel:
				label_list.append(child)
		sprite_sets.append(sprite_list)
		label_sets.append(label_list)

func load_phrases() -> void:
	var file_path = GlobalResource.get_current_content_path() + phrases_json_path
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Error JSON parse: ", error)
		return
	
	var data = json.data
	for frame_set in data.values():
		var frame_list: Array[Array] = []
		for frame in frame_set.values():
			var frame_data: Array[String] = []
			for phrase in frame.values():
				frame_data.append(phrase)
			frame_list.append(frame_data)
		frame_sets.append(frame_list)

func force_hide_all_elements() -> void:
	for sprite_set in sprite_sets:
		for sprite in sprite_set:
			sprite.modulate.a = 0
	for label_set in label_sets:
		for label in label_set:
			label.modulate.a = 0

func force_hide_current_set_sprites() -> void:
	for sprite in sprite_sets[current_set_idx]:
		sprite.modulate.a = 0

func force_hide_current_set_labels() -> void:
	for label in label_sets[current_set_idx]:
		label.modulate.a = 0

func animated_current_set_hiding() -> void:
	current_set_hiding = true
	tween = create_tween().set_parallel()
	for sprite in sprite_sets[current_set_idx]:
		tween.tween_property(sprite, "modulate:a", 0, 0.5)
	for label in label_sets[current_set_idx]:
		tween.tween_property(label, "modulate:a", 0, 0.5)
	await tween.finished
	current_set_hiding = false

@abstract func on_set_completed(set_idx: int) -> MangaAction

func advance_to_next() -> void:
	var current_frame_list = frame_sets[current_set_idx]
	var current_sprite_list = sprite_sets[current_set_idx]
	var current_label_list = label_sets[current_set_idx]

	if current_frame_idx >= 0 and current_phrase_idx < current_frame_list[current_frame_idx].size() - 1:
		current_phrase_idx += 1
		current_label_idx += 1
		current_label_list[current_label_idx].modulate.a = 1
		current_label_list[current_label_idx].start_typing(current_frame_list[current_frame_idx][current_phrase_idx])
	else:
		if current_frame_idx < current_frame_list.size() - 1:
			current_frame_idx += 1
			tween = create_tween()
			tween.tween_property(current_sprite_list[current_frame_idx], "modulate:a", 1, 0.5)
			
			if current_frame_list[current_frame_idx].size() > 0:
				current_phrase_idx = 0
				current_label_idx += 1
				current_label_list[current_label_idx].modulate.a = 1
				current_label_list[current_label_idx].start_typing(current_frame_list[current_frame_idx][current_phrase_idx])
		else:
			var action = on_set_completed(current_set_idx)
			match action:
				MangaAction.NEXT:
					if current_set_idx < node_sets.size() - 1:
						if not current_set_hiding:
							await animated_current_set_hiding()
							current_set_idx += 1
							current_label_idx = -1
							current_frame_idx = -1
							current_phrase_idx = 0
							advance_to_next()
					else:
						end_cutscene()
				MangaAction.END:
					end_cutscene()

@abstract func end_cutscene()

#region Click Handle
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click()

func handle_click() -> void:
	if switching_scene:
		return
	elif label_sets[current_set_idx][current_label_idx].is_typing:
		if tween and tween.is_running():
			tween.kill()
		sprite_sets[current_set_idx][current_frame_idx].modulate.a = 1
		label_sets[current_set_idx][current_label_idx].skip_typing()
	elif current_set_hiding:
		if tween and tween.is_running():
			tween.kill()
			force_hide_current_set_labels()
			force_hide_current_set_sprites()
			tween.finished.emit()
	else:
		advance_to_next()
#endregion
