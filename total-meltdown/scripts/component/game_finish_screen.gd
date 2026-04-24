extends Panel
class_name FinishScreen

@onready var developer_label = $DeveloperLabel
@onready var pattern_label = $PatternLabel
@onready var contract_label = $ContractLabel
@onready var money_label = $MoneyLabel
@onready var score_label = $FinalScore

func _ready() -> void:
	scale = Vector2.ZERO

func show_screen():
	set_content()
	show()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func set_content():
	var total_developer = DeveloperManager.idle_developers.size() + DeveloperManager.working_developers.size()
	var total_pattern = PatternManager.owned_patterns.size()
	var total_contract = ContractManager.completed_contracts.size()
	var total_money = GlobalResource.money
	var total_score = (total_developer + total_pattern) * 3 + total_contract * 5 + total_money / 10
	
	developer_label.text = "Número de Desenvolvedores Contratados: %d" % total_developer
	pattern_label.text = "Número de Padrões Aprendidos: %d" % total_pattern
	contract_label.text = "Número de Contratos Resolvidos: %d" % total_contract
	money_label.text = "Quantidade de Dinheiro Adquirido: %.2f" % total_money
	score_label.text = "[color=yellow]Pontuação Final: %.2f[/color]" % total_score


func _on_menu_button_pressed() -> void:
	await Fade.fade_out().finished  
	get_tree().change_scene_to_file("res://scenes/StartMenu.tscn")
	Fade.fade_in()
