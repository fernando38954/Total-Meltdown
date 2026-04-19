extends BaseItemPanel
class_name DeveloperPanel

@export_category("Extra Container")
@export var extra_container: Container
@export var extra_overview_card_scene: PackedScene
@export var extra_detail_card_scene: PackedScene
const INDEX_DIVISION_NUMBER = 10000

#region Abstract Override Functions
func get_items() -> Array:
	return DeveloperManager.idle_developers

func _ready_prerequisites():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
#endregion

func get_extra_container_items() -> Array:
	return ContractManager.claimable_contracts + ContractManager.active_contract_list

#region Override Functions
func build_panel():
	for child in container.get_children() + extra_container.get_children():
		child.queue_free()
	
	for idx in range(get_items().size()):
		var item = get_items()[idx]
		var overview_instance = overview_card_scene.instantiate()
		container.add_child(overview_instance)
		overview_instance.set_panel(self)
		overview_instance.set_content(item)
		overview_instance.set_index(idx)
	
	for idx in range(get_extra_container_items().size()):
		var item = get_extra_container_items()[idx]
		var extra_overview_instance = extra_overview_card_scene.instantiate()
		extra_container.add_child(extra_overview_instance)
		extra_overview_instance.set_panel(self)
		extra_overview_instance.set_content(item)
		extra_overview_instance.set_index(idx + INDEX_DIVISION_NUMBER)

func open_detail_card(idx: int, initial_center: Vector2):
	if current_detail_card_instance:
		close_detail_card()
	
	open_click_blocker()
	var item
	if idx >= INDEX_DIVISION_NUMBER:
		idx -= INDEX_DIVISION_NUMBER
		item = get_item(idx, get_extra_container_items())
		current_detail_card_instance = extra_detail_card_scene.instantiate()
	else:
		item = get_item(idx)
		current_detail_card_instance = detail_card_scene.instantiate()
	add_child(current_detail_card_instance)
	current_detail_card_instance.set_panel(self)
	current_detail_card_instance.initialize_card(initial_center)
	current_detail_card_instance.set_content(item)
	current_detail_card_instance.open_card()
#endregion
