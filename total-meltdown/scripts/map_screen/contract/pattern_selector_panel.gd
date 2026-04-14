extends BaseItemPanel
class_name PatternSelectorPanel

@export var target_detail_card_center: Vector2

func get_items():
	return SwebokManager.chapters

func _ready_prerequisites():
	while !SwebokManager.creation_finished:
		await get_tree().process_frame
