extends BaseDetailCard
class_name ContractDetailCard

@onready var quest_title = $QuestTitle
@onready var icon = $QuestIcon
@onready var bullet_points = $BulletPoints
@onready var description = $Description
@onready var footnote = $Footnote
@onready var radar_chart = $RadarChart
@onready var progress_bar = $ProgressBar
@onready var claimable_notification = $ProgressBar/ClaimLabel
@onready var developement_container = $DevelopementContainer

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25

var current_contract_data = null

func _ready() -> void:
	claimable_notification.hide()
	GlobalSignal.timer_update.connect(update_progress)

func set_content(item_data: Variant):
	current_contract_data = item_data
	quest_title.text = item_data.quest_data.title
	icon.texture = item_data.quest_data.icon
	
	bullet_points.text = "[ul]\n"
	for value in item_data.quest_data.bullet_point.values():
		bullet_points.text += value + "\n"
	bullet_points.text += "[/ul]"
	
	var paragraphs = []
	for value in item_data.quest_data.description.values():
		paragraphs.append(value)
	description.text = "\n\n".join(paragraphs)
	
	footnote.text = item_data.quest_data.footnote
	
	radar_chart.set_label(font, font_size, value_font_size)
	radar_chart.set_attributes(item_data.total_attribute)
	
	progress_bar.value = item_data.progress
	progress_bar.self_modulate = Color(0, 0.5, 0) if progress_bar.value >= 100 else Color(0.8, 0, 0)
	if ContractManager.claimable_contracts.has(current_contract_data):
		claimable_notification.show()
	
	for child in developement_container.get_children():
		child.queue_free()
		
	var pattern_rect = new_texture_rect()
	pattern_rect.texture = item_data.pattern_data.icon
	developement_container.add_child(pattern_rect)
	for developer_entry in item_data.developers_data:
		var developer_rect = new_texture_rect()
		developer_rect.texture = developer_entry.portrait
		developement_container.add_child(developer_rect)

func new_texture_rect() -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(400.0, 400.0)
	return texture_rect

func update_progress():
	if current_contract_data == null:
		return
	else:
		progress_bar.value = current_contract_data.progress
		if progress_bar.value >= 100:
			progress_bar.self_modulate = Color(0, 0.5, 0)
		if ContractManager.claimable_contracts.has(current_contract_data):
			claimable_notification.show()


func _on_progress_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ContractManager.claim_contract(current_contract_data)
		close_card(0.2, Callable(panel, "close_detail_card"))
		panel.build_panel()
