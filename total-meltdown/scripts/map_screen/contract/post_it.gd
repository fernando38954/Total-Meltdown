extends Sprite2D
class_name PostIt

@onready var bullet_points = $BulletPoints
@onready var footnote = $Footnote

func set_content(bullet_list: Dictionary, footnote_text: String):
	bullet_points.text = "[ul]\n"
	for value in bullet_list.values():
		bullet_points.text += value + "\n"
	bullet_points.text += "[/ul]"
	
	footnote.text = footnote_text
