extends Sprite2D

@export var curr_cam: Camera2D
var list_of_black_holes

# ---------------------------
var unit_timer_fn = Utils.timers_remaining_time_normalized
# ---------------------------
var shockwave_duration := 5.0
var last_index: int = 0
var arr_of_void_hole_positions: Array[Vector2];
var arr_of_void_hole_timers: Array[Timer];

func _ready():
	# -- set size to
	Utils.set_sprite_to_resolution(self)
	material.set_shader_parameter("resolution", texture.get_size() * scale)
	assert( curr_cam )
	
func _physics_process(delta):
	if global_position != curr_cam.global_position:
		global_position = curr_cam.global_position
	
	if !arr_of_void_hole_positions.is_empty():
		last_index = arr_of_void_hole_positions.size()
		material.set_shader_parameter("actual_index", last_index)
		material.set_shader_parameter("positions", arr_of_void_hole_positions)
		material.set_shader_parameter("times", arr_of_void_hole_timers.map(func(a_timer):
			return a_timer.wait_time - a_timer.time_left
			))
		#material.set_shader_parameter("unit_times", arr_of_void_hole_timers.map(
			#unit_timer_fn))
	elif last_index != 0:
		last_index = 0
		material.set_shader_parameter("actual_index", last_index)

func void_hole_made(a_pos: Vector2):
	var rel_pos = a_pos - global_position # -- changing to camera origin
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = shockwave_duration
	timer.timeout.connect( func():
		arr_of_void_hole_positions.remove_at( arr_of_void_hole_positions.find(a_pos))
		arr_of_void_hole_timers.remove_at( arr_of_void_hole_timers.find(timer))
		#print(arr_of_void_hole_positions)
		#print(arr_of_void_hole_timers)
		timer.queue_free()
		)
	timer.start()
	arr_of_void_hole_positions.append(rel_pos)
	arr_of_void_hole_timers.append( timer )
	#print(arr_of_void_hole_positions)
	#print(arr_of_void_hole_timers)
