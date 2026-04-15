extends BaseOverviewCard
class_name PatternOptionOverviewCard

@onready var icon = $Icon
var stored_item_data = null

func set_content(item_data: Dictionary):
	icon.texture = item_data.icon
	stored_item_data = item_data

#region Drag and Drop
func _get_drag_data(at_position: Vector2):
	var preview = duplicate()
	set_drag_preview(preview)
	return self
#endregion
