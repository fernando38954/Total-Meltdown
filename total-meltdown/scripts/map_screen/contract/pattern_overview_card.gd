extends BaseOverviewCard
class_name PatternOverviewCard

@onready var icon = $Icon

func set_content(item_data: Dictionary):
	icon.texture = item_data.icon

func _on_pressed() -> void:
	if panel and item_index >= 0:
		panel.open_detail_card(item_index, get_center_position())

#region Drag and Drop
func _get_drag_data(at_position: Vector2):
	var preview = duplicate()
	set_drag_preview(preview)
	return self
#endregion
