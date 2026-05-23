extends BaseScreen
class_name StudySessionScreen

@onready var pipe_game = $PipeGame 
@onready var game_click_blocker = $GameClickBlocker 

func _ready_prerequisites():
	GlobalSignal.study_pattern.connect(start_game)
	GlobalSignal.minigame_finished.connect(finish_game)
	game_click_blocker.hide()

func set_content(studiable_patterns_list: Array):
	panel.set_studiable_list(studiable_patterns_list)

func start_game(pattern_key):
	pipe_game.generate_and_build_grid(pattern_key)
	pipe_game.open_game()
	game_click_blocker.show()

func finish_game():
	game_click_blocker.hide()
