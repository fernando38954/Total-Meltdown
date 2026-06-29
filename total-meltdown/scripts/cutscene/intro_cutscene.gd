extends MangaCutscene

@export_category("BGM")
@export var mainBGM: AudioStream

func initialize_phrases_path():
	phrases_json_path = "cutscene/intro.json"

func ready_setting():
	cutscene_BGM = mainBGM

func on_set_completed(set_idx: int) -> MangaAction:
	return MangaAction.NEXT

func end_cutscene():
	switching_scene = true
	AudioManager.stop_bgm()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
	GlobalSignal.emit_signal("game_start")
	Fade.fade_in()
