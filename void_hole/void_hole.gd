extends Area2D


@onready var void_sprite = $VoidSprite
@onready var visual_cue_sprite = $VisualCueSprite
@onready var visual_cue_timer: Timer = $VisualCueTimer
@onready var duration_timer: Timer = $DurationTimer


@onready var timer_fn: Callable = Utils.timers_remaining_time_normalized

var sucked_in_clikmis = 0
var initial_inhale: bool = true
var starting_sprite_scale = Vector2(2., 2.)

func _ready():
	#area_entered.connect( func(area): 
		#if !initial_inhale and area is Clikmi: 
			#suck_in_clikmis())
	void_sprite.visible = false
	void_sprite.scale = Vector2.ZERO
	
	duration_timer.timeout.connect( evaporate )
	visual_cue_timer.timeout.connect( start_void )
	void_sprite.material.set_shader_parameter("swirl_dist_normal", 0.0) # in case I forget to clear it
	visual_cue_timer.timeout.connect(func(): start_void())
	visual_cue_timer.start()
	
	# -- Cue sprite scale juice
	visual_cue_sprite.scale = Vector2.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(visual_cue_sprite, "scale", starting_sprite_scale, 0.8).set_trans(Tween.TRANS_SINE)
	
func start_void():
	void_sprite.visible = true

	var tween = get_tree().create_tween()
	tween.tween_property(visual_cue_sprite, "scale", Vector2.ZERO, 1.25).set_trans(Tween.TRANS_SINE)
	tween.tween_property(void_sprite, "scale", starting_sprite_scale, 1.).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback( func(): 
		visual_cue_sprite.visible = false; # unecessary but maybe saves a render call?
		suck_in_clikmis())
	
	$CollisionShape2D.set_deferred("disabled", false)
	duration_timer.start()


func _physics_process(delta):
	if !visual_cue_timer.is_stopped():
		var t = timer_fn.call(visual_cue_timer)
		visual_cue_sprite.material.set_shader_parameter("t",  t)

	if !duration_timer.is_stopped():
		#var t = timer_fn.call(duration_timer)
		void_sprite.material.set_shader_parameter("swirl_dist_normal",  timer_fn.call(duration_timer))


func suck_in_clikmis():
	var arr_of_clikmis = get_overlapping_areas().filter( func(x): return x is Clikmi)
	if arr_of_clikmis.size() > 0:
	# closure around the arr_of_clikmis to check for queuing free
		arr_of_clikmis.map( func(x):
			x.sucked_in.connect( sucked_in_callback(arr_of_clikmis) )
			# start + have the clikmis spin the length of the hole animation
			x.start_sucking_in( global_position, duration_timer.wait_time)) 
	else:
		initial_inhale = false

# -- this is a function that can do cool stuff if the clikmi is sucked in
func sucked_in_callback( arr: Array):
	return func():
		sucked_in_clikmis += 1
		if sucked_in_clikmis == arr.size() and duration_timer.is_stopped():
			evaporate()

func evaporate():
	# probably some particle effect or something
	var tween = get_tree().create_tween()
	tween.tween_property(void_sprite, "scale", Vector2.ZERO, 1.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback( func(): queue_free())


func set_size(_scale: float):
	$CollisionShape2D.shape.radius *= _scale
	$VoidSprite.scale = _scale
	$VisualCueSprite.scale = _scale
