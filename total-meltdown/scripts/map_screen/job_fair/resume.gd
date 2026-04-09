extends TextureButton
class_name JobFairResume

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart

@export_category("Visual Settings")
@export var name_size: int = 100

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

var job_fair_panel: DeveloperPanel = null
var resume_developer_data = null

func set_panel(panel: DeveloperPanel):
	job_fair_panel = panel

func set_content(developer_data: Dictionary):
	resume_developer_data = developer_data
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, developer_data.name]
	portrait.texture = developer_data.portrait
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(developer_data.attribute)

func get_center_position():
	return global_position + size * 0.5 * scale * job_fair_panel.scale

func _on_pressed() -> void:
	job_fair_panel.open_developer_detail(self.get_meta("developer_index"), get_center_position())


func _on_hire_button_pressed() -> void:
	GlobalSignal.emit_signal("hire_developer", resume_developer_data.file_name)
