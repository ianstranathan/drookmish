extends Node2D

var HOW_MANY_CLICKS_TO_OPEN = 4.0
var MAX_HEALTH = 100.0

var health = MAX_HEALTH
var seconds_at_max_open    = 1.6
var seconds_until_it_opens = 1.2

@export var clikmi_container: Node2D
@export var clikmi_scene: PackedScene

# --------------------------------------------
# -- These are for shader magic to allow for an outline in a sprite sheet
# -- It's a square sprite sheet, so h and v are the same
# --------------------------------------------
@onready var sprite: Sprite2D = $Sprite2D
@onready var h_frame_number = sprite.hframes
@onready var last_frame_count: int = sprite.frame
# @onready var v_frame_number = sprite.vframes

# --------------------------------------------
# -- Shader vars for decaying shake
# --------------------------------------------
@onready var shake_decay_timer = $Sprite2D/ShakeDecayTimer

# --------------------------------------------
# -- Timers used to distinguish animation intervals
# --------------------------------------------
@onready var play_interval_timer             = $PlayIntervalTimer  # -- the timer that plays between shots
@onready var anim_player                     = $AnimationPlayer


func _ready():
	#++++++++++++++++++++++++
	$maker_area2d.clicked_on.connect(func(): 
		if health > 0:
			on_hit_taken())
	#++++++++++++++++++++++++
	
	anim_player.set_current_animation( "open" )
	anim_player.pause()
	init_connections()
	
	$Sprite2D.material.set_shader_parameter("row_number", h_frame_number)
	$Sprite2D.material.set_shader_parameter("decay_time", 5.0)


func _physics_process(delta):
	if shake_decay_timer.time_left > 0:
		$Sprite2D.material.set_shader_parameter("decay_time", shake_decay_timer.wait_time - shake_decay_timer.time_left) # [0 to whatever timer is]


func init_connections() -> void:
	sprite.connect("frame_changed",             on_frame_changed)      # -- ✔
	anim_player.connect("animation_finished",   on_animation_finished) # -- ✔
	play_interval_timer.connect("timeout",      on_play_interval_timer_timeout) # -- plays animation for ratio of time relative to shot damage
	$OpenTimer.connect("timeout",               on_open_timer_timeout)          # -- plays animation from open frame to zenith frame
	$ResourceCollectionTimer.connect("timeout", on_resource_timer_timeout)      # -- delay for how long animation remains on open frame


func on_animation_finished(anim_name) -> void:         # -- callback needs arg
	anim_player.stop()
	$Sprite2D.material.set_shader_parameter("_t", 0.0)


func on_health_depleted() -> void:
	# -- get whatever the last time_increment_to_open_time was add the difference so
	# -- that it smoothly animates to zenith point
	$OpenTimer.wait_time = (seconds_at_max_open - seconds_until_it_opens) # + animation_time_left_til_open # -- keeping numbers to remind myself (frame 12 & 16)
	$OpenTimer.start()
	anim_player.play()

# --------------------------------------------
# -- Animation is in increments of 0.1 seconds, anything less than this has no effect
# -- ✔
# -------------------------------------------- 
func on_hit_taken():
	if health > 0:
		health -= MAX_HEALTH / HOW_MANY_CLICKS_TO_OPEN
		var ratio = 1.0 - (health / MAX_HEALTH)
		# -- case:
		# ----- Health is say 1; damage is 3, => ratio > 1.0
		ratio = min(ratio, 1.0) # -- min should be faster than a clamp
		
		shake_decay_timer.start()
		sprite.material.set_shader_parameter("_t", ratio) # - -[0, 1]
		anim_player.call_deferred( "seek", ratio * seconds_until_it_opens, true) 
		anim_player.call_deferred( "advance", 0.0)

	if health <= 0:
		on_health_depleted()

func on_play_interval_timer_timeout():
	var p =  anim_player.current_animation_position
	#anim_player.pause()


func on_open_timer_timeout() -> void:
	var a_clikmi = clikmi_scene.instantiate()
	clikmi_container.add_clikmi( a_clikmi)
	anim_player.pause()
	$ResourceCollectionTimer.start()


func on_resource_timer_timeout():
	health = MAX_HEALTH
	anim_player.play()


func on_frame_changed() -> void:
	var frame_count = $Sprite2D.frame
	var i = frame_count % h_frame_number
	var j = frame_count / h_frame_number
	$Sprite2D.material.set_shader_parameter("index_vec", Vector2(i, j))
