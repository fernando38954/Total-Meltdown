@abstract
extends Panel
class_name BaseItemPanel

@export var container: Container
@export var click_blocker: ColorRect
@export var overview_card_scene: PackedScene
@export var detail_card_scene: PackedScene

var current_detail_card_instance: BaseDetailCard = null

@abstract func get_items()

func get_item(index: int, items: Array = []):
	if items.is_empty():
		items = get_items()
	if index < 0 or index >= items.size():
		return {}
	return items[index]

@abstract func _ready_prerequisites()

func _ready():
	await _ready_prerequisites()
	build_panel()
	close_click_blocker()

func build_panel():
	for child in container.get_children():
		child.queue_free()
	
	for idx in range(get_items().size()):
		var item = get_items()[idx]
		var overview_instance = overview_card_scene.instantiate()
		container.add_child(overview_instance)
		overview_instance.set_panel(self)
		overview_instance.set_content(item)
		overview_instance.set_index(idx)

func open_detail_card(idx: int, initial_center: Vector2):
	if current_detail_card_instance:
		close_detail_card()
	
	open_click_blocker()
	var item = get_item(idx)
	current_detail_card_instance = detail_card_scene.instantiate()
	add_child(current_detail_card_instance)
	current_detail_card_instance.set_panel(self)
	current_detail_card_instance.initialize_card(initial_center)
	current_detail_card_instance.set_content(item)
	current_detail_card_instance.open_card()

func close_detail_card():
	if current_detail_card_instance != null:
		current_detail_card_instance.queue_free()
		current_detail_card_instance = null
	close_click_blocker()

func open_click_blocker():
	if click_blocker:
		click_blocker.show()

func close_click_blocker():
	if click_blocker:
		click_blocker.hide()

func get_center_position() -> Vector2:
	return global_position + size * 0.5 * scale

func _on_click_blocker_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_detail_card_instance._on_return_button_pressed()
