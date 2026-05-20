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
@export var property_display_names: Array[String] = [
	"Adequação Funcional",
	"Eficiência de Desempenho",
	"Compatibilidade",
	"Capacidade de Interação",
	"Confiabilidade",
	"Segurança",
	"Manutenibilidade",
	"Flexibilidade",
	"Segurança Operacional"
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

@export_category("Icon Settings")
@export var icon_textures: Array[Texture2D]
var icon_rects: Array[Rect2] = []

# Tooltip Variables
@export var tooltip_label: Label
var current_hovered_icon_idx: int = -1

@export_category("Animation Settings")
var tween: Tween
var start_values: Array[float] = []
var start_second_values: Array[float] = []
var target_values: Array[float] = []
var target_second_values: Array[float] = []
@export var animation_duration: float = 0.5

func _init():
	property_size = property_names.size()
	reset_values()

func _ready() -> void:
	hide_tooltip()

#region Value Setting
func reset_values(array_size: int = property_size):
	values.resize(array_size)
	values.fill(lower_limit)
	second_values.resize(array_size)
	second_values.fill(lower_limit)
	target_values.resize(array_size)
	target_values.fill(lower_limit)
	target_second_values.resize(array_size)
	target_second_values.fill(lower_limit)

func set_attributes(attr_dict: Dictionary, second_attr_dict: Dictionary = {}) -> void:
	for idx in range(property_size):
		var key = property_names[idx]
		if attr_dict.has(key):
			var value = attr_dict[key]
			if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
				target_values[idx] = clamp(float(value), lower_limit, upper_limit)
			else:
				target_values[idx] = lower_limit
		else:
			target_values[idx] = lower_limit
		
		if second_attr_dict.has(key):
			var value = second_attr_dict[key]
			if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
				target_second_values[idx] = clamp(float(value), lower_limit, upper_limit)
			else:
				target_second_values[idx] = lower_limit
		else:
			target_second_values[idx] = lower_limit
	start_animation()

func set_label_font(p_font):
	self.font = p_font
#endregion

#region Animation
func stop_animation() -> void:
	if tween and tween.is_valid():
		tween.kill()

func start_animation() -> void:
	stop_animation()
	
	start_values = values.duplicate()
	start_second_values = second_values.duplicate()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(update_animation, 0.0, 1.0, animation_duration)
	tween.finished.connect(on_animation_finished)

func update_animation(progress: float) -> void:
	for idx in range(property_size):
		values[idx] = lerp(start_values[idx], target_values[idx], progress)
		second_values[idx] = lerp(start_second_values[idx], target_second_values[idx], progress)
	queue_redraw()

func on_animation_finished() -> void:
	values = target_values.duplicate()
	second_values = target_second_values.duplicate()
	queue_redraw()

func _exit_tree() -> void:
	stop_animation()
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
	setup_tooltip()


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

func draw_icons(center: Vector2, radius: float, start_angle: float, icon_size: float) -> void:
	var step_angle = 2 * PI / property_size
	var size_vector = Vector2.ONE * icon_size
	var label_offset = icon_size * 2 / 3
	icon_rects.resize(property_size)
	
	for i in range(property_size):
		if i >= icon_textures.size() or icon_textures[i] == null:
			continue
		
		var angle = start_angle + i * step_angle
		var dir = Vector2(cos(angle), sin(angle))
		var icon_center = center + dir * (radius + label_offset)
		var half_size = size_vector * 0.5
		var rect = Rect2(icon_center - half_size, size_vector)
		draw_texture_rect(icon_textures[i], rect, false)
		icon_rects[i] = rect
#endregion

#region Mouse Detection & Tooltip
func setup_tooltip():
	var tooltip_font_size = clamp(min(size.x, size.y) * 0.05, 16.0, 80.0)
	tooltip_label.add_theme_font_size_override("font_size", int(tooltip_font_size))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_hovered_icon_idx = get_hovered_icon_index()
		
		if new_hovered_icon_idx != current_hovered_icon_idx:
			if current_hovered_icon_idx != -1:
				hide_tooltip()
			if new_hovered_icon_idx != -1:
				update_tooltip_content(new_hovered_icon_idx)
				update_tooltip_position(new_hovered_icon_idx)
				tooltip_label.visible = true
			current_hovered_icon_idx = new_hovered_icon_idx
		elif new_hovered_icon_idx != -1:
			update_tooltip_position(new_hovered_icon_idx)

func get_hovered_icon_index() -> int:
	for i in range(icon_rects.size()):
		if icon_rects[i].has_point(get_local_mouse_position()):
			return i
	return -1

func update_tooltip_content(idx: int) -> void:
	if idx < 0 or idx >= property_display_names.size() or idx >= values.size():
		return
	
	var attr_name = property_display_names[idx]
	var attr_value = target_values[idx] if target_second_values[idx] == lower_limit else target_second_values[idx]
	tooltip_label.text = "%s\n%.1f" % [attr_name, attr_value]
	tooltip_label.reset_size()

func update_tooltip_position(idx: int) -> void:
	var offset = icon_rects[idx].size
	var new_pos = icon_rects[idx].position + offset
	var tooltip_size = tooltip_label.get_minimum_size()
	new_pos.x = clamp(new_pos.x, 0, size.x - tooltip_size.x)
	new_pos.y = clamp(new_pos.y, 0, size.y - tooltip_size.y)
	tooltip_label.position = new_pos

func hide_tooltip() -> void:
	tooltip_label.visible = false
	current_hovered_icon_idx = -1
#endregion
