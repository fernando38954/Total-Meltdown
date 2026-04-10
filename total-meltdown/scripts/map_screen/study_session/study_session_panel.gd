extends DeveloperPanel
class_name StudySessionPanel

func _ready():
	while !SwebokManager.creation_finished:
		await get_tree().process_frame
	build_developer_panel()
	close_click_blocker()

func build_developer_panel():
	for child in developer_container.get_children():
		child.queue_free()
	
	for idx in range(SwebokManager.remaining_chapters.size()):
		var chapter = SwebokManager.remaining_chapters[idx]
		var developer_overview_instance = developer_overview_card_scene.instantiate()
		developer_container.add_child(developer_overview_instance)
		developer_overview_instance.set_panel(self)
		developer_overview_instance.set_content(chapter)
		developer_overview_instance.set_meta("chapter_index", idx)

func open_developer_detail(idx: int, initial_center: Vector2):
	if developer_detail_card_instance:
		close_developer_detail()
	
	open_click_blocker()
	var chapter = SwebokManager.remaining_chapters[idx]
	developer_detail_card_instance = developer_detail_card_scene.instantiate()
	add_child(developer_detail_card_instance)
	developer_detail_card_instance.set_panel(self)
	developer_detail_card_instance.initialize_card(initial_center)
	developer_detail_card_instance.set_content(chapter)
	developer_detail_card_instance.open_card()
