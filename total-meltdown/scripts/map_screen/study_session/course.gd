extends BaseOverviewCard
class_name StudySessionCourse

@onready var pattern_title = $PatternName
@onready var description_label = $Description

@export_category("Visual Settings")
@export var title_size: int = 100
@export var description_size: int = 80

func set_content(item_data: Variant):
	pattern_title.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [title_size, item_data.title]
	description_label.text = "[font_size=%d]%s[/font_size]" % [description_size, item_data.description]

func _on_study_button_pressed() -> void:
	GlobalSignal.emit_signal("study_pattern", item_index)
