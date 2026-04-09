extends DeveloperPanel
class_name JobFairPanel

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
