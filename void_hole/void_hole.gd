extends Area2D


@onready var void_sprite = $VoidSprite
@onready var visual_cue_sprite = $VisualCueSprite
@onready var visual_cue_timer: Timer = $VisualCueTimer

signal void_hole_finished( arr_of_clikmis, this_void_hole)

var camera: Camera2D

func _ready():
	#$VoidSprite.visible = false
	$DurationTimer.timeout.connect( end_void )
	$StartTimer.timeout.connect( end_start )
	void_sprite.material.set_shader_parameter("swirl_dist_normal", 0.0) # in case I forget to clear it


func start_void():
	$StartTimer.start()


func _physics_process(delta):
	# this is the offset in world space for the screen reading shader
	# if the visual cue is still running:
	if !visual_cue_timer.is_stopped():
		visual_cue_sprite.material.set_shader_parameter("cam_offset",  global_position - camera.global_position)
	if !$StartTimer.is_stopped():
		var normalized_t = ($StartTimer.wait_time - $StartTimer.time_left) / $StartTimer.wait_time
		visual_cue_sprite.material.set_shader_parameter("t", normalized_t)
		
	if !$DurationTimer.is_stopped():
		var normalized_t = ($DurationTimer.wait_time - $DurationTimer.time_left) / $DurationTimer.wait_time
		void_sprite.material.set_shader_parameter("swirl_dist_normal", normalized_t)

func end_start():
	visual_cue_sprite.visible = false
	visual_cue_sprite.material.set_shader_parameter("t", 0.0)
	# start the duration timer and turn on void sprite
	$DurationTimer.start()
	void_sprite.visible = true


func end_void():
	emit_signal("void_hole_finished", get_overlapping_areas().map( func(x): x is Clikmi), self)


func set_size(_scale: float):
	$CollisionShape2D.shape.radius *= _scale
	$VoidSprite.scale = _scale
