extends BaseItemPanel
class_name SelectorPanel

@export var second_overview_card_scene: PackedScene
@export var second_detail_card_scene: PackedScene
var option_type: OptionBox.OptionType = OptionBox.OptionType.Pattern

func set_option_type(new_type: OptionBox.OptionType):
	option_type = new_type
	build_panel()

func get_items():
	if option_type == OptionBox.OptionType.Pattern:
		return SwebokManager.owned_chapters
	elif option_type == OptionBox.OptionType.Developer:
		return DeveloperManager.idle_developers
	else:
		push_error("Unknown Option Type in Selector Panel: ", option_type)
		return {}

func _ready_prerequisites():
	while !SwebokManager.creation_finished or !DeveloperManager.creation_finished:
		await get_tree().process_frame

#region Override Functions
func build_panel():
	for child in container.get_children():
		child.queue_free()
	
	for idx in range(get_items().size()):
		var item = get_items()[idx]
		var overview_instance
		if option_type == OptionBox.OptionType.Pattern:
			overview_instance = overview_card_scene.instantiate()
		elif option_type == OptionBox.OptionType.Developer:
			overview_instance = second_overview_card_scene.instantiate()
		container.add_child(overview_instance)
		overview_instance.set_panel(self)
		overview_instance.set_content(item)
		overview_instance.set_index(idx)

func open_detail_card(idx: int, initial_center: Vector2):
	if current_detail_card_instance:
		close_detail_card()
	
	open_click_blocker()
	var item = get_item(idx)
	if option_type == OptionBox.OptionType.Pattern:
		current_detail_card_instance = detail_card_scene.instantiate()
	elif option_type == OptionBox.OptionType.Developer:
		current_detail_card_instance = second_detail_card_scene.instantiate()
	add_child(current_detail_card_instance)
	current_detail_card_instance.set_panel(self)
	current_detail_card_instance.initialize_card(initial_center)
	current_detail_card_instance.set_content(item)
	current_detail_card_instance.open_card()
#endregion
