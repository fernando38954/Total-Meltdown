extends Node
class_name ContractData

var quest_data: Dictionary
var pattern_data: Dictionary
var developers_data: Array
var total_attribute: Dictionary
var base_money_reward: int = 0
var progress: float
var progress_per_update: float = 10

func _init(p_quest_data, p_pattern_data, p_developers_data, p_total_attribute):
	quest_data = p_quest_data
	pattern_data = p_pattern_data
	developers_data = p_developers_data.duplicate()
	total_attribute = p_total_attribute
	base_money_reward = 100
	progress = 0

func update_quest():
	progress = clamp(progress + progress_per_update, 0.0, 100.0)
	if progress >= 100.0:
		ContractManager.mark_contract_claimable(self)

func calculate_compatibility() -> float:
	var total_quest_attribute = 0.0
	for attribute_value in quest_data.attribute.values():
		total_quest_attribute += attribute_value
	
	var total_penalty = 0.0
	for stat_name in quest_data.attribute.keys():
		var required_attribute = quest_data.attribute[stat_name]
		var current_attribute = total_attribute[stat_name]
		if current_attribute < required_attribute:
			var deficit_ratio = (required_attribute - current_attribute) / required_attribute
			var attribute_weight = required_attribute / total_quest_attribute
			total_penalty += attribute_weight * deficit_ratio
	
	var compatibility = max(0.0, 1.0 - total_penalty)
	return compatibility
