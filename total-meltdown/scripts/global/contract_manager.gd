extends Node

const REWARD_POPUP_SCENE = preload("res://scenes/component/RewardPopup.tscn")

var awaked_contracts: Dictionary = {}
var active_contract_list: Array[String]
var claimable_contracts: Array[String]
var completed_contracts: Array[String]

#region Array Operation
func get_contract_by_key(key: String) -> ContractData:
	return awaked_contracts.get(key, null)

func start_contract(quest_key: String, pattern_key: String, developer_data_list: Array, total_attribute: Dictionary):
	QuestManager.start_quest(quest_key)
	DeveloperManager.assign_work(developer_data_list)
	var new_contract = ContractData.new(quest_key, pattern_key, developer_data_list, total_attribute)
	awaked_contracts[quest_key] = new_contract
	active_contract_list.append(quest_key)
	GlobalSignal.emit_signal("contract_list_changed", quest_key)

func mark_contract_claimable(target_contract_key: String):
	if target_contract_key in active_contract_list:
		active_contract_list.erase(target_contract_key)
		claimable_contracts.append(target_contract_key)
		var contract_data = get_contract_by_key(target_contract_key)
		DeveloperManager.finish_work(contract_data.developers_key)
		GlobalSignal.emit_signal("contract_list_changed", target_contract_key)
	else:
		push_error("mark_contract_claimable: No contract with quest key " + target_contract_key + " found in active_contract_list")

func claim_contract(target_contract_key: String) -> void:
	if target_contract_key in claimable_contracts:
		var contract_data = get_contract_by_key(target_contract_key)
		claimable_contracts.erase(target_contract_key)
		give_reward(contract_data)
		completed_contracts.append(target_contract_key)
		QuestManager.complete_quest(contract_data.quest_key)
		DeveloperManager.return_idle(contract_data.developers_key)
		awaked_contracts.erase(target_contract_key)
		GlobalSignal.emit_signal("contract_list_changed", target_contract_key)
	else:
		push_error("claim_contract: No contract with quest key " + target_contract_key + " found in claimable_contracts")
#endregion

func _ready() -> void:
	GlobalSignal.timer_update.connect(update_contracts)
	GlobalSignal.game_start.connect(initialize)

func initialize():
	active_contract_list.clear()
	claimable_contracts.clear()
	completed_contracts.clear()

func update_contracts() -> void:
	for contract in active_contract_list:
		get_contract_by_key(contract).update_quest()

func give_reward(target_contrat_data: ContractData):
	var profit = target_contrat_data.base_reward * target_contrat_data.calculate_reward_multiplier()
	profit = round(profit)
	GlobalResource.change_money(profit)
	var reward_popup = REWARD_POPUP_SCENE.instantiate()
	get_tree().root.add_child(reward_popup)
	reward_popup.show_reward(target_contrat_data, profit)
