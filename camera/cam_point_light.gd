extends PointLight2D

var _shadowed_clikmi: Clikmi

func _ready():
	visible = false
	set_process( false )

func set_cam_tex_rect(a_tex_rect: TextureRect):
	color = a_tex_rect.set_color # -- see set_color in game_ui.tscn script
	a_tex_rect.light_pos_change.connect( func(a_selected_clikmi):
		_init_light( true )
		_shadowed_clikmi = a_selected_clikmi
		a_selected_clikmi.sucked_in.connect( func():
			_shadowed_clikmi = null
			_init_light( false )
			)
		a_selected_clikmi.released_light_pos.connect( func(a_clikmi):
			if a_clikmi == _shadowed_clikmi:
				_shadowed_clikmi = null
				_init_light( false )
		)
	)

func _init_light(b: bool):
	visible = b
	set_process(b)
	
func _process(_delta):
	global_position = _shadowed_clikmi.global_position
