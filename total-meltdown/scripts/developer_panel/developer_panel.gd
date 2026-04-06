extends Panel
class_name DeveloperPanel

@onready var developer_container = $ScrollContainer/GridContainer
@export var developer_overview_card_scene: PackedScene
@export var developer_detail_card_scene: PackedScene
@export var swebok: Swebok = null

func _ready():
	while !DeveloperManager.creation_finished:
		await get_tree().process_frame
	build_developer_panel()

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

func open_developer_detail(idx: int):
	var developer = DeveloperManager.developers[idx]
	var developer_detail_instance = developer_detail_card_scene.instantiate()
	add_child(developer_detail_instance)
	developer_detail_instance.set_content(developer)
