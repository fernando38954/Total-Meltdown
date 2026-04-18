extends BaseOverviewCard
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

@export_category("Visual Settings")
@export var name_size: int = 100

func set_content(item_data: Variant) -> void:
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, item_data.name]
	portrait.texture = item_data.portrait
