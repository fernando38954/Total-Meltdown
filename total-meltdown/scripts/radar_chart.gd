extends Control
class_name RadarChart

var property_size
var values: Array[float]
var second_values: Array[float]

@export_category("Content Settings")
@export var property_names: Array[String] = [
	"Functional Suitability",
	"Performance Efficiency",
	"Compatibility",
	"Interaction Capability",
	"Reliability",
	"Security",
	"Maintainability",
	"Flexibility",
	"Safety"
]
@export var lower_limit: float = 0.0
@export var upper_limit: float = 10.0

@export_category("Visual Settings")
@export var bg_color := Color(0.15, 0.15, 0.2)
@export var line_color := Color(0.6, 0.7, 0.9)
@export var fill_color := Color(0.3, 0.6, 0.9, 0.5)
@export var second_fill_color := Color(0.9, 0.6, 0.3, 0.5)
@export var outline_color := Color(0.2, 0.9, 0.6)
@export var second_outline_color := Color(0.6, 0.9, 0.2)
@export var text_color := Color.BLACK
@export var grid_levels := 5

# Label Settings
var font = ThemeDB.fallback_font
var font_size = 30
var value_font_size = 25

@export_category("Icon Settings")
@export var icon_textures: Array[Texture2D]

func _init():
	property_size = property_names.size()
	reset_values(property_size)

#region Value Setting
func reset_values(array_size: int):
	values.resize(array_size)
	second_values.resize(array_size)
	for i in range(array_size):
		values[i] = lower_limit
		second_values[i] = lower_limit

func set_attributes(attr_dict: Dictionary, second_attr_dict: Dictionary = {}) -> void:
	for idx in range(property_size):
		var key = property_names[idx]
		if attr_dict.has(key):
			var value = attr_dict[key]
			if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
				values[idx] = clamp(float(value), lower_limit, upper_limit)
			else:
				values[idx] = lower_limit
		else:
			values[idx] = lower_limit
		
		if second_attr_dict.has(key):
			var value = second_attr_dict[key]
			if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
				second_values[idx] = clamp(float(value), lower_limit, upper_limit)
			else:
				second_values[idx] = lower_limit
		else:
			second_values[idx] = lower_limit
	queue_redraw()

func set_label(p_font, p_font_size: int, p_value_font_size: int):
	self.font = p_font
	self.font_size = p_font_size
	self.value_font_size = p_value_font_size
#endregion

#region Draw
func _draw() -> void:
	if size.x <= 0 or size.y <= 0:
		push_error("Size of nonagon should be positive: ", get_path())
		return
	
	var center = Vector2(size.x / 2, size.y / 2)
	var radius = min(size.x, size.y) * 0.38   # Reservar espaco suficiente para label
	var label_size = min(size.x, size.y) * 0.06
	var start_angle = -PI / 2
	
	draw_background(center, radius, start_angle, label_size)
	draw_data(center, radius, start_angle)
	draw_icons(center, radius, start_angle, label_size)


func draw_background(center: Vector2, radius: float, start_angle: float, label_size: float) -> void:
	var step_angle = 2 * PI / property_size
	
	for level in range(1, grid_levels + 1):
		var level_radius = radius * level / grid_levels
		var points = []
		for i in range(property_size):
			var angle = start_angle + i * step_angle
			var point = center + Vector2(cos(angle), sin(angle)) * level_radius
			points.append(point)
		draw_polyline(points + [points[0]], line_color, 3.6)
		
		# Draw Value Label
		var level_label_size = label_size / 2
		var value = lower_limit + (upper_limit - lower_limit) * (level as float / grid_levels)
		var value_text = "%.1f" % value
		var pos = center + Vector2.UP * level_radius
		var draw_pos = pos + Vector2(level_label_size/4, level_label_size/2)
		draw_string(font, draw_pos, value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_label_size, text_color)

	
	for i in range(property_size):
		var angle = start_angle + i * step_angle
		var end_point = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, end_point, line_color, 3.0)


func draw_data(center: Vector2, radius: float, start_angle: float) -> void:
	var step_angle = 2 * PI / property_size
	var data_points = []
	var second_data_points = []
	
	for i in range(property_size):
		var r = radius * (values[i] - lower_limit) / (upper_limit - lower_limit)
		var second_r = radius * (second_values[i] - lower_limit) / (upper_limit - lower_limit)
		var angle = start_angle + i * step_angle
		var point = center + Vector2(cos(angle), sin(angle)) * r
		var second_point = center + Vector2(cos(angle), sin(angle)) * second_r
		data_points.append(point)
		second_data_points.append(second_point)
	
	if data_points.size() >= 3:
		draw_polygon(data_points, PackedColorArray([fill_color]))
		draw_polyline(data_points + [data_points[0]], outline_color, 3.6)
		for point in data_points:
			draw_circle(point, 1.5, outline_color)
	
	if second_data_points.size() >= 3:
		draw_polygon(second_data_points, PackedColorArray([second_fill_color]))
		draw_polyline(second_data_points + [second_data_points[0]], second_outline_color, 3.6)
		for point in second_data_points:
			draw_circle(point, 1.5, second_outline_color)


func draw_labels(center: Vector2, radius: float, start_angle: float) -> void:
	var step_angle = 2 * PI / property_size
	var label_offset = 18
	
	for i in range(property_size):
		var angle = start_angle + i * step_angle
		var dir = Vector2(cos(angle), sin(angle))
		var label_pos = center + dir * (radius + label_offset)
		
		var text = property_names[i]
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var draw_pos = label_pos - text_size * 0.5
		draw_string(font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		
		var value_text = "%.0f" % values[i]
		var value_size = font.get_string_size(value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, value_font_size)
		var value_pos = label_pos + Vector2(0, text_size.y) - value_size * 0.5
		draw_string(font, value_pos, value_text, HORIZONTAL_ALIGNMENT_LEFT, -1, value_font_size, Color.LIGHT_GRAY)

func draw_icons(center: Vector2, radius: float, start_angle: float, icon_size: float) -> void:
	var step_angle = 2 * PI / property_size
	var size_vector = Vector2.ONE * icon_size
	var label_offset = icon_size * 2 / 3
	
	for i in range(property_size):
		if i >= icon_textures.size() or icon_textures[i] == null:
			continue
		
		var angle = start_angle + i * step_angle
		var dir = Vector2(cos(angle), sin(angle))
		var icon_center = center + dir * (radius + label_offset)
		
		var half_size = size_vector * 0.5
		var rect = Rect2(icon_center - half_size, size_vector)
		draw_texture_rect(icon_textures[i], rect, false)
#endregion
