extends Control
class_name ContentViewer

@onready var title_label = $Title
@onready var icon = $Icon
@onready var image = $Image
@onready var description_label = $Description
@onready var radar_chart = $RadarChart
@export var swebok: Swebok = null

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

enum ContentType{
	Tutorial, Pattern
}

func show_content(content_data: Dictionary, content_type: ContentType):
	title_label.text = "[b]%s[/b]\n\n" % [content_data.title]
	description_label.text = "%s" % [content_data.description]
	if content_type == ContentType.Tutorial:
		icon.hide()
		radar_chart.hide()
		image.show()
		image.texture = content_data.image
	if content_type == ContentType.Pattern:
		icon.show()
		radar_chart.show()
		image.hide()
		icon.texture = content_data.icon
		radar_chart.set_label(font, font_size, value_font_size, label_offset)
		radar_chart.set_attributes(content_data.attribute)
