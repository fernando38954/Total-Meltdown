extends BaseDetailCard
class_name PatternDetailCard

@onready var icon = $Icon
@onready var pattern_name = $PatternName
@onready var complexity_level = $ComplexityLevel
@onready var cost_level = $CostLevel
@onready var radar_chart = $RadarChart
@onready var description = $Description

@export var level_indicator: Texture

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25

func set_content(item_key: Variant):
	var item_data =  PatternManager.get_pattern_by_key(item_key)
	icon.texture = item_data.icon
	pattern_name.text = "%s" % [item_data.title]
	complexity_level.get_children()[item_data.complexity_level - 1].texture = level_indicator
	cost_level.get_children()[item_data.cost_level - 1].texture = level_indicator
	description.text = "%s" % [item_data.description]
	radar_chart.set_label(font, font_size, value_font_size)
	radar_chart.set_attributes(item_data.attribute)
