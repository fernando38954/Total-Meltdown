extends Node2D

const PHRASES_JSON_PATH := "res://contents/cutscene/intro.json"
@onready var sprites: Array[Sprite2D] = [
	$FirstSet/BackgroundCity,
	$FirstSet/CPUs,
	$FirstSet/CodeRunning,
	$FirstSet/ComputerError,
	$FirstSet/BuildingFire,
	$SecondSet/RetroCode,
	$SecondSet/ComputerCalls,
	$SecondSet/Agent
]

@onready var typing_label: AutoTypingRichTextLabel = $AutoTypingRichTextLabel

var phrases: Array[String] = []
var current_step := -1
var first_set_hided: bool = false
var first_set_hiding: bool = false
var switching_scene: bool = false
var tween: Tween

func _ready() -> void:
	load_phrases()
	hide_all_sprites()
	await get_tree().create_timer(1).timeout
	advance_to_next()

func load_phrases() -> void:
	var file = FileAccess.open(PHRASES_JSON_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.data
		for phrase in data.values():
			phrases.append(phrase)

func hide_all_sprites() -> void:
	for sprite in sprites:
		sprite.modulate.a = 0

func animated_hiding_first_set() -> void:
	first_set_hiding = true
	tween = create_tween().set_parallel()
	tween.tween_property(typing_label, "modulate:a", 0, 0.5)
	for idx in range(5):
		tween.tween_property(sprites[idx], "modulate:a", 0, 0.5)
	await tween.finished
	first_set_hided = true
	first_set_hiding = false
	advance_to_next()

func advance_to_next() -> void:
	typing_label.modulate.a = 1
	if current_step < sprites.size() - 1:
		current_step += 1
		tween = create_tween()
		tween.tween_property(sprites[current_step], "modulate:a", 1, 0.5)
		typing_label.start_typing(phrases[current_step])
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
	elif typing_label.is_typing:
		if tween and tween.is_running():
			tween.kill()
		sprites[current_step].modulate.a = 1
		typing_label.skip_typing()
	elif current_step >= 4 and not first_set_hided:
		if first_set_hiding:
			if tween and tween.is_running():
				tween.kill()
			hide_all_sprites()
			typing_label.modulate.a = 0
			first_set_hided = true
			first_set_hiding = false
			advance_to_next()
		else:
			animated_hiding_first_set()
	else:
		advance_to_next()
#endregion
