extends BaseOverviewCard
class_name DeveloperOptionOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
var stored_item_data = null

func set_content(item_data: Dictionary) -> void:
	developer_name.text = "[center][b]%s[/b][/center]" % [item_data.name]
	portrait.texture = item_data.portrait
	stored_item_data = item_data

#region Drag and Drop
func _get_drag_data(at_position: Vector2):
	var preview = duplicate()
	set_drag_preview(preview)
	return self
#endregion
