extends Sprite2D
class_name QuestPanel

@onready var title = $Title
@onready var icon = $Icon
@onready var description = $Description

func set_content(title_text: String, icon_sprite: Texture2D, description_list: Dictionary):
	title.text = title_text
	icon.texture = icon_sprite
	var paragraphs = []
	for value in description_list.values():
		paragraphs.append(value)
	description.text = "\n\n".join(paragraphs)
