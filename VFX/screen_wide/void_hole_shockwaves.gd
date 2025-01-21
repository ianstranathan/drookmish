extends Sprite2D

@export var curr_cam: Camera2D

var shockwave_duration := 2.5
var last_index: int = 0
var managed_clikmis: Dictionary = {}


func _ready():
	assert( curr_cam )
	
	# -- connect the camera to a signal to see when it moves
	curr_cam.moved.connect( func():
		material.set_shader_parameter("positions", 
		last_arr_of_positions.map( func(_pos): return _pos - global_position)))
	
	init_sprite_and_shader_params()
	get_tree().get_root().size_changed.connect(func():
		init_sprite_and_shader_params())
	## -- set size to
	#Utils.set_sprite_to_resolution(self)
	## -- for the screen wide shader to normalize the uv space
	#material.set_shader_parameter("resolution", texture.get_size() * scale)
	

func init_sprite_and_shader_params():
	# -- set the sprite to be the size of the window / viewport
	Utils.set_sprite_to_resolution(self)
	# -- for the screen wide shader to normalize the uv space
	material.set_shader_parameter("resolution", texture.get_size() * scale)

func _process(_delta):
	global_position = curr_cam.global_position


func _physics_process(_delta):
	if !managed_clikmis.is_empty():
		material.set_shader_parameter("times", managed_clikmis.keys().map(func(x):
				var a_timer =  managed_clikmis[x]["Timer"]
				return a_timer.wait_time - a_timer.time_left
		))

var last_arr_of_positions: Array
func void_hole_made(a_clikmi: Clikmi):
	if !managed_clikmis.has(a_clikmi.name):
		managed_clikmis[a_clikmi.name]= {"Clikmi": a_clikmi, 
										 "Timer": Timer.new()}
		managed_clikmis[a_clikmi.name]["Timer"].wait_time = shockwave_duration
		managed_clikmis[a_clikmi.name]["Timer"].one_shot = true
		# -- timer won't start til in scene tree?
		add_child(managed_clikmis[a_clikmi.name]["Timer"])
	managed_clikmis[a_clikmi.name]["Timer"].start()
	# ----------------------------------------------------------------
	# -- for all managed clikmis give camera relative position
	#var arr_rel_pos = managed_clikmis.keys().map(func(x):
			#return managed_clikmis[x]["Clikmi"].global_position - global_position
			#)
	#print(arr_rel_pos)
	#var arr_rel_pos = managed_clikmis.keys().map(func(x):
			#return managed_clikmis[x]["Clikmi"].global_position - global_position
			#)
	material.set_shader_parameter("positions", arr_rel_pos_fn())
	# ----------------------------------------------------------------
	# -- for loop index in shader
	material.set_shader_parameter("actual_index", managed_clikmis.size())


func arr_rel_pos_fn():
	last_arr_of_positions.clear()
	return managed_clikmis.keys().map(func(x):
		var _clikmi_pos = managed_clikmis[x]["Clikmi"].global_position
		last_arr_of_positions.append(_clikmi_pos)
		return _clikmi_pos - global_position)
#func arr_of_rel_positions() -> Array:
	#last_arr_of_positions.clear()
	#var ret = []
	#for k in managed_clikmis.keys():
		#var clikmi_pos = managed_clikmis[k]["Clikmi"].global_position
		#last_arr_of_positions.append( clikmi_pos )
		#ret.append(clikmi_pos - global_position)
	#return ret
	#return managed_clikmis.keys().map(func(x):
			#
			#return 
			#)


func clikmi_freed(a_clikmi) -> void:
	var key = a_clikmi.name
	if managed_clikmis.has(key):
		managed_clikmis.get(key).get("Timer").queue_free()
		call_deferred("safe_erase", key)


func safe_erase(key: String) -> void:
	# -- Queue_free is thread safe, so there is some background locking
	# -- deferred call to change managed clikmis
	managed_clikmis.erase(key)
	material.set_shader_parameter("actual_index", managed_clikmis.size())


func shake(duration_time: float, shake_scale: float):
	# -- uniform float shake_scale =  0.01; is default
	material.set_shader_parameter("shake_scale", shake_scale)
	# -- see shader for why 5 is picked (exp(-t) is ~ 0 by like 4-5 x)
	Utils.material_shader_float_tween(create_tween(), material, "shake_t", duration_time, 0., 5.)
