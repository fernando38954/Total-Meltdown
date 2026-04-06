extends CanvasLayer
class_name Swebok

signal move_animation_finished

@onready var book_sprite = $AnimatedSprite2D
@onready var catalog_view = $Catalog
@onready var content_view = $ContentViewer
@onready var left_button = $LeftButton
@onready var right_button = $RightButton
@onready var return_button = $ReturnButton

var open_position = Vector2(593, 283)
var hide_position = Vector2(1558, 283)
var tween: Tween

var current_page_idx: int

#region Internal Classes
enum BookPage {
	turning = -4,
	close = -3,
	opening = -2,
	catalogPage = -1
} 

enum PageDirection {
	left = -1,
	right = 1
}
#endregion

func _ready():
	close_book(0)

#region Book Action
func move_book(target_position: Vector2, duration: float = 1.0):
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(book_sprite, "position", target_position, duration)
	tween.tween_callback(move_animation_finished.emit)

func close_book(duration: float = 0.5):
	move_book(hide_position, duration)
	show_page(BookPage.close)
	book_sprite.play_backwards("open_book")

func open_book(duration: float = 0.5):
	current_page_idx = BookPage.opening
	move_book(open_position, duration)
	book_sprite.play("open_book")
	
	await move_animation_finished
	if current_page_idx == BookPage.opening:
		show_page(BookPage.catalogPage)

func turn_to_page(target_page_idx: int):
	var direction = PageDirection.right if (target_page_idx > current_page_idx) else PageDirection.left
	show_page(BookPage.turning)
	book_sprite.play("turn_page", 1.0 * direction, (direction < 0))
	
	await book_sprite.animation_finished
	if current_page_idx == BookPage.turning:
		show_page(target_page_idx)
#endregion

#region Book Content
func show_page(page_idx: int):
	current_page_idx = page_idx
	update_page_visibility()
	update_buttons_visibility()
	
	if page_idx > BookPage.catalogPage:
		content_view.show_content(SwebokManager.chapters[page_idx])

func update_page_visibility():
	catalog_view.visible = current_page_idx == BookPage.catalogPage
	content_view.visible = current_page_idx > BookPage.catalogPage

func update_buttons_visibility():
	var catalog_index = BookPage.catalogPage
	var last_chapter_index = SwebokManager.chapters.size() - 1
	var prev_index = current_page_idx - 1
	var next_index = current_page_idx + 1
	
	left_button.visible = prev_index >= catalog_index and prev_index <= last_chapter_index
	right_button.visible = current_page_idx >= catalog_index and next_index <= last_chapter_index
	return_button.visible = current_page_idx > catalog_index
#endregion

func _on_left_button_pressed() -> void:
	turn_to_page(current_page_idx + PageDirection.left)


func _on_right_button_pressed() -> void:
	turn_to_page(current_page_idx + PageDirection.right)


func _on_return_button_pressed() -> void:
	turn_to_page(BookPage.catalogPage)
