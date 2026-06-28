extends Node2D

const CONFIG_POPUP_SCENE = preload("res://scenes/component/ConfigPopup.tscn")
const CREDIT_POPUP_SCENE = preload("res://scenes/component/CreditPopup.tscn")

@export_category("SFX")
@export var start_game_SFX: AudioStream

@export_category("BGM")
@export var main_BGM: AudioStream

func _ready() -> void:
	AudioManager.play_bgm(main_BGM)


func _on_start_button_pressed() -> void:
	AudioManager.play_sfx(start_game_SFX)
	AudioManager.stop_bgm()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/IntroCutscene.tscn")
	await Fade.fade_in().finished


func _on_config_button_pressed() -> void:
	var config_popup = CONFIG_POPUP_SCENE.instantiate()
	get_tree().root.add_child(config_popup)


func _on_credit_button_pressed() -> void:
	var credit_popup = CREDIT_POPUP_SCENE.instantiate()
	get_tree().root.add_child(credit_popup)
