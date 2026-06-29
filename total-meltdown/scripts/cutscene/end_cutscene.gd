extends MangaCutscene

@export var finish_screen: FinishScreen

@export_category("BGM")
@export var good_endBGM: AudioStream
@export var bad_endBGM: AudioStream

func initialize_phrases_path():
	phrases_json_path = "cutscene/end.json"

func ready_setting():
	current_set_idx = 0 if GlobalResource.money > 400 else 1
	cutscene_BGM = good_endBGM if GlobalResource.money > 400 else bad_endBGM

func on_set_completed(set_idx: int) -> MangaAction:
	return MangaAction.END

func end_cutscene():
	switching_scene = true
	finish_screen.show_screen()
