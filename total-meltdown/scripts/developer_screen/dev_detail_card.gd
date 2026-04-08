extends Panel
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

var developer_panel: DeveloperPanel = null
var initial_center_position: Vector2
var tween: Tween

func set_panel(panel: DeveloperPanel):
	developer_panel = panel

func initialize_card(target_center_position: Vector2) -> void:
	scale = Vector2.ZERO
	initial_center_position = target_center_position
	global_position = initial_center_position

func set_content(developer_data: Dictionary):
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, developer_data.name]
	description.text = "[font_size=%d]%s[/font_size]" % [description_size, developer_data.description]
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(developer_data.attribute)
	
	var texture = load(developer_data.portrait_path)
	if texture:
		portrait.texture = texture
	else:
		push_error("Error: Unable to load image:", developer_data.portrait_path)

#region Animation
func animate_to_center(target_center_position: Vector2, target_scale: Vector2, duration: float, callback: Callable = Callable()):
	if tween and tween.is_running():
		return
	
	var target_global_position = target_center_position - size * 0.5 * target_scale * developer_panel.scale
	tween = create_tween().set_parallel(true)
	tween.tween_property(self, "global_position", target_global_position, duration)
	tween.tween_property(self, "scale", target_scale, duration)
	
	await tween.finished
	if callback.is_valid():
		callback.call()

func close_card(duration: float = 0.2, callback: Callable = Callable()):
	animate_to_center(initial_center_position, Vector2.ZERO, duration, callback)

func open_card(duration: float = 0.2, callback: Callable = Callable()):
	var developer_panel_center_position = developer_panel.get_center_position()
	print(developer_panel_center_position)
	animate_to_center(developer_panel_center_position, Vector2(0.8, 0.8), duration, callback)
#endregion

func _on_return_button_pressed() -> void:
	var callback = Callable(developer_panel, "close_developer_detail")
	close_card(.2, callback)
