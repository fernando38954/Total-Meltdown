extends Area2D
class_name Region

@export var workspace: Workspace
@export var left_region: Region = null
@export var right_region: Region = null

@export_category("Setting")
@export var focus: Marker2D   # posição global predeterminada do zoom
@export var zoom_level: float = 2.0
@export var duration: float = 0.3
@export var indicator: Sprite2D = null

func _ready() -> void:
	indicator.hide()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		workspace.switch_region(self)
		indicator.hide()

func _on_mouse_entered() -> void:
	if workspace.current_region == null:
		indicator.show()

func _on_mouse_exited() -> void:
	indicator.hide()
