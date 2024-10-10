extends Node2D


func set_up_light_cols(arr_of_tex_rects: Array):
	var lights = get_children()
	assert( arr_of_tex_rects.size() == lights.size())
	lights.map( func(light): 
		# -- for each index of the lights arr: 
		# -- call set_cam_tex_rect with each corresponding tex rect index
		light.set_cam_tex_rect( arr_of_tex_rects[lights.find(light)]))
