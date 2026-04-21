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

@export_category("Game Map Screen")
@export var map_screen: MapScreen
@export var map_screen_region: Region

@export_category("Button")
@export var left_button: TextureButton
@export var right_button: TextureButton
@export var return_button: TextureButton

@export_category("SFX")
@export var screen_open_SFX: AudioStream
@export var screen_button_SFX: AudioStream

@export_category("BGM")
@export var main_BGM: AudioStream

func _ready() -> void:
	left_button.hide()
	right_button.hide()
	return_button.hide()
	AudioManager.play_bgm(main_BGM)

func switch_region(region: Region):
	if current_region == region:
		return
	if current_region == null:
		AudioManager.play_sfx(screen_open_SFX)
	
	await check_close_screen()
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
	
	if current_region == map_screen_region:
		await workspace_camera.zoom_finished
		map_screen.disable_event_blocker()

func check_close_screen():
	if current_region == swebok_region:
		swebok.close_book()
	
	if current_region == developer_screen_region:
		developer_screen.close_panel(0.3)
	
	if current_region == map_screen_region:
		map_screen.close_event_screen()
		map_screen.enable_event_blocker()


func _on_return_button_pressed() -> void:
	AudioManager.play_sfx(screen_button_SFX)
	await check_close_screen()
	current_region = null
	return_button.hide()
	left_button.hide()
	right_button.hide()
	workspace_camera.return_default_setting()


func _on_left_button_pressed() -> void:
	AudioManager.play_sfx(screen_button_SFX)
	await check_close_screen()
	switch_region(current_region.left_region)


func _on_right_button_pressed() -> void:
	AudioManager.play_sfx(screen_button_SFX)
	await check_close_screen()
	switch_region(current_region.right_region)
