extends Button
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

@export_category("Visual Settings")
@export var name_size: int = 100

var developer_panel: DeveloperPanel = null

func set_panel(panel: DeveloperPanel):
	developer_panel = panel

func set_content(developer_data: Dictionary):
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, developer_data.name]
	portrait.texture = developer_data.portrait

func get_center_position():
	return global_position + size * 0.5 * scale * developer_panel.scale

func _on_pressed() -> void:
	developer_panel.open_developer_detail(self.get_meta("developer_index"), get_center_position())
