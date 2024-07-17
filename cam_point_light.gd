extends PointLight2D


#var _cam_tex_rect: TextureRect
var _shadowed_clikmi: Clikmi

# -- might consider changing light mask
func set_cam_tex_rect(a_tex_rect: TextureRect):
	color = a_tex_rect.set_color
	a_tex_rect.light_pos_change.connect( func(a_selected_clikmi):
		visible = true
		_shadowed_clikmi = a_selected_clikmi
		a_selected_clikmi.sucked_in.connect( func():
			_shadowed_clikmi = null
			)
		a_selected_clikmi.released_light_pos.connect( func(a_clikmi):
			if a_clikmi == _shadowed_clikmi:
				_shadowed_clikmi = null
		)
	)

func _physics_process(delta):
	if _shadowed_clikmi:
		global_position = _shadowed_clikmi.global_position
	else:
		if visible:
			visible = false
