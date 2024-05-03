extends Area2D


@onready var void_sprite = $VoidSprite
@onready var visual_cue_sprite = $VisualCueSprite
@onready var visual_cue_timer: Timer = $VisualCueTimer
@onready var duration_timer: Timer = $DurationTimer


@onready var timer_fn: Callable = Utils.timers_remaining_time_normalized

var sucked_in_clikmis = 0

func _ready():
	#void_sprite.visible = false
	duration_timer.timeout.connect( end_void )
	visual_cue_timer.timeout.connect( start_void )
	void_sprite.material.set_shader_parameter("swirl_dist_normal", 0.0) # in case I forget to clear it
	visual_cue_timer.timeout.connect(func(): start_void())
	visual_cue_timer.start()

func start_void():
	#void_sprite.visible = true
	visual_cue_sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", false)
	duration_timer.start()

func end_void():
	suck_in_clikmis()

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
			x.start_sucking_in())
	else:
		evaporate()

# -- this is a function that can do cool stuff if the clikmi is sucked in
func sucked_in_callback( arr: Array):
	return func():
		sucked_in_clikmis += 1
		if sucked_in_clikmis == arr.size():
			evaporate()

func evaporate():
	# probably some particle effect or something
	queue_free()


func set_size(_scale: float):
	$CollisionShape2D.shape.radius *= _scale
	$VoidSprite.scale = _scale
	$VisualCueSprite.scale = _scale
