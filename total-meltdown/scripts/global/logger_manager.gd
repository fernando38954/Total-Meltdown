extends Node
const LOG_FILE_NAME := "study_log.json"
const ID_LENGTH := 8

var session_id: String = ""
var session_started_at: String = ""
var recorded_actions: Array = []

func _ready() -> void:
	GlobalSignal.game_start.connect(initialize)

func initialize() -> void:
	var timestamp := Time.get_datetime_dict_from_system()
	session_started_at = format_datetime(timestamp)
	session_id = generate_random_id(ID_LENGTH)
	recorded_actions.clear()

#region Auxiliary Function
func get_log_path() -> String:
	return OS.get_executable_path().get_base_dir() + "/" + LOG_FILE_NAME

func format_datetime(datetime: Dictionary) -> String:
	var year: int = datetime.get("year", 2000)
	var month: int = datetime.get("month", 1)
	var day: int = datetime.get("day", 1)
	var hour: int = datetime.get("hour", 0)
	var minute: int = datetime.get("minute", 0)
	var second: int = datetime.get("second", 0)
	return "%02d-%02d-%04d %02d:%02d:%02d" % [day, month, year, hour, minute, second]

func generate_random_id(length: int) -> String:
	const CHARSET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var result := ""
	for i in range(length):
		var random_index := randi() % CHARSET.length()
		result += CHARSET[random_index]
	return result
#endregion

func record_action(action_name: String, details: Dictionary = {}, category: String = "gameplay") -> Dictionary:
	var payload: Dictionary = {
		"timestamp": format_datetime(Time.get_datetime_dict_from_system()),
		"unix_time": Time.get_unix_time_from_system(),
		"session_id": session_id,
		"action": action_name,
		"category": category,
		"details": details,
		"platform": OS.get_name(),
	}
	recorded_actions.append(payload)
	return payload

func save_now() -> bool:
	var readable_content = generate_readable_log()
	var success = write_log_file(readable_content)
	return success

func write_log_file(json_string: String) -> bool:
	if OS.get_name() == "Web":
		_download_json_in_browser(json_string)
		return true

	var file := FileAccess.open(get_log_path(), FileAccess.WRITE)
	if file == null:
		push_error("LoggerManager: Unable to save log file at %s. Error: %s" % [get_log_path(), FileAccess.get_open_error()])
		return false

	file.store_string(json_string)
	file.close()
	return true

func _download_json_in_browser(json_string: String) -> void:
	if OS.get_name() != "Web":
		push_warning("LoggerManager: Browser download is only available in the web export.")
		return

	var script := (
		"window.savePlayerLog = function(filename, text) { "
		+ "const blob = new Blob([text], { type: 'application/json;charset=utf-8' }); "
		+ "const url = URL.createObjectURL(blob); "
		+ "const a = document.createElement('a'); "
		+ "a.href = url; "
		+ "a.download = filename; "
		+ "document.body.appendChild(a); "
		+ "a.click(); "
		+ "a.remove(); "
		+ "setTimeout(function() { URL.revokeObjectURL(url); }, 0); "
		+ "}; "
		+ "window.savePlayerLog(%s, %s);" % [JSON.stringify(LOG_FILE_NAME), JSON.stringify(json_string)]
	)
	JavaScriptBridge.eval(script)

func generate_readable_log() -> String:
	var content := ""
	content += "=== PLAYER ACTION LOG ===\n"
	content += "Session ID: %s\n" % session_id
	content += "Started at: %s\n" % session_started_at
	content += "Platform: %s\n" % OS.get_name()
	content += "Total Actions: %d\n" % recorded_actions.size()
	content += "\n"
	
	var separator = "-".repeat(80)
	for i in range(recorded_actions.size()):
		var action = recorded_actions[i]
		content += separator + "\n"
		content += "[%d] %s\n" % [i + 1, action.get("action", "Unknown")]
		content += "Time: %s | Category: %s\n" % [action.get("timestamp", "N/A"), action.get("category", "N/A")]
		
		var details = action.get("details", {})
		if typeof(details) == TYPE_DICTIONARY and details.size() > 0:
			for key in details.keys():
				var value = details[key]
				content += "  • %s: %s\n" % [key, str(value)]
		content += "\n"
	
	content += separator + "\n"
	return content
