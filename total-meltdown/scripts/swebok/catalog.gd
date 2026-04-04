extends Control

@onready var button_container = $ScrollContainer/VBoxContainer
@export var swebok: Swebok = null

func _ready():
	while SwebokManager.chapters.is_empty():
		await get_tree().process_frame
	build_catalog()

func build_catalog():
	for child in button_container.get_children():
		child.queue_free()
	
	for idx in range(SwebokManager.chapters.size()):
		var chapter = SwebokManager.chapters[idx]
		var button = Button.new()
		button.text = chapter.title
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		button.set_meta("chapter_index", idx)
		button.pressed.connect(_on_chapter_selected.bind(idx))
		button_container.add_child(button)

func _on_chapter_selected(chapter_idx: int):
	var chapter_data = SwebokManager.chapters[chapter_idx]
	swebok.show_chapter_content(chapter_data)
