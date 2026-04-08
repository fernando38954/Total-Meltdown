extends Sprite2D
class_name Workspace

@export var workspace_camera: WorkspaceCamera
var current_region: Region = null

@export_category("Swebok")
@export var swebok: Swebok
@export var swebok_region: Region

@export_category("Developer Screen")
@export var developer_screen: DeveloperScreen
@export var developer_screen_region: Region

@export_category("Button")
@export var left_button: TextureButton
@export var right_button: TextureButton
@export var return_button: TextureButton

func _ready() -> void:
	left_button.hide()
	right_button.hide()
	return_button.hide()

func switch_region(region: Region):
	current_region = region
	return_button.show()
	left_button.set_visible(region.left_region != null)
	right_button.set_visible(region.right_region != null)
	
	workspace_camera.zoom_to_point(region.focus.global_position, region.zoom_level * Vector2.ONE)
	
	if current_region == swebok_region:
		await workspace_camera.zoom_finished
		swebok.open_book()
	
	if current_region == developer_screen_region:
		await workspace_camera.zoom_finished
		developer_screen.open_panel()

func check_close_swebok():
	if current_region == swebok_region:
		swebok.close_book()
		await swebok.move_animation_finished
	
	if current_region == developer_screen_region:
		developer_screen.close_panel()
		await developer_screen.rescale_animation_finished


func _on_return_button_pressed() -> void:
	await check_close_swebok()
	current_region = null
	return_button.hide()
	left_button.hide()
	right_button.hide()
	workspace_camera.return_default_setting()


func _on_left_button_pressed() -> void:
	await check_close_swebok()
	switch_region(current_region.left_region)


func _on_right_button_pressed() -> void:
	await check_close_swebok()
	switch_region(current_region.right_region)
