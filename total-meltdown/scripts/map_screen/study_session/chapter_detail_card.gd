extends DeveloperDetailCard

func set_content(chapter_data: Dictionary):
	developer_name.text = "[center][b][font_size=%d]%s[/font_size][/b][/center]\n\n" % [name_size, chapter_data.title]
	description.text = "[font_size=%d]%s[/font_size]" % [description_size, chapter_data.description]
	radar_chart.set_label(font, font_size, value_font_size, label_offset)
	radar_chart.set_attributes(chapter_data.attribute)
