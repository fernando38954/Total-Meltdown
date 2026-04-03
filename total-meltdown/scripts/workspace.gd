extends Sprite2D
class_name Workspace

@export var workspace_camera: Camera2D
var current_region: Region = null

@export_category("Button")
@export var left_button: TextureButton
@export var right_button: TextureButton
@export var return_button: TextureButton

func switch_region(region: Region):
	current_region = region
	return_button.show()
	left_button.set_visible(region.left_region != null)
	right_button.set_visible(region.right_region != null)
	
	workspace_camera.zoom_to_point(region.focus.global_position, region.zoom_level * Vector2.ONE)


func _on_return_button_button_down() -> void:
	current_region = null
	return_button.hide()
	left_button.hide()
	right_button.hide()
	workspace_camera.return_default_setting()


func _on_left_button_button_down() -> void:
	switch_region(current_region.left_region)


func _on_right_button_button_down() -> void:
	switch_region(current_region.right_region)
