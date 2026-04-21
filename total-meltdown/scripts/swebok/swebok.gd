extends CanvasLayer
class_name Swebok

signal move_animation_finished

@onready var book_sprite = $AnimatedSprite2D
@onready var catalog_view = $Catalog
@onready var content_view = $ContentViewer
@onready var left_button = $LeftButton
@onready var right_button = $RightButton
@onready var return_button = $ReturnButton
@onready var audio_player = $AudioStreamPlayer

@export var open_position = Vector2(2015.0, 950.0)
@export var hide_position = Vector2(5100.0, 950.0)

@export_category("SFX")
@export var flip_page_right_SFX : AudioStream
@export var flip_page_left_SFX : AudioStream

var tween: Tween
var current_page_idx: int
var tutorial_page_qty: int = 0

#region Internal Classes
var BookPage = {
	"turning": -4,
	"close": -3,
	"opening": -2,
	"catalogPage": -1
}

enum PageDirection {
	left = -1,
	right = 1
}
#endregion

func _ready():
	BookPage["tutorialPageLimit"] = TutorialPageManager.all_pages.size()
	close_book(0)

#region Book Action
func move_book(target_position: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(book_sprite, "position", target_position, duration)
	tween.tween_callback(move_animation_finished.emit)

func close_book(duration: float = 1):
	move_book(hide_position, duration)
	show_page(BookPage.close)
	book_sprite.play_backwards("open_book")
	if duration > 0:
		AudioManager.play_sfx(flip_page_left_SFX)

func open_book(duration: float = 0.5):
	current_page_idx = BookPage.opening
	move_book(open_position, duration)
	
	await move_animation_finished
	book_sprite.play("open_book")
	AudioManager.play_sfx(flip_page_right_SFX)
	await book_sprite.animation_finished
	if current_page_idx == BookPage.opening:
		catalog_view.build_catalog()
		show_page(BookPage.catalogPage)

func turn_to_page(index: int, content_type: ContentViewer.ContentType):
	var target_page_idx = index_to_page(index, content_type)
	var direction = PageDirection.right if (target_page_idx > current_page_idx) else PageDirection.left
	show_page(BookPage.turning)
	book_sprite.play("turn_page", 1.0 * direction, (direction < 0))
	AudioManager.play_sfx(flip_page_right_SFX if direction == PageDirection.right else flip_page_left_SFX)
	
	await book_sprite.animation_finished
	if current_page_idx == BookPage.turning:
		show_page(target_page_idx)

func index_to_page(index: int, content_type: ContentViewer.ContentType):
	var page_offset = BookPage.tutorialPageLimit if content_type == ContentViewer.ContentType.Pattern else 0
	return index + page_offset

func page_to_index(page_index):
	var content_type = ContentViewer.ContentType.Pattern if page_index >= BookPage.tutorialPageLimit else ContentViewer.ContentType.Tutorial
	var index = page_index - BookPage.tutorialPageLimit * (1 if content_type == ContentViewer.ContentType.Pattern else 0)
	return [index, content_type]
#endregion

#region Book Content
func show_page(page_idx: int):
	current_page_idx = page_idx
	update_page_visibility()
	update_buttons_visibility()
	
	var idx_package = page_to_index(page_idx)
	if idx_package[1] == ContentViewer.ContentType.Pattern:
		content_view.show_content(PatternManager.owned_patterns[idx_package[0]], idx_package[1])
	elif page_idx > BookPage.catalogPage:
		content_view.show_content(TutorialPageManager.all_pages[idx_package[0]], idx_package[1])

func update_page_visibility():
	catalog_view.visible = current_page_idx == BookPage.catalogPage
	content_view.visible = current_page_idx > BookPage.catalogPage

func update_buttons_visibility():
	var catalog_index = BookPage.catalogPage
	var last_page_index = TutorialPageManager.all_pages.size() + PatternManager.owned_patterns.size() - 1
	var prev_index = current_page_idx - 1
	var next_index = current_page_idx + 1
	
	left_button.visible = prev_index >= catalog_index and prev_index <= last_page_index
	right_button.visible = current_page_idx >= catalog_index and next_index <= last_page_index
	return_button.visible = current_page_idx > catalog_index
#endregion

func _on_left_button_pressed() -> void:
	var idx_package = page_to_index(current_page_idx + PageDirection.left)
	turn_to_page(idx_package[0], idx_package[1])


func _on_right_button_pressed() -> void:
	var idx_package = page_to_index(current_page_idx + PageDirection.right)
	turn_to_page(idx_package[0], idx_package[1])


func _on_return_button_pressed() -> void:
	turn_to_page(BookPage.catalogPage, ContentViewer.ContentType.Tutorial)
