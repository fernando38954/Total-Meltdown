extends BaseScreen
class_name JobFairScreen

@export var current_developer_price_label: RichTextLabel

func set_content(recruitable_developers_list: Array):
	current_developer_price_label.text = "Preço de Contratação: [color=yellow]%.2f[/color]" % GlobalResource.current_developer_price
	panel.set_recruitable_list(recruitable_developers_list)
