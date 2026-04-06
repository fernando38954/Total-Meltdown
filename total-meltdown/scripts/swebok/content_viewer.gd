extends Control

@onready var title_label = $Title
@onready var description_label = $Description
@onready var radar_chart = $RadarChart
@export var swebok: Swebok = null

func show_content(chapter_data: Dictionary):
	title_label.text = "[center][b]%s[/b][/center]\n\n" % chapter_data.title
	description_label.text = "%s" % chapter_data.description
	radar_chart.set_attributes(chapter_data.attribute)
