extends RichTextLabel
class_name AutoTypingRichTextLabel

signal typing_finished()

@onready var text_label: RichTextLabel = self
@onready var typing_timer: Timer = $TypingTimer

@export_category("Auto Typing Settings")
@export_multiline  var auto_typing_text: String = ""
@export var typing_speed: float = 0.05
@export var auto_start: bool = false

@export_category("SFX")
@export var text_typing_SFX : AudioStream

var is_typing: bool = false
var stop_requested: bool = false

func _ready() -> void:
	if auto_start and not auto_typing_text.is_empty():
		start_typing()

func start_typing(target_text: String = auto_typing_text) -> void:
	auto_typing_text = target_text
	is_typing = true
	stop_requested = false
	text_label.text = ""
	AudioManager.play_sfx(text_typing_SFX)
	
	for letter in auto_typing_text:
		if stop_requested:
			return
		text_label.text += letter
		await wait_timer(typing_speed)
	
	is_typing = false
	typing_finished.emit()
	AudioManager.stop_sfx()

func wait_timer(second: float):
	typing_timer.start(second)
	await typing_timer.timeout

func skip_typing() -> void:
	is_typing = false
	stop_requested = true
	text = auto_typing_text
	typing_finished.emit()
	AudioManager.stop_sfx()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		skip_typing()
