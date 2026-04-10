extends Control

@onready var button_container = $ScrollContainer/VBoxContainer
@export var swebok: Swebok = null
@export var label_size: int = 80

func _ready():
	while !SwebokManager.creation_finished:
		await get_tree().process_frame
	build_catalog()

func build_catalog():
	for child in button_container.get_children():
		child.queue_free()
	
	for idx in range(SwebokManager.owned_chapters.size()):
		var chapter = SwebokManager.owned_chapters[idx]
		var button = Button.new()
		button.text = chapter.title
		button.add_theme_font_size_override("font_size", label_size)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		button.set_meta("chapter_index", idx)
		button.pressed.connect(_on_chapter_selected.bind(idx))
		button_container.add_child(button)

func _on_chapter_selected(chapter_idx: int):
	swebok.turn_to_page(chapter_idx)
