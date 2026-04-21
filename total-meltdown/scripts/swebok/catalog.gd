extends Control

@export var button_entry_scene: PackedScene
@export var swebok: Swebok = null

@export_category("Container")
@export var tutorial_container: Container
@export var pattern_container: Container

func _ready():
	while !PatternManager.creation_finished or !TutorialPageManager.creation_finished:
		await get_tree().process_frame
	build_catalog()

func build_catalog():
	for child in tutorial_container.get_children() + pattern_container.get_children():
		child.queue_free()
	
	for idx in range(TutorialPageManager.all_pages.size()):
		var page = TutorialPageManager.all_pages[idx]
		var button = button_entry_scene.instantiate()
		button.button_text = page.title
		button.pressed.connect(_on_page_selected.bind(idx, ContentViewer.ContentType.Tutorial))
		tutorial_container.add_child(button)
	
	for idx in range(PatternManager.owned_patterns.size()):
		var pattern = PatternManager.owned_patterns[idx]
		var button = button_entry_scene.instantiate()
		button.button_text = pattern.title
		button.pressed.connect(_on_page_selected.bind(idx, ContentViewer.ContentType.Pattern))
		pattern_container.add_child(button)

func _on_page_selected(index: int, content_type: ContentViewer.ContentType):
	swebok.turn_to_page(index, content_type)
