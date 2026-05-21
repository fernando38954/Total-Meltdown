extends Node

var game_timer: Timer
var timer_delta_time: float = 1.0

# Player Status
var money: float = 0

func initialize():
	money = 50

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
