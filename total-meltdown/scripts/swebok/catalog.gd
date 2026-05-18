extends Control

@export var swebok: Swebok = null

@export_category("Container")
@export var attribute_container: Container
@export var pattern_container: Container

func _ready():
	while !PatternManager.creation_finished or !TutorialPageManager.creation_finished:
		await get_tree().process_frame
	build_catalog()

func build_catalog():
	pass

func _on_page_selected(index: int, content_type: ContentViewer.ContentType):
	swebok.turn_to_page(index, content_type)
