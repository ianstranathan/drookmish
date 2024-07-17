extends Node2D


func set_up_light_cols(arr_of_tex_rects: Array):
	var lights = get_children()
	assert( arr_of_tex_rects.size() == lights.size())
	# -- see set_color in game_ui.tscn script
	lights.map(func(light): light.set_cam_tex_rect( arr_of_tex_rects[lights.find(light)]))
