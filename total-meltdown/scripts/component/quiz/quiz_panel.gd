extends CanvasLayer
class_name QuizPanel

enum QuizType {
	Normal, Bug
}

const appearance_list: Dictionary[String, QuizAppearance] = {
	"Normal": preload("res://assets/resource/quiz_appearance/normal_quiz.tres"),
	"Bug": preload("res://assets/resource/quiz_appearance/bug_quiz.tres"),
}

@onready var panel = $Panel
@onready var question = $Panel/Question
@onready var option_container = $Panel/AspectRatioContainer/OptionContainer
@onready var return_button = $Panel/ReturnButton
var appearance: QuizAppearance
var question_list: Array[Dictionary] = []
var current_question_idx: int = 0

var quiz_type: QuizType
var response_key: String = ""
var correct_counter: int = 0
var tween: Tween

func _ready() -> void:
	panel.scale = Vector2.ZERO
	correct_counter = 0
	return_button.hide()
	open_panel()

func set_quiz(_quiz_type: QuizType, _question_list: Dictionary, _response_key: String):
	quiz_type = _quiz_type
	response_key = _response_key
	appearance = appearance_list["Normal"] if quiz_type == QuizType.Normal else appearance_list["Bug"]
	for question_entry in _question_list.values():
		question_list.append(question_entry)
	current_question_idx = 0
	
	panel.texture = appearance.panel
	for option in option_container.get_children():
		option.texture_normal = appearance.option_normal
		option.texture_disabled = appearance.option_normal
		option.texture_hover = appearance.option_hover
	
	if quiz_type == QuizType.Bug:
		ContractManager.set_contract_bug_trying(response_key, true)
	set_content(0)

func set_content(question_idx: int):
	if question_idx >= question_list.size():
		push_error("ERROR: question index %d exceed question list limit" % question_idx)
		return
	
	current_question_idx = question_idx
	var question_data = question_list[current_question_idx]
	question.text = question_data.description
	var correct_choice = question_list[current_question_idx].choices["correct"]
	var choice_texts = question_list[current_question_idx].choices.values()
	var options = option_container.get_children()
	choice_texts.shuffle()
	for i in range(3):
		options[i].set_content(choice_texts[i], choice_texts[i] == correct_choice, self)

func disable_all_options():
	for option in option_container.get_children():
		option.set_disabled(true)

func choice_answer(answer_is_correct: bool):
	# Check if answer is correct
	if answer_is_correct:
		correct_counter += 1
	else:
		for option in option_container.get_children():
			if option.is_correct:
				option.show_mark(true)
	
	# Check if quiz continues
	if current_question_idx + 1 < question_list.size():
		set_content(current_question_idx + 1)
	else:
		return_button.show()
		disable_all_options()
		if quiz_type == QuizType.Bug:
			ContractManager.set_contract_bug_trying(response_key, false)
			if answer_is_correct:
				ContractManager.contract_bug_resolved(response_key)
			else:
				ContractManager.contract_bug_tried(response_key)

#region Animation
func rescale_panel(target_panel_scale: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		return
	
	tween = create_tween().set_parallel()
	tween.tween_property(panel, "scale", target_panel_scale, duration)

func close_panel(duration: float = 0.5):
	rescale_panel(Vector2.ZERO, duration)
	await tween.finished
	queue_free()

func open_panel(duration: float = 0.5):
	rescale_panel(Vector2(0.8, 0.8), duration)
#endregion

func _on_click_blocker_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if quiz_type == QuizType.Bug:
			ContractManager.set_contract_bug_trying(response_key, false)
			close_panel()

func _on_return_button_pressed() -> void:
	close_panel()
