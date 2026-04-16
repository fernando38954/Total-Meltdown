extends BaseItemPanel
class_name StudySessionPanel

var studiable_chapters_list: Array = []

func set_studiable_list(new_chapters_list: Array):
	studiable_chapters_list = new_chapters_list

func get_items() -> Array:
	return studiable_chapters_list

func _ready_prerequisites():
	GlobalSignal.study_chapter.connect(_on_receive_study_chapter)
	while !SwebokManager.creation_finished:
		await get_tree().process_frame

func _on_receive_study_chapter(chapter_index):
	SwebokManager.study_chapter(studiable_chapters_list, studiable_chapters_list[chapter_index])
	GlobalSignal.emit_signal("current_map_event_finished")
