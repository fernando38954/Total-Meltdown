extends Control
class_name RadarChart

var property_size
var values: Array[float]

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
@export var outline_color := Color(0.2, 0.9, 0.6)
@export var text_color := Color.WHITE
@export var grid_levels := 5

# Label Settings
var font
var font_size
var value_font_size
var label_offset

func _init():
	property_size = property_names.size()
	reset_values(property_size)

#region Value Setting
func reset_values(array_size: int):
	values.resize(array_size)
	for i in range(array_size):
		values[i] = lower_limit

func set_attributes(attr_dict: Dictionary) -> void:
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
	queue_redraw()

func set_label(p_font, p_font_size: int, p_value_font_size: int, p_label_offset: int):
	self.font = p_font
	self.font_size = p_font_size
	self.value_font_size = p_value_font_size
	self.label_offset = p_label_offset
#endregion

#region Draw
func _draw() -> void:
	if size.x <= 0 or size.y <= 0:
		push_error("Size of nonagon should be positive: ", get_path())
		return
	
	var center = Vector2(size.x / 2, size.y / 2)
	var radius = min(size.x, size.y) * 0.38   # Reservar espaco suficiente para label
	var start_angle = -PI / 2
	
	draw_background(center, radius, start_angle)
	draw_data(center, radius, start_angle)
	draw_labels(center, radius, start_angle)


func draw_background(center: Vector2, radius: float, start_angle: float) -> void:
	var step_angle = 2 * PI / property_size
	
	for level in range(1, grid_levels + 1):
		var level_radius = radius * level / grid_levels
		var points = []
		for i in range(property_size):
			var angle = start_angle + i * step_angle
			var point = center + Vector2(cos(angle), sin(angle)) * level_radius
			points.append(point)
		draw_polyline(points + [points[0]], line_color, 3.6)
	
	for i in range(property_size):
		var angle = start_angle + i * step_angle
		var end_point = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, end_point, line_color, 3.0)


func draw_data(center: Vector2, radius: float, start_angle: float) -> void:
	var step_angle = 2 * PI / property_size
	var data_points = []
	
	for i in range(property_size):
		var r = radius * (values[i] - lower_limit) / (upper_limit - lower_limit)
		var angle = start_angle + i * step_angle
		var point = center + Vector2(cos(angle), sin(angle)) * r
		data_points.append(point)
	
	if data_points.size() >= 3:
		draw_polygon(data_points, PackedColorArray([fill_color]))
		draw_polyline(data_points + [data_points[0]], outline_color, 3.6)
		for point in data_points:
			draw_circle(point, 1.5, outline_color)


func draw_labels(center: Vector2, radius: float, start_angle: float) -> void:
	var step_angle = 2 * PI / property_size
	
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
	#endregion
