extends BaseOverviewCard
class_name ContractOverviewCard

@onready var quest_title = $QuestTitle
@onready var progress_bar = $ProgressBar
@onready var icon = $QuestIcon
@onready var developer_container = $HBoxContainer

var current_contract_data = null

func _ready() -> void:
	GlobalSignal.timer_update.connect(update_progress)

func set_content(item_data: Variant) -> void:
	current_contract_data = item_data
	quest_title.text = item_data.quest_data.title
	icon.texture = item_data.quest_data.icon
	progress_bar.value = item_data.progress
	progress_bar.self_modulate = Color(0, 0.5, 0) if progress_bar.value >= 100 else Color(0.8, 0, 0)
	
	for child in developer_container.get_children():
		child.queue_free()
	for developer_entry in item_data.developers_data:
		var developer_rect = TextureRect.new()
		developer_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		developer_rect.custom_minimum_size = Vector2(360.0, 360.0)
		developer_rect.texture = developer_entry.portrait
		developer_container.add_child(developer_rect)

func update_progress():
	if current_contract_data == null:
		return
	else:
		progress_bar.value = current_contract_data.progress
		if progress_bar.value >= 100:
			progress_bar.self_modulate = Color(0, 0.5, 0)
