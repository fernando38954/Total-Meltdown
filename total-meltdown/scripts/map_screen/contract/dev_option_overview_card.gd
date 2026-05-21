extends BaseOverviewCard
class_name DeveloperOptionOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName
var stored_item_key = null

func set_content(item_key: Variant) -> void:
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "%s" % [item_data.name]
	portrait.texture = item_data.portrait
	stored_item_key = item_key

#region Drag and Drop
func _get_drag_data(at_position: Vector2):
	var preview = duplicate()
	set_drag_preview(preview)
	return self
#endregion
