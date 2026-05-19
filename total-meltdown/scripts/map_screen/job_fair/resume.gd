extends BaseOverviewCard
class_name JobFairResume

@onready var portrait = $Portrait
@onready var cost_label = $Cost
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25

func set_content(item_key: Variant):
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "[b]%s[/b]" % [item_data.name]
	cost_label.text = "-%d$" % [item_data.cost]
	portrait.texture = item_data.portrait
	radar_chart.set_label(font, font_size, value_font_size)
	radar_chart.set_attributes(item_data.attribute)

func _on_hire_button_pressed() -> void:
	GlobalSignal.emit_signal("hire_developer", item_index)
