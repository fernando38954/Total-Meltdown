extends BaseDetailCard
class_name DeveloperDetailCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart
@onready var description = $Description

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25

func set_content(item_data: Variant):
	developer_name.text = "[b]%s[/b]\n\n" % [item_data.name]
	description.text = "%s" % [item_data.description]
	portrait.texture = item_data.portrait
	radar_chart.set_label(font, font_size, value_font_size)
	radar_chart.set_attributes(item_data.attribute)
