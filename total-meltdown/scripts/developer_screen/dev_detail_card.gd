extends BaseDetailCard
class_name DeveloperDetailCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart
@onready var description = $Description

@export_category("Visual Settings")
@export var name_size: int = 80
@export var description_size: int = 60

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

func set_content(item_data: Variant):
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, item_data.name]
	description.text = "[font_size=%d]%s[/font_size]" % [description_size, item_data.description]
	portrait.texture = item_data.portrait
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(item_data.attribute)
