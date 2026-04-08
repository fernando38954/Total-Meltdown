extends Control

@onready var title_label = $Title
@onready var description_label = $Description
@onready var radar_chart = $RadarChart
@export var swebok: Swebok = null

@export_category("Visual Settings")
@export var title_size: int = 80
@export var description_size: int = 60

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

func show_content(chapter_data: Dictionary):
	title_label.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [title_size, chapter_data.title]
	description_label.text = "[font_size=%d]%s[/font_size]" % [description_size, chapter_data.description]
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(chapter_data.attribute)
