extends Control

@onready var button_container = $ScrollContainer/VBoxContainer
@export var entry_scene: PackedScene
@export var swebok: Swebok = null
@export var label_size: int = 80

func _ready():
	while !PatternManager.creation_finished:
		await get_tree().process_frame
	build_catalog()

func build_catalog():
	for child in button_container.get_children():
		child.queue_free()
	
	for idx in range(PatternManager.owned_patterns.size()):
		var pattern = PatternManager.owned_patterns[idx]
		var button = entry_scene.instantiate()
		button.button_text = pattern.title
		
		button.set_meta("pattern_index", idx)
		button.pressed.connect(_on_pattern_selected.bind(idx))
		button_container.add_child(button)

func _on_pattern_selected(pattern_idx: int):
	swebok.turn_to_page(pattern_idx)
