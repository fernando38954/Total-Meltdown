extends Node2D

func _on_start_button_pressed() -> void:
	await Fade.fade_out().finished  
	get_tree().change_scene_to_file("res://scenes/IntroCutscene.tscn")
	await Fade.fade_in().finished
