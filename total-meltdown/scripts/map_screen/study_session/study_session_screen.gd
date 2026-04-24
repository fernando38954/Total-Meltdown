extends BaseScreen
class_name StudySessionScreen

@export var current_pattern_price_label: RichTextLabel

func set_content(studiable_patterns_list: Array):
	current_pattern_price_label.text = "Preço de Estudo: [color=yellow]%.2f[/color]" % GlobalResource.current_pattern_price
	panel.set_studiable_list(studiable_patterns_list)
