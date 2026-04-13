extends BaseItemPanel
class_name StudySessionPanel

func get_items() -> Array:
	return SwebokManager.remaining_chapters

func _ready_prerequisites():
	while !SwebokManager.creation_finished:
		await get_tree().process_frame
