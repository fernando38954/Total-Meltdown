extends Node

var game_timer: Timer
var timer_delta_time: float = 1.0
var current_developer_price = 10.0
var current_pattern_price = 10.0

# Player Status
var money: float = 0
var remaining_contract: int = 5

func initialize():
	money = 50
	remaining_contract = 5
	current_developer_price = 10.0
	current_pattern_price = 10.0

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

func contract_done():
	remaining_contract -= 1
	GlobalSignal.emit_signal("contract_value_changed")
	if remaining_contract <= 0:
		GlobalSignal.emit_signal("game_finished")

#region Money System
func change_money(value: float):
	money += value
	GlobalSignal.emit_signal("money_value_changed")

func pay_developer_price():
	change_money(-1 * current_developer_price)
	current_developer_price += 10

func pay_pattern_price():
	change_money(-1 * current_pattern_price)
	current_pattern_price += 10
#endregion
