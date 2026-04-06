extends Button
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var status = $Status
@export var developer_panel: DeveloperPanel = null

func set_panel(panel: DeveloperPanel):
	developer_panel = panel

func set_content(developer_data: Dictionary):
	developer_name.text = "[center][font_size=40]%s[/font_size][/center]\n\n" % developer_data.name
	
	var texture = load(developer_data.portrait_path)
	if texture:
		portrait.texture = texture
	else:
		push_error("Error: Unable to load image:", developer_data.portrait_path)


func _on_pressed() -> void:
	developer_panel.open_developer_detail(self.get_meta("developer_index"))
