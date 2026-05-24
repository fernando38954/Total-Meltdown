extends Node

var game_timer: Timer
var timer_delta_time: float = 1.0
var base_question_reward: int = 30

# Quarter Mechanic
const TOTAL_QUARTER = 4
var current_quarter: int = 0
var developer_quarter_distribution: Array
var pattern_quarter_distribution: Array
var quest_quarter_distribution: Array
var exam_quarter_distribution: Array

# Player Status
var money: int = 0

func initialize():
	money = 50
	current_quarter = 0
	developer_quarter_distribution = [1, 3, 2, -1]
	pattern_quarter_distribution = [1, 2, 2, 2]
	quest_quarter_distribution = [1, 3, 5, 6]
	exam_quarter_distribution = [1, 1, 1, 1]

func _ready():
	game_timer = Timer.new()
	game_timer.wait_time = timer_delta_time
	game_timer.one_shot = false
	game_timer.timeout.connect(_on_timer_timeout)
	add_child(game_timer)
	game_timer.start()
	GlobalSignal.game_start.connect(initialize)

func _on_timer_timeout():
	GlobalSignal.emit_signal("timer_update")

func set_interval(seconds: float):
	timer_delta_time = seconds
	game_timer.wait_time = timer_delta_time

#region Money System
func change_money(value: float):
	money += value
	GlobalSignal.emit_signal("money_value_changed")
#endregion

#region Quarter System
#region Stock Operation
func remaining_developer() -> int:
	if developer_quarter_distribution[current_quarter] < 0:
		return DeveloperManager.locked_developers.size()
	else:
		return developer_quarter_distribution[current_quarter]

func decrease_developer_event_stock():
	developer_quarter_distribution[current_quarter] -= 1

func remaining_pattern() -> int:
	if pattern_quarter_distribution[current_quarter] < 0:
		return PatternManager.locked_patterns[current_quarter].size()
	else:
		return pattern_quarter_distribution[current_quarter]

func decrease_pattern_event_stock():
	pattern_quarter_distribution[current_quarter] -= 1

func remaining_quest() -> int:
	if quest_quarter_distribution[current_quarter] < 0:
		return QuestManager.pending_quests[current_quarter].size()
	else:
		return quest_quarter_distribution[current_quarter]

func decrease_quest_event_stock():
	quest_quarter_distribution[current_quarter] -= 1

func remaining_exams() -> int:
	if exam_quarter_distribution[current_quarter] < 0:
		return ExamManager.unfinished_exams[current_quarter].size()
	else:
		return exam_quarter_distribution[current_quarter]

func decrease_exams_event_stock():
	exam_quarter_distribution[current_quarter] -= 1
#endregion

func proceed_next_quarter():
	await Fade.fade_out().finished
	await Fade.fade_in().finished
	current_quarter += 1
#endregion
