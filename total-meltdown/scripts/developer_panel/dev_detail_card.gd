extends Panel

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
@onready var radar_chart = $RadarChart
@onready var description = $Description
@export var developer_panel: DeveloperPanel = null

func set_content(developer_data: Dictionary):
	developer_name.text = "[center][font_size=40]%s[/font_size][/center]\n\n" % developer_data.name
	description.text = "%s" % developer_data.description
	radar_chart.set_attributes(developer_data.attribute)
	
	var texture = load(developer_data.portrait_path)
	if texture:
		portrait.texture = texture
	else:
		push_error("Error: Unable to load image:", developer_data.portrait_path)
