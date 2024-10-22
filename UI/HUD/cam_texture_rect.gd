extends TextureRect


signal cam_icon_selected
signal camera_hotkey_pressed 
signal camera_icon_hovered
signal camera_hotkey_made

# -- to change the colored light when clikmi hotkey is set
signal light_pos_change( a_selected_clikmi)

var camera_hot_key_fn = null
var _can_select = false

@export var set_color: Color

func _ready():
	material.set_shader_parameter("set_col", Vector4(set_color.r, set_color.g, set_color.b, set_color.a))
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect( on_mouse_exited)
	
	
func on_mouse_entered():
	MouseContainer.hovering_over_cam_tex_rect = true
	_can_select = true
	# check if there is a clikmi selected, if yes, check if it's the same one as in the hotkey
	emit_signal("camera_icon_hovered", camera_hover_callback_fn)


func on_mouse_exited():
	MouseContainer.hovering_over_cam_tex_rect = false
	print("exited")
	_can_select = false
	turn_off_button_cues()


func camera_hover_callback_fn( a_selected_clikmi ):
	# if your mouse is hovering over the icon:
	# Do you have a selected clikmi?
	# Y?: do the animation for binding the icon
	# N?: does the camera have a bind?
		# Y: do the anim for the bind
		# N: do nothing
	if a_selected_clikmi:
		if !(camera_hot_key_fn and camera_hot_key_fn.call(true) == a_selected_clikmi):
			material.set_shader_parameter("hovered_over_bind_hotkey", 1.0)
			material.set_shader_parameter("hover_set_bind_col", Vector4(1., 1., 0., 1.))
	else:
		if camera_hot_key_fn:
			material.set_shader_parameter("hovered_over_hotkey_jump", 1.0)


func turn_off_button_cues():
	material.set_shader_parameter("hover_set_bind_col", 0.0)
	material.set_shader_parameter("hovered_over_bind_hotkey", 0.0)
	material.set_shader_parameter("hovered_over_hotkey_jump", 0.0)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and _can_select:
		# -- send out signal: this rect -> gui -> stage
		# --                  stage -> selected_clikmi -> this rect
		emit_signal("cam_icon_selected", cam_hotkey_click_callback_fn)
#func _input(event):
	#if event.is_action_pressed("select") and _can_select:
		#emit_signal("cam_icon_selected", cam_hotkey_click_callback_fn)


# -- closure around a clikmi
func cam_loc_fn(a_clickmi) -> Callable:
	return func(b=false):
		if b: 
			return a_clickmi
		else:
			emit_signal("camera_hotkey_pressed", a_clickmi.global_position)


func cam_hotkey_click_callback_fn(a_selected_clikmi):
	if a_selected_clikmi:
		# if there is a hotkeyed clikmi to this rect
		# remove the color
		if camera_hot_key_fn:
			camera_hot_key_fn.call(true).set_color()
		
		turn_off_button_cues() # stop vertex shader stuff
		
		# the clikmi must also be able to unbind
		a_selected_clikmi.set_hotkey(unbind_from_a_clikmi, set_color) 
		camera_hot_key_fn = cam_loc_fn(a_selected_clikmi)
		emit_signal("camera_hotkey_made")
		emit_signal("light_pos_change", a_selected_clikmi )
	# otherwise call the func and let the camera jump to the hotkey loc
	elif camera_hot_key_fn:
		camera_hot_key_fn.call()


func unbind_from_a_clikmi():
	camera_hot_key_fn = null
