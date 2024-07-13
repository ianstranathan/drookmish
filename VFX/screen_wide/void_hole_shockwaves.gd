extends Sprite2D

@export var curr_cam: Camera2D
var list_of_black_holes

# ---------------------------
var unit_timer_fn = Utils.timers_remaining_time_normalized
# ---------------------------
var shockwave_duration := 2.5
var last_index: int = 0
var arr_of_void_hole_positions: Array[Vector2];
var arr_of_void_hole_timers: Array[Timer];

var managed_clikmis: Dictionary = {}
var arr_of_clikmis : Array[Clikmi]

func _ready():
	# -- set size to
	Utils.set_sprite_to_resolution(self)
	# -- for the screen wide shader to normalize the uv space
	material.set_shader_parameter("resolution", texture.get_size() * scale)
	assert( curr_cam )
	
func _physics_process(delta):
	if global_position != curr_cam.global_position:
		global_position = curr_cam.global_position
	
	if !managed_clikmis.is_empty():
		material.set_shader_parameter("times", managed_clikmis.keys().map(func(x):
				var a_timer =  managed_clikmis[x]["Timer"]
				return a_timer.wait_time - a_timer.time_left
		))

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
	var arr_rel_pos = managed_clikmis.keys().map(func(x):
			return managed_clikmis[x]["Clikmi"].global_position - global_position
			)
	#print(arr_rel_pos)
	material.set_shader_parameter("positions", arr_rel_pos)
	# ----------------------------------------------------------------
	# -- for loop index in shader
	material.set_shader_parameter("actual_index", managed_clikmis.size())

func clikmi_freed(a_clikmi):
	# -- timer won't start til in scene tree? => forced to manage resource here
	managed_clikmis[a_clikmi.name]["Timer"].queue_free()
	managed_clikmis.erase(a_clikmi.name)
	material.set_shader_parameter("actual_index", managed_clikmis.size())
	
	
