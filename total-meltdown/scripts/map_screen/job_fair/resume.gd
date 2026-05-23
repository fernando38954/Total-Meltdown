extends BaseOverviewCard
class_name JobFairResume

@onready var portrait = $Portrait
@onready var cost_label = $Cost
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font

var developer_key = ""

func set_content(item_key: Variant):
	developer_key = item_key
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "[b]%s[/b]" % [item_data.name]
	cost_label.text = "-%d$" % [item_data.cost]
	portrait.texture = item_data.portrait
	radar_chart.set_label_font(font)
	radar_chart.set_attributes(item_data.attribute)

func _on_hire_button_pressed() -> void:
	GlobalSignal.emit_signal("hire_developer", developer_key)
