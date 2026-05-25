extends CanvasLayer
class_name QuarterReport

@onready var report = $Report
@onready var gain_icon = $Report/GainIcon
@onready var quarter_start_money = $Report/StartMoney
@onready var current_money = $Report/CurrentMoney
@onready var total_gain = $Report/TotalGain
@onready var developer_hired = $Report/DeveloperHired
@onready var pattern_learned = $Report/PatternLearned
@onready var exam_bonus = $Report/ExamBonus
@onready var developer_salary = $Report/DeveloperSalary
@onready var final_money = $Report/FinalMoney

@export_category("Icon Settings")
@export var positive_gain_mark: Texture
@export var negative_gain_mark: Texture

@export_category("SFX")
@export var report_close_SFX : AudioStream

var tween: Tween

#region Animation
func rescale_panel(target_report_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween()
	tween.tween_property(report, "scale", target_report_scale, duration)

func close_panel(duration: float = 0.5):
	AudioManager.play_sfx(report_close_SFX)
	rescale_panel(Vector2.ZERO, duration)

func open_panel(duration: float = 0.5):
	rescale_panel(Vector2.ONE, duration)
#endregion

func _ready() -> void:
	report.scale = Vector2.ZERO
	open_panel()

func set_content(content: Dictionary) -> void:
	gain_icon.texture = positive_gain_mark if content.gain_is_positive else negative_gain_mark
	quarter_start_money.text = "$ %d" % content.quarter_start_money
	current_money.text = "$ %d" % content.current_money
	total_gain.text = "$ %d" % content.total_gain
	developer_hired.text = str(content.developer_hired)
	pattern_learned.text = str(content.pattern_learned)
	exam_bonus.text = "$ %d" % content.exam_bonus
	developer_salary.text = "$ %d" % content.developer_salary
	final_money.text = "$ %d" % content.final_money

func _on_click_blocker_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_panel()
		await tween.finished
		GlobalResource.proceed_next_quarter()
		queue_free()
