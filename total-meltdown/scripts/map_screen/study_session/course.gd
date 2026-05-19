extends BaseOverviewCard
class_name StudySessionCourse

@onready var pattern_title = $PatternName
@onready var cost_label = $Cost
@onready var icon = $Icon
@onready var concept_label = $Concept
@onready var advantage_label = $Advantage
@onready var disadvantage_label = $Disadvantage

func set_content(item_key: Variant):
	var item_data = PatternManager.get_pattern_by_key(item_key)
	pattern_title.text = "[b]%s[/b]" % [item_data.title]
	cost_label.text = "-%d$" % [item_data.cost]
	icon.texture = item_data.icon
	concept_label.text = "%s" % [item_data.concept]
	advantage_label.text = "%s" % [item_data.advantage]
	disadvantage_label.text = "%s" % [item_data.disadvantage]

func _on_study_button_pressed() -> void:
	GlobalSignal.emit_signal("study_pattern", item_index)
