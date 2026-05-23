extends TextureButton

@onready var description = $Description
@onready var answer_mark = $AnswerMark

@export var correct_mark: Texture
@export var wrong_mark: Texture

var panel: QuizPanel
var is_correct: bool = false

func set_content(_description: String, _is_correct: bool, _panel: QuizPanel):
	description.text = _description
	is_correct = _is_correct
	panel = _panel
	answer_mark.texture = null

func show_mark(is_correct_mark: bool):
	if is_correct_mark:
		answer_mark.texture = correct_mark
	else:
		answer_mark.texture = wrong_mark
		print("wrong answer")

func _on_pressed() -> void:
	panel.choice_answer(is_correct)
	show_mark(is_correct)
