extends Node

var active_contract_list: Array[ContractData]
var claimable_contracts: Array[ContractData]
var completed_contracts: Array[ContractData]

#region Array Operation
func start_contract(quest_data: Dictionary, pattern_data: Dictionary, developer_data_list: Array, total_attribute: Dictionary):
	QuestManager.start_quest(quest_data)
	DeveloperManager.assign_work(developer_data_list)
	var new_contract = ContractData.new(quest_data, pattern_data, developer_data_list, total_attribute)
	active_contract_list.append(new_contract)

func mark_contract_claimable(target_contrat_data: ContractData):
	if target_contrat_data in active_contract_list:
		active_contract_list.erase(target_contrat_data)
		claimable_contracts.append(target_contrat_data)
	else:
		push_error("mark_contract_claimable: No contract with quest filename " + target_contrat_data.quest_data.file_name + " found in active_contract_list")

func claim_contract(target_contrat_data: ContractData) -> void:
	if target_contrat_data in claimable_contracts:
		claimable_contracts.erase(target_contrat_data)
		give_reward(target_contrat_data)
		completed_contracts.append(target_contrat_data)
	else:
		push_error("claim_contract: No contract with quest filename " + target_contrat_data.quest_data.file_name + " found in claimable_contracts")
#endregion

func _ready() -> void:
	GlobalSignal.timer_update.connect(update_contracts)

func update_contracts() -> void:
	for contract in active_contract_list:
		contract.update_quest()

func give_reward(target_contrat_data: ContractData):
	var profit = target_contrat_data.base_money_reward * target_contrat_data.calculate_compatibility()
	GlobalResource.change_money(profit)
