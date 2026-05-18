extends BaseOverviewCard
class_name StudySessionCourse

@onready var pattern_title = $PatternName
@onready var description_label = $Description

func set_content(item_key: Variant):
	var item_data = PatternManager.get_pattern_by_key(item_key)
	pattern_title.text = "[b]%s[/b]" % [item_data.title]
	description_label.text = "%s" % [item_data.abstract]

func _on_study_button_pressed() -> void:
	GlobalSignal.emit_signal("study_pattern", item_index)
