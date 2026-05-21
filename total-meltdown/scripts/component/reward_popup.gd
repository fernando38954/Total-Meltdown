extends CanvasLayer
class_name RewardPopup

@onready var report = $Report
@onready var quest_name = $Report/QuestName
@onready var quest_description = $Report/Description
@onready var quest_icon = $Report/Icon
@onready var radar_chart = $Report/RadarChart
@onready var developer_container = $Report/AspectRatioContainer/DeveloperContainer
@onready var recipe = $Recipe
@onready var reward_description = $Recipe/Description

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font

var tween: Tween

#region Animation
func rescale_panel(target_report_scale: Vector2, target_recipe_scale: Vector2, target_recipe_modulate: Color, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween().set_parallel()
	tween.tween_property(report, "scale", target_report_scale, duration)
	tween.tween_property(recipe, "scale", target_recipe_scale, duration/2).set_delay(duration/2)
	tween.tween_property(recipe, "modulate", target_recipe_modulate, duration/2).set_delay(duration/2)

func close_panel(duration: float = 0.5):
	rescale_panel(Vector2.ZERO, Vector2.ONE * 2, Color.TRANSPARENT, duration)

func open_panel(duration: float = 0.5):
	rescale_panel(Vector2.ONE, Vector2.ONE, Color.WHITE, duration)
#endregion

func _ready() -> void:
	report.scale = Vector2.ZERO
	recipe.scale = Vector2.ONE * 2
	recipe.modulate = Color.TRANSPARENT
	for developer_rect in developer_container.get_children():
		developer_rect.queue_free()
	open_panel()

func show_reward(contract_data: ContractData, final_profit: float) -> void:
	var quest_data = QuestManager.get_quest_by_key(contract_data.quest_key)
	quest_name.text = quest_data.title
	quest_description.text =  "\n".join(quest_data.description.values())
	quest_icon.texture = quest_data.icon
	radar_chart.set_label_font(font)
	radar_chart.set_attributes(quest_data.attribute, contract_data.total_attribute)
	reward_description.text = generate_reward_description(contract_data, final_profit)

	for developer_key in contract_data.developers_key:
		var developer_data = DeveloperManager.get_developer_by_key(developer_key)
		var developer_rect = new_texture_rect()
		developer_rect.texture = developer_data.portrait
		developer_container.add_child(developer_rect)

func new_texture_rect() -> TextureRect:
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(300.0, 030.0)
	return texture_rect

func generate_reward_description(contract_data: ContractData, final_profit: float) -> String:
	var description_text = "Lucro básico: %.2f\n" % contract_data.base_money_reward
	description_text += "Multiplicador: %.2f\n" % contract_data.calculate_compatibility()
	description_text += "Lucro final: %.2f" % final_profit
	return description_text

func _on_click_blocker_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_panel()
		await tween.finished
		queue_free()
