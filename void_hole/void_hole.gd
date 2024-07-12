extends Area2D

@export var void_duration: float = 7.0
@export var visual_cue_duration: float = 7.0
#----------------------------------------------------
@onready var void_sprite = $VoidSprite

#----------------------------------------------------
@onready var black_hole_duration_timer: Timer = $DurationTimer
@onready var coyote_timer: Timer = $CoyoteTimer
#----------------------------------------------------

@onready var timer_fn: Callable = Utils.timers_remaining_time_normalized
@onready var shader_uniform_fn: Callable = Utils.shader_float_tween

var starting_sprite_scale = Vector2(2., 2.)

"""
TODO:
	suck in any clikmis that come in, not just those that happen on suck_in_clikmis after visual cue
"""

func _ready():
	area_entered.connect( func(area): suck_in_clikmis() )
	
	# -- black hole is not visible
	# -- both black hole and visual cue are zero scale (should tween in)
	void_sprite.visible = false
	void_sprite.scale = Vector2.ZERO
	
	# -- coyote timer should allow some buffer space to get out of black hole
	coyote_timer.timeout.connect( on_coyote_timer_timeout )
	black_hole_duration_timer.timeout.connect( evaporate )
	void_sprite.material.set_shader_parameter("swirl_dist_normal", 0.0) # in case I forget to clear it
	
	
	
	# -- shockwave juice
	#$Shockwave.visible = true
	#var tween = get_tree().create_tween()
	#shader_uniform_fn.call(tween, $Shockwave, "t", 1.0)
	#tween.tween_callback(func():
		#$Shockwave.visible = false
		#)


func start_void():
	# -- there should be a quick sin(x)/x type sample dist
	void_sprite.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(void_sprite, "scale", starting_sprite_scale, 1.).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_callback( func(): 
		coyote_timer.start() # -- start the black hole check after coyote timer is done
		black_hole_duration_timer.start() # -- when black hole is done growing, start timer
		)

func on_coyote_timer_timeout():
	$CollisionShape2D.set_deferred("disabled", false) # -- the inspector value is already disabled
	suck_in_clikmis()


func _physics_process(delta):
	if !black_hole_duration_timer.is_stopped():
		#var t = timer_fn.call(black_hole_duration_timer)
		void_sprite.material.set_shader_parameter("swirl_dist_normal",  timer_fn.call(black_hole_duration_timer))


func sucked_in_mapping(arr_of_clikmis: Array):
	arr_of_clikmis.map( func(x):
		# connect the sucked in signal on clikmi to a 
		# closure around the arr_of_clikmis to check for queuing free
		x.sucked_in.connect( sucked_in_callback(arr_of_clikmis) )
		# start + have the clikmis spin the length of the hole animation
		x.start_sucking_in( global_position, black_hole_duration_timer.wait_time))

func suck_in_clikmis():
	var arr_of_clikmis = get_overlapping_areas().filter( func(x): return x is Clikmi)
	if arr_of_clikmis.size() > 0:
		sucked_in_mapping( arr_of_clikmis )
	# closure around the arr_of_clikmis to check for queuing free
		#arr_of_clikmis.map( func(x):
			#x.sucked_in.connect( sucked_in_callback(arr_of_clikmis) )
			## start + have the clikmis spin the length of the hole animation
			#x.start_sucking_in( global_position, black_hole_duration_timer.wait_time)) 

# -- this is a function that can do cool stuff if the clikmi is sucked in
var sucked_in_clikmis = 0

func sucked_in_callback( arr: Array):
	return func():
		sucked_in_clikmis += 1
		if sucked_in_clikmis == arr.size() and black_hole_duration_timer.is_stopped():
			evaporate()


func evaporate():
	# probably some particle effect or something (like zelda bomb w/e)
	
	# turn off its ability to suck in clikmis (player won't like random suck in at end)
	set_deferred("monitoring", false)
	
	var tween = get_tree().create_tween()
	tween.tween_property(void_sprite, "scale", Vector2.ZERO, 1.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback( func(): 
		queue_free())


func set_size(_scale: float):
	$CollisionShape2D.shape.radius *= _scale
	$VoidSprite.scale = _scale
	$VisualCueSprite.scale = _scale
