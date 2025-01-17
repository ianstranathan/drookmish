extends Area2D

@export var void_duration: float = 7.0
@export var visual_cue_duration: float = 7.0
#----------------------------------------------------
@onready var void_sprite = $VoidSprite

#----------------------------------------------------
@onready var black_hole_duration_timer: Timer = $DurationTimer
@onready var coyote_timer: Timer = $CoyoteTimer
#----------------------------------------------------

#@onready var shader_uniform_fn: Callable = Utils.shader_float_tween

var starting_sprite_scale = Vector2(2., 2.)

signal tween_anim_in_finished
"""
TODO:
	suck in any clikmis that come in, not just those that happen on suck_in_clikmis after visual cue
"""

var can_make_sounds :bool = true

func _ready():
	# -- SFX
	$SFX_container/VisibleOnScreenNotifier2D.screen_entered.connect(func(): can_make_sounds = true)
	$SFX_container/VisibleOnScreenNotifier2D.screen_exited.connect(func(): can_make_sounds = true)
	# --------------------------------
	z_index = Ordering.black_hole
	# --------------------------------
	area_entered.connect( on_area_entered )
	area_exited.connect( on_area_exited )
	# --------------------------------
	$CollisionShape2D.disabled = true
	#$CollisionShape2D.set_deferred("disabled", false) 
	# -- coyote timer should allow some buffer space to get out of black hole
	coyote_timer.timeout.connect( on_coyote_timer_timeout )
	black_hole_duration_timer.timeout.connect( evaporate )
	void_sprite.material.set_shader_parameter("swirl_dist_normal", 0.0) # in case I forget to clear it
	
	
	void_sprite.visible = true
	void_sprite.scale = Vector2.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(void_sprite, "scale", starting_sprite_scale, 1.).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback( func():
		coyote_timer.start()
		$CollisionShape2D.set_deferred("disabled", false) 
		 # -- start the black hole check after coyote timer is done
		black_hole_duration_timer.start() # -- when black hole is done growing, start timer
		var swirl_speed_tween = get_tree().create_tween()
		Utils.shader_float_tween(swirl_speed_tween, $VoidSprite, "swirl_dist_normal", 1.3)
	)
	$SFX_container/stop.finished.connect( func(): queue_free())
	$SFX_container/start.play()


func on_coyote_timer_timeout():
	suck_in_clikmis()


func sucked_in_mapping(arr_of_clikmis: Array):
	arr_of_clikmis.map( func(x):
		# connect the sucked in signal on clikmi to a 
		# closure around the arr_of_clikmis to check for queuing free
		x.sucked_in.connect( sucked_in_callback(arr_of_clikmis) )
		# start + have the clikmis spin the length of the hole animation
		x.start_sucking_in( global_position, func(): return black_hole_duration_timer.time_left))
		#x.start_sucking_in( global_position, black_hole_duration_timer.wait_time))


func suck_in_clikmis():
	var arr_of_clikmis = get_overlapping_areas().filter( func(x): 
		return x is Clikmi)
	if arr_of_clikmis.size() > 0:
		sucked_in_mapping( arr_of_clikmis )


func on_area_entered(area: Area2D):
	if area is Clikmi and !area.invincible and coyote_timer.is_stopped():
		suck_in_clikmis()


func on_area_exited(area: Area2D):
	if area is Clikmi and !coyote_timer.is_stopped():
		area.and_one()


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
	$SFX_container/stop.play() # --  clip is 2.12 seconds, so if finished queues free, there is enough time or scale tween
	var tween = get_tree().create_tween()
	tween.tween_property(void_sprite, "scale", Vector2.ZERO, 1.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback( func():
		$CollisionShape2D.set_deferred("disabled", true)
		#queue_free()
		)


func set_size(_scale: float):
	$CollisionShape2D.shape.radius *= _scale
	$VoidSprite.scale = _scale
	$VisualCueSprite.scale = _scale
