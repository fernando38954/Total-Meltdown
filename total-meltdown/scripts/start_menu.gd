extends Node2D


func _on_start_button_pressed() -> void:
	await Fade.fade_out().finished  
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
	GlobalSignal.emit_signal("game_start")
	Fade.fade_in()
