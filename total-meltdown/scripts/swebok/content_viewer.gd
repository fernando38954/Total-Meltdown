extends Control

@onready var content_label = $RichTextLabel
@onready var back_button = $BackButton
@export var swebok: Swebok = null

func show_content(chapter_data: Dictionary):
	content_label.text = "[center][b]%s[/b][/center]\n\n%s" % [chapter_data.title, chapter_data.description]

func _on_back_button_pressed() -> void:
	swebok.show_catalog()
