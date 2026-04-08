extends Panel
class_name DeveloperPanel

@export var developer_container: GridContainer
@export var click_blocker: ColorRect
@export var developer_overview_card_scene: PackedScene
@export var developer_detail_card_scene: PackedScene

var developer_detail_card_instance: DeveloperDetailCard = null

func _ready():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
	build_developer_panel()
	close_click_blocker()

func build_developer_panel():
	for child in developer_container.get_children():
		child.queue_free()
	
	for idx in range(DeveloperManager.developers.size()):
		var developer = DeveloperManager.developers[idx]
		var developer_overview_instance = developer_overview_card_scene.instantiate()
		developer_container.add_child(developer_overview_instance)
		developer_overview_instance.set_panel(self)
		developer_overview_instance.set_content(developer)
		developer_overview_instance.set_meta("developer_index", idx)

func open_developer_detail(idx: int, initial_center: Vector2):
	if developer_detail_card_instance:
		close_developer_detail()
	
	open_click_blocker()
	var developer = DeveloperManager.developers[idx]
	developer_detail_card_instance = developer_detail_card_scene.instantiate()
	add_child(developer_detail_card_instance)
	developer_detail_card_instance.set_panel(self)
	developer_detail_card_instance.initialize_card(initial_center)
	developer_detail_card_instance.set_content(developer)
	developer_detail_card_instance.open_card()

func close_developer_detail():
	if developer_detail_card_instance != null:
		developer_detail_card_instance.queue_free()
	developer_detail_card_instance = null
	close_click_blocker()

func open_click_blocker():
	click_blocker.show()
	
func close_click_blocker():
	click_blocker.hide()

func get_center_position():
	return global_position + size * 0.5 * scale


func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		developer_detail_card_instance._on_return_button_pressed()
