extends BaseOverviewCard
class_name DeveloperOverviewCard

@onready var portrait = $Portrait
@onready var developer_name = $DeveloperName

@export_category("JobMark")
@onready var job_mark = $JobMark
@export var job_finished_sprite: Texture
@export var job_ongoing_sprite: Texture

func set_content(item_key: String):
	var item_data = DeveloperManager.get_developer_by_key(item_key)
	developer_name.text = "%s" % [item_data.name]
	portrait.texture = item_data.portrait
	if item_key in DeveloperManager.working_developers:
		job_mark.texture = job_ongoing_sprite
	elif item_key in DeveloperManager.resting_developers:
		job_mark.texture = job_finished_sprite
	else:
		job_mark.texture = null
