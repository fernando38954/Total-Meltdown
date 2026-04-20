extends Control

@onready var title_label = $Title
@onready var icon = $Icon
@onready var description_label = $Description
@onready var radar_chart = $RadarChart
@export var swebok: Swebok = null

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

func show_content(pattern_data: Dictionary):
	title_label.text = "[b]%s[/b]\n\n" % [pattern_data.title]
	icon.texture = pattern_data.icon
	description_label.text = "%s" % [pattern_data.description]
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(pattern_data.attribute)
