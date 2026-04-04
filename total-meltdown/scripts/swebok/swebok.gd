extends CanvasLayer
class_name Swebok

signal move_animation_finished

@onready var book_sprite = $AnimatedSprite2D
@onready var catalog_view = $Catalog
@onready var content_view = $ContentViewer

var open_position = Vector2(593, 283)
var hide_position = Vector2(1558, 283)
var tween: Tween

var is_open: bool

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
	hide_everything()
	book_sprite.play_backwards("open_book")
	is_open = false

func open_book(duration: float = 0.5):
	move_book(open_position, duration)
	book_sprite.play("open_book")
	is_open = true
	
	await move_animation_finished
	if is_open:
		show_catalog()
#endregion

#region Book Content
func hide_everything():
	catalog_view.visible = false
	content_view.visible = false

func show_catalog():
	catalog_view.visible = true
	content_view.visible = false

func show_chapter_content(chapter_data: Dictionary):
	catalog_view.visible = false
	content_view.visible = true
	content_view.show_content(chapter_data)

func show_catalog_from_content():
	show_catalog()
#endregion
