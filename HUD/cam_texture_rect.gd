extends TextureRect

signal cam_icon_selected
signal camera_hotkey_pressed 
signal camera_icon_hovered
signal camera_hotkey_made

var camera_hot_key_fn = null
var managed_clikmi = null
var _can_select = false

@export var set_color: Vector4 = Vector4(1., 1., 1., 1.)

func _ready():
	material.set_shader_parameter("set_col", set_color)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect( on_mouse_exited)
	
func on_mouse_entered():
	_can_select = true
	# check if there is a clikmi selected, if yes, check if it's the same one as in the hotkey
	emit_signal("camera_icon_hovered", camera_hover_callback_fn)

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


func on_mouse_exited():
	_can_select = false
	turn_off_button_cues()


func turn_off_button_cues():
	material.set_shader_parameter("hover_set_bind_col", 0.0)
	material.set_shader_parameter("hovered_over_bind_hotkey", 0.0)
	material.set_shader_parameter("hovered_over_hotkey_jump", 0.0)


func _input(event):
	if event.is_action_pressed("select") and _can_select:
		emit_signal("cam_icon_selected", cam_hotkey_click_callback_fn)


func cam_loc_fn(a_clickmi) -> Callable:
	return func(b=false):
		if b: 
			return a_clickmi
		else:
			emit_signal("camera_hotkey_pressed", a_clickmi.global_position)


func cam_hotkey_click_callback_fn(a_selected_clikmi):
	if a_selected_clikmi:
		if camera_hot_key_fn:
			var assoc_clikmi = camera_hot_key_fn.call(true)
			if assoc_clikmi != a_selected_clikmi:
				assoc_clikmi.remove_hotkey_color()
		
		turn_off_button_cues() # stop vertex shader stuff
		a_selected_clikmi.hotkey_color(set_color, self) # change the clikmi to match 
		camera_hot_key_fn = cam_loc_fn(a_selected_clikmi)
		emit_signal("camera_hotkey_made")
	# otherwise call the func and let the camera jump to the hotkey loc
	elif camera_hot_key_fn:
		camera_hot_key_fn.call()


func unbind_from_a_clikmi(a_clikmi):
	camera_hot_key_fn = null
