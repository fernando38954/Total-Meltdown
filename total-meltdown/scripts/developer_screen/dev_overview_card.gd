extends BaseOverviewCard
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

func set_content(item_data: Variant) -> void:
	developer_name.text = "[b]%s[/b]\n\n" % [item_data.name]
	portrait.texture = item_data.portrait
