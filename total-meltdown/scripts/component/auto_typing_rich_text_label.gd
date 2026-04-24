extends RichTextLabel

@onready var text_label: RichTextLabel = self
@onready var typing_timer: Timer = $TypingTimer
@export var label_size: int

func _ready() -> void:
	text_label.add_theme_font_size_override("normal_font_size", label_size)

func play_text_typing(json_file_path: String) -> void:
	var json_data = get_json_data(json_file_path)
	for part in json_data.values():
		text_label.text = ""
		for paragraph in part.values():
			for letter in paragraph:
				text_label.text += letter
				await wait_timer(0.05)
			text_label.text += "\n"
			await wait_timer(1)
		await wait_timer(2)

func get_json_data(json_file_path: String):
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var file_data = null
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			file_data = json.data
	else:
		push_error("Failed to parse JSON：", json_file_path)
	file.close()
	return file_data

func wait_timer(second: float):
	typing_timer.start(second)
	await typing_timer.timeout
