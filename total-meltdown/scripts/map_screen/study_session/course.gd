extends TextureButton
class_name StudySessionCourse

@onready var chapter_title = $PatternName
@onready var description_label = $Description

@export_category("Visual Settings")
@export var title_size: int = 100
@export var description_size: int = 80

var study_session_panel: DeveloperPanel = null
var course_chapter_data = null

func set_panel(panel: DeveloperPanel):
	study_session_panel = panel

func set_content(chapter_data: Dictionary):
	course_chapter_data = chapter_data
	chapter_title.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [title_size, chapter_data.title]
	description_label.text = "[font_size=%d]%s[/font_size]" % [description_size, chapter_data.description]

func get_center_position():
	return global_position + size * 0.5 * scale * study_session_panel.scale

func _on_pressed() -> void:
	study_session_panel.open_developer_detail(self.get_meta("chapter_index"), get_center_position())

func _on_study_button_pressed() -> void:
	GlobalSignal.emit_signal("study_chapter", course_chapter_data.file_name)
