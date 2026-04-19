extends CanvasLayer
class_name RewardPopup

@onready var popup_panel = $Popup
@onready var radar_chart = $Popup/RadarChart
@onready var description = $Popup/Description

@export_category("Label Settings")
@export var font = ThemeDB.fallback_font
@export var font_size = 30
@export var value_font_size = 25
@export var label_offset = 18

var open_scale = Vector2(1, 1)
var hide_scale = Vector2(0, 0)
var tween: Tween

#region Animation
func rescale_panel(target_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.tween_property(popup_panel, "scale", target_scale, duration)

func close_panel(duration: float = 0.5):
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	rescale_panel(Vector2.ONE, duration)
#endregion

func _ready() -> void:
	popup_panel.scale = Vector2.ZERO
	open_panel()

func show_reward(contract_data: ContractData, final_profit: float) -> void:
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(contract_data.quest_data.attribute, contract_data.total_attribute)
	var reward_text = generate_reward_description(contract_data, final_profit)
	description.text = reward_text

func generate_reward_description(contract_data: ContractData, final_profit: float) -> String:
	var description_text = "Base Profit: %.2f | Multiplier: %.2f\n" % [contract_data.base_money_reward, contract_data.calculate_compatibility()]
	description_text += "[color=yellow]Final Profit: %.2f[/color]" % final_profit
	return description_text

func _on_confirm_button_pressed() -> void:
	close_panel()
	await tween.finished
	queue_free()

func _on_click_blocker_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_confirm_button_pressed()
