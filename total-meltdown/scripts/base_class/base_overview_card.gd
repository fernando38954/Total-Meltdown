@abstract
extends TextureButton
class_name BaseOverviewCard

var panel: BaseItemPanel = null
var item_index: int = -1

func set_panel(p_panel: BaseItemPanel):
	panel = p_panel

func set_index(idx: int):
	item_index = idx

@abstract func set_content(item_data: Variant)

func get_center_position() -> Vector2:
	return global_position + size * 0.5 * scale * panel.scale

func _on_pressed() -> void:
	if panel and item_index >= 0:
		panel.open_detail_card(item_index, get_center_position())
