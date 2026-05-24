extends AspectRatioContainer
class_name AwakedContractPanel

@export var map_screen: MapScreen
@onready var contract_panel = $ContractContainer
@export var contract_progress_bar_scene: PackedScene

func _ready() -> void:
	GlobalSignal.contract_list_changed.connect(update_contract_panel)
	for progress_bar in contract_panel.get_children():
		progress_bar.queue_free()

func update_contract_panel(contract_key):
	if contract_key in ContractManager.active_contract_list:
		var progress_bar_instance = contract_progress_bar_scene.instantiate()
		contract_panel.add_child(progress_bar_instance)
		progress_bar_instance.set_map_screen(map_screen)
		progress_bar_instance.set_contract(contract_key)
	elif contract_key in ContractManager.claimable_contracts:
		for progress_bar in contract_panel.get_children():
			if progress_bar.contract_key == contract_key:
				progress_bar.mark_claimable()
				return
	elif contract_key in ContractManager.completed_contracts:
		for progress_bar in contract_panel.get_children():
			if progress_bar.contract_key == contract_key:
				progress_bar.queue_free()
				return

func size():
	return contract_panel.get_children().size()
