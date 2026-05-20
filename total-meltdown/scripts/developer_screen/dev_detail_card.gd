extends BaseDetailCard
class_name DeveloperDetailCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart
@onready var description = $Description

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font

func set_content(item_key: Variant):
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "%s" % [item_data.name]
	description.text = "%s" % [item_data.description]
	portrait.texture = item_data.portrait
	radar_chart.set_label_font(font)
	radar_chart.set_attributes(item_data.attribute)
