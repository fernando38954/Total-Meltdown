extends BaseOverviewCard
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

func set_content(item_key: String):
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "[b]%s[/b]" % [item_data.name]
	portrait.texture = item_data.portrait
