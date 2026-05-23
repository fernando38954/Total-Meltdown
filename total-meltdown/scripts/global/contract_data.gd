extends Node
class_name ContractData

#region Constants
const time_per_difficult = {
	"easy": 10,
	"medium": 15,
	"hard": 20
}

const bug_probability_per_difficulty = {
	"easy": 0.2,
	"medium": 0.5,
	"hard": 0.8
}
#endregion

var quest_key: String
var pattern_key: String
var developers_key: Array
var total_attribute: Dictionary
var base_reward: int = 0
var pattern_satisfied: bool = false
var attribute_compatibility: float = 0.0
var progress: float = 0
var progress_per_update: float = 10

# Bug mechanics
var has_bug: bool = false
var bug_active: bool = false
var bug_solve_trying: bool = false
var bug_solve_tried: bool = false
var bug_occur_progress_required: float = 0.0
var bug_resolve_time_countdown: int = 0

#region Initialization
func _init(_quest_key, _pattern_key, _developers_key, _total_attribute):
	quest_key = _quest_key
	pattern_key = _pattern_key
	developers_key = _developers_key.duplicate()
	total_attribute = _total_attribute
	attribute_compatibility = calculate_compatibility()
	progress_per_update = ceil(100.0 / calculate_contract_second())
	
	var quest_data = QuestManager.get_quest_by_key(_quest_key)
	base_reward = quest_data.base_reward
	for required_pattern_key in quest_data.requirements.values():
		if _pattern_key == required_pattern_key:
			pattern_satisfied = true
			break
	
	setup_bug()

func calculate_contract_second() -> int:
	var time_seconds = 0
	var pattern_time_level = PatternManager.get_pattern_by_key(pattern_key).time_level
	var quest_difficult_level = QuestManager.get_quest_by_key(quest_key).difficult.to_lower()
	time_seconds = time_per_difficult.get(quest_difficult_level, 0) * pattern_time_level
	return time_seconds

func setup_bug():
	var quest_difficult_level = QuestManager.get_quest_by_key(quest_key).difficult.to_lower()
	var pattern_time_level = PatternManager.get_pattern_by_key(pattern_key).complexity_level
	if randf() <= bug_probability_per_difficulty.get(quest_difficult_level, 1):
		has_bug = true
		bug_occur_progress_required = randf_range(20, 70)
		bug_resolve_time_countdown = pattern_time_level * 10 * randf_range(1, 2)
#endregion

func update_quest():
	if has_bug and progress > bug_occur_progress_required and bug_resolve_time_countdown > 0:
		bug_active = true
		if not bug_solve_trying:
			bug_resolve_time_countdown -= 1
		return
	bug_active = false
	progress = clamp(progress + progress_per_update, 0.0, 100.0)
	if progress >= 100.0:
		ContractManager.mark_contract_claimable(quest_key)

func bug_solved():
	bug_active = false
	bug_resolve_time_countdown = 0
	progress = clamp(progress + 10, 0.0, 100.0)

#region Reward
func calculate_reward_multiplier() -> float:
	var bonus = 0.2 if pattern_satisfied else 0.0
	return attribute_compatibility * 0.8 + bonus

func calculate_compatibility() -> float:
	var total_quest_attribute = 0.0
	var quest_data = QuestManager.get_quest_by_key(quest_key)
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
#endregion
