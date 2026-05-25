extends CanvasLayer
class_name Swebok

signal move_animation_finished

@onready var book_sprite = $AnimatedSprite2D
@onready var content_view = $ContentViewer
@onready var left_button = $LeftButton
@onready var right_button = $RightButton
@onready var click_blocker = $ClickBlocker

@export var open_position = Vector2(2015.0, 1050.0)
@export var hide_position = Vector2(2015.0, 3315.0)
@export var initial_minimize_position = Vector2(-1153.0, 3297.0)
@export var minimize_position = Vector2(-446.0, 2769.0)

@export_category("Catalog")
@export var catalog: Catalog

@export_category("SFX")
@export var flip_page_right_SFX : AudioStream
@export var flip_page_left_SFX : AudioStream

var tween: Tween
var current_page_idx: int
var tutorial_page_qty: int = 0

#region Internal Classes
var BookPage = {
	"close": -5,
	"half_close": -4,
	"opening": -3,
	"turning": -2,
	"catalogPage": -1,
	"homePage": 0
}

enum PageDirection {
	left = -1,
	right = 1
}
#endregion

func _ready():
	BookPage["tutorialPageLimit"] = TutorialPageManager.all_pages.size()
	close_book(0, hide_position, false)
	click_blocker.hide()
	show()

#region Book Action
func move_book(target_position: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(book_sprite, "position", target_position, duration)
	tween.tween_callback(move_animation_finished.emit)

func close_book(duration: float = 0.5, target_position: Vector2 = hide_position, play_animation: bool = true):
	move_book(target_position, duration)
	show_page(BookPage.close)
	if play_animation:
		book_sprite.play_backwards("open_book")
		if duration > 0:
			AudioManager.play_sfx(flip_page_left_SFX)
	else:
		book_sprite.animation = "open_book"
		book_sprite.frame = 0

func minimize_book(duration: float = 0.5, initial_position: Vector2 = book_sprite.position, play_animation: bool = true):
	book_sprite.position = initial_position
	move_book(minimize_position, duration)
	show_page(BookPage.half_close)
	if play_animation:
		book_sprite.play_backwards("open_half_book")
		if duration > 0:
			AudioManager.play_sfx(flip_page_left_SFX)
	else:
		book_sprite.animation = "open_half_book"
		book_sprite.frame = 0

func open_book(duration: float = 0.5, is_half_book: bool = false):
	current_page_idx = BookPage.opening
	book_sprite.position = minimize_position if is_half_book else hide_position
	move_book(open_position, duration)
	
	await move_animation_finished
	if is_half_book:
		book_sprite.play("open_half_book")
		click_blocker.show()
	else:
		book_sprite.play("open_book")
	AudioManager.play_sfx(flip_page_right_SFX)
	await book_sprite.animation_finished
	if current_page_idx == BookPage.opening:
		catalog.update_catalog()
		show_page(BookPage.homePage)

func turn_to_page(target_page_idx: int):
	if target_page_idx == current_page_idx:
		return
	var direction = PageDirection.right if (target_page_idx > current_page_idx) else PageDirection.left
	show_page(BookPage.turning)
	book_sprite.play("turn_page", 1.0 * direction, (direction < 0))
	AudioManager.play_sfx(flip_page_right_SFX if direction == PageDirection.right else flip_page_left_SFX)
	await book_sprite.animation_finished
	if current_page_idx == BookPage.turning:
		show_page(target_page_idx)

func _on_click_blocker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		minimize_book()
		click_blocker.hide()

func _on_minimize_book_region_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_page_idx == BookPage.half_close:
		open_book(0.5, true)
#endregion

#region Book Content
func show_page(page_idx: int):
	current_page_idx = page_idx
	update_page_visibility()
	update_buttons_visibility()
	
	var content_type = ContentViewer.ContentType.Pattern if page_idx >= BookPage.tutorialPageLimit else ContentViewer.ContentType.Tutorial
	var content_key = catalog.marker_list[page_idx].get_meta("key", "Unknown")
	if content_type == ContentViewer.ContentType.Pattern:
		content_view.show_content(PatternManager.get_pattern_by_key(content_key), content_type)
	elif page_idx > BookPage.catalogPage:
		content_view.show_content(TutorialPageManager.get_page_by_key(content_key), content_type)

func update_page_visibility():
	catalog.visible = current_page_idx >= BookPage.turning
	content_view.visible = current_page_idx > BookPage.catalogPage

func update_buttons_visibility():
	if current_page_idx <= BookPage.catalogPage:
		left_button.visible = false
		right_button.visible = false
	else:
		left_button.visible = catalog.get_previous_available_marker(current_page_idx) > -1
		right_button.visible = catalog.get_next_available_marker(current_page_idx) > -1
#endregion

func _on_left_button_pressed() -> void:
	turn_to_page(catalog.get_previous_available_marker(current_page_idx))

func _on_right_button_pressed() -> void:
	turn_to_page(catalog.get_next_available_marker(current_page_idx))
