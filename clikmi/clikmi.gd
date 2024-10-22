extends Area2D

class_name Clikmi

@onready var utils_rng = Utils.rng
@onready var void_hole_timer: Timer = $VoidHoleTimer

#-------------------------------------------------------------------------------
@onready var label_panel = $PanelContainer
@onready var label_panel_label = $PanelContainer/Label
#-------------------------------------------------------------------------------
@export var void_hole_scene: PackedScene
@export var spirit_sprite: PackedScene
@export var score_point_visual_scene: PackedScene = preload("res://scenes/collected_number_visual/collected_number_visual.tscn")
#-------------------------------------------------------------------------------

@export var speed := 200.0

var cam_rect: TextureRect

#-------------------------------------------------------------------------------

signal sucked_in() # -- void hole (REFACTOR THIS PLEASE)
signal started_being_sucked_in( a_clikmi ) # -- clikmi container for crown logic
signal clikmi_freed
signal void_hole_made
signal released_light_pos
signal timer_collectable_collected(this_voids_wait_time, a_clikmi)
signal scored_points(a_clikmi)

#-------------------------------------------------------------------------------
enum MoveDirs{
	IDLE,
	NORTH,
	NORTH_EAST,
	EAST,
	SOUTH_EAST,
	SOUTH,
	SOUTH_WEST,
	WEST,
	NORTH_WEST
}

@onready var anim_player = $AnimationPlayer

#-------------------------------------------------------------------------------
# Fns
#-------------------------------------------------------------------------------
func _ready():
	z_index = Ordering.clikmi_index
	$PanelContainer.visible = false
	# simplify this, it needs to be a minimum of the union of the void hole's timers
	# but probably needs to be tuned for fun
	void_hole_timer.timeout.connect( func():
		make_void_hole())
	$Sprite2D.material.set_shader_parameter("col_switch", 0.)


func _process(delta: float) -> void:
	if !void_hole_timer.is_stopped() and !void_hole_timer.is_paused():
		set_void_hole_label()


func _physics_process(delta):
	if target_fn:
		euler_update(delta)


func make_void_hole():
	label_panel.material.set_shader_parameter("t", 0.0)
	var void_hole = void_hole_scene.instantiate();
	# -- signal for score effect in game UI
	emit_signal("void_hole_made", self)
	#void_hole.tween_anim_in_finished.connect( func(): emit_signal("scored_points", self))
	#$emit_signal("scored_points", self)
	score_points()
	get_tree().root.call_deferred("add_child", void_hole);
	void_hole.global_position = global_position;
	void_hole.z_index = Ordering.black_hole


@onready var root = get_tree().get_root()
func score_points(is_and_one:bool = false):
	emit_signal("scored_points", self)
	var text = "2x" if is_and_one else str(int(void_hole_timer.wait_time))
	var score_point_visual = score_point_visual_scene.instantiate()
	score_point_visual.text = text
	score_point_visual.global_position = global_position + Vector2.LEFT * 20.0
	score_point_visual.z_index = z_index
	root.add_child(score_point_visual)


func and_one():
	score_points(true)

# ------------------------------------------------------------------------------
# -- Kinematics
# ------------------------------------------------------------------------------
#static _ALWAYS_INLINE_ double move_toward(double p_from, double p_to, double p_delta) {
	#return abs(p_to - p_from) <= p_delta ? p_to : p_from + SIGN(p_to - p_from) * p_delta;
#}
@onready var vel := Vector2.ZERO
@export var max_speed : float = 300
@onready var delta_accl : = max_speed / 6.0

func euler_update( delta: float ):
	vel_resolution()
	global_position += delta * vel


@export var tolerance = 50 # in pixels squared
func vel_resolution():
	var rel_pos = target_pos_fn.call() - global_position
	var dist_sqr = (rel_pos).length_squared()
	var _rpn = rel_pos.normalized()
	# --------------------------------------------------------------------------
	# Accumulate acceleration
	if dist_sqr > tolerance:
		vel = vel.move_toward(max_speed * _rpn, max_speed / 10.0)
	elif dist_sqr <= tolerance * 3.0:
		vel = vel.move_toward(Vector2.ZERO, max_speed / 3.0)
	
	# --------------------------------------------------------------------------
	if vel.is_equal_approx(Vector2.ZERO):
		stop_moving()
		
	if is_clikmi_fn.call(target_fn.call()):
		set_animation_dir(target_fn.call().global_position - global_position)
	# --------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# -- Target logic
# ------------------------------------------------------------------------------
func stop_moving():
	anim_player.play("idle")


func visual_follow_cue():
	# turn grey if following
	pass

var clikmi_offset_fn = func(x): return x + 50.0 * (global_position - x).normalized()
var target_pos_fn    = func():  return (clikmi_offset_fn.call(target_fn.call().global_position) if 
											is_clikmi_fn.call(target_fn.call()) else target_fn.call())
var is_clikmi_fn     = func(x): return x is Clikmi
var target_fn

func set_target(x):
	target_fn = func(): return x
	set_animation_dir( target_pos_fn.call() - global_position )
	if x is Clikmi:
		x.clikmi_freed.connect( func():
			target_fn=null)
# ------------------------------------------------------------------------------
# -- Animation functions
# ------------------------------------------------------------------------------
func eight_dir(vec : Vector2) -> int:
	# divide a hemisphere into 8 sections (1 for each slivers of east and west, 2 for north east, west and north)
	var section = PI / 8.0
	var angle = vec.angle_to(Vector2.RIGHT)
	var eight_dir_move
	if angle > 0:
		if angle <= section:
			eight_dir_move = MoveDirs.EAST
		elif angle <= 3.0 * section:
			eight_dir_move = MoveDirs.NORTH_EAST
		elif angle <= 5.0 * section:
			eight_dir_move = MoveDirs.NORTH
		elif angle <= 7.0 * section:
			eight_dir_move = MoveDirs.NORTH_WEST
		else:
			eight_dir_move = MoveDirs.WEST
	elif angle < 0:
		if angle >= -section:
			eight_dir_move = MoveDirs.EAST
		elif angle >= -3.0 * section:
			eight_dir_move = MoveDirs.SOUTH_EAST
		elif angle >= -5.0 * section:
			eight_dir_move = MoveDirs.SOUTH
		elif angle >= -7.0 * section:
			eight_dir_move = MoveDirs.SOUTH_WEST
		else:
			eight_dir_move = MoveDirs.WEST
	else:
		# -- case where angle is essentially zeo (vector2.right)
		if target_pos_fn.call():
			eight_dir_move = MoveDirs.EAST
		else:
			eight_dir_move = MoveDirs.IDLE

	return eight_dir_move


func set_animation_dir(_rel_pos_vec):
	move_anim( eight_dir( _rel_pos_vec.normalized() ) )


func move_anim(eight_dir_move: int):
	match eight_dir_move:
		MoveDirs.IDLE: 
			anim_player.play("idle")
		MoveDirs.NORTH:
			anim_player.play("walk_north")
		MoveDirs.NORTH_EAST:
			anim_player.play("walk_north_east")
		MoveDirs.EAST:
			anim_player.play("walk_east")
		MoveDirs.SOUTH_EAST:
			anim_player.play("walk_south_east")
		MoveDirs.SOUTH:
			anim_player.play("walk_south")
		MoveDirs.SOUTH_WEST:
			anim_player.play("walk_south_west")
		MoveDirs.WEST:
			anim_player.play("walk_west")
		MoveDirs.NORTH_WEST:
			anim_player.play("walk_north_west")


var crownable = true # -- REFACTOR PLEASE
# void_hole_anim_duration --> fn.call()
func start_sucking_in( void_hole_pos, void_hole_timer_fn ):
	crownable = false
	# -- turn off void hole timer to prevent instantiating void holes 
	# -- while tweening inside 
	void_hole_timer.stop()
	
	# -- tween spin and scale
	var t = void_hole_timer_fn.call()
	var tween = create_tween().set_parallel(true)#get_tree().create_tween()
	# -- clikmi sucked in animation should be slightly shorter than the void hole
	tween.tween_property(anim_player, "speed_scale",     5.0,           0.5 * t).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($Sprite2D,   "scale",           Vector2.ZERO,        t).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self,        "global_position", void_hole_pos, 0.8 * t).set_trans(Tween.TRANS_BOUNCE)
	
	# tell that this clikmi is unselectable
	$CollisionShape2D.set_deferred("disabled", true)
	$PanelContainer.visible = false
	emit_signal("started_being_sucked_in", self)
	emit_signal("released_light_pos", self)       # -- this won't change the col of the clikmi, but I kinda like it
	tween.chain().tween_callback( func():
		emit_signal("sucked_in") 
		my_queue_free())
	anim_player.play("spin")


var unbind: Callable
func set_hotkey( cam_rect_unbind_fn, col: Color):
	if unbind:
		emit_signal("released_light_pos", self)
		unbind.call()
	unbind = func(): cam_rect_unbind_fn.call()
	set_color( col )
	
	# -- grab the respective colored light


func set_color(col: Color = Color(0., 0., 0., 0.)):
	var col_uniform = Vector4(col.r, col.g, col.b, col.a)
	if col_uniform != Vector4.ZERO:
		var tween = get_tree().create_tween()
		Utils.shader_float_tween( tween, $Sprite2D, "col_switch", 1.5)
		tween.tween_callback( func():
			var _tween = get_tree().create_tween()
			Utils.shader_float_tween( _tween, $Sprite2D, "col_switch", 1.0, true))
	$Sprite2D.material.set_shader_parameter("color", col_uniform)


func my_queue_free():
	if unbind:
		unbind.call()
	emit_signal("clikmi_freed", self)
	queue_free()
	release_spirit()


func release_spirit():
	var tree = get_tree()
	var spirit = spirit_sprite.instantiate()
	tree.root.add_child(spirit)
	spirit.global_position = global_position
	
	# -- give it a random direction
	var spirit_dir := Vector2(Utils.rng.randf_range(-1.0, 1.0), Utils.rng.randf_range(-1.0, 1.0)).normalized()
	var sprit_loc_xy = Utils.rng.randf_range(1000, 5000) * spirit_dir
	# -- give it a random lifetime
	var spirit_lifetime = Utils.rng.randf_range(10.0, 20.0)
	spirit.global_rotation = Vector2.UP.angle_to(sprit_loc_xy)
	
	var tween = tree.create_tween().set_parallel(true)
	tween.tween_property(spirit, "global_position",  global_position + sprit_loc_xy, spirit_lifetime)
	Utils.material_shader_float_tween(tween, spirit.material, "t", 0.7 * spirit_lifetime)
	#Utils.shader_float_tween(tween, spirit, "transparency_normal_val", spirit_lifetime)
	#tween.chain().tween_callback
	tween.chain().tween_callback(func(): 
		spirit.queue_free())


var crushed: bool = false
func crush():
	if !crushed:
		crushed = true
		my_queue_free()

# -- I want the time indication to start blinking at whatever this is for
# -- all clikmis
@onready var time_to_start_flashing = 0.8 * void_hole_timer.wait_time

func set_void_hole_label():
	if void_hole_timer.time_left <= time_to_start_flashing:
		var t = 1.0 - (void_hole_timer.time_left / time_to_start_flashing)
		label_panel.material.set_shader_parameter("t", t)
	label_panel_label.text = str(int(void_hole_timer.time_left))


func left_safe_zone():
	label_panel.material.set_shader_parameter("is_paused", 0.0)
	# -- for initial case of leaving a safe zone
	if !label_panel.visible:
		label_panel.visible = true
	if void_hole_timer.is_paused():
		void_hole_timer.set_paused( false )


func entered_safe_zone():
	label_panel.material.set_shader_parameter("is_paused", 1.0)
	# -- timer is set to auto start in inspector
	# -- also, weird bug if not set to autostart
	void_hole_timer.set_paused( true )


func get_void_hole_time():
	return void_hole_timer.wait_time


func time_increase( time_num: int) -> void:
	$pickup_particles.emitting = true
	void_hole_timer.wait_time += time_num
	# -- signal for crown logic in clikmi container
	emit_signal("timer_collectable_collected", void_hole_timer.wait_time, self)


@onready var audio_stream_players = $clikmi_sounds_container.get_children()
func play_clikmi_sound() -> void:
	var clikmi_sound_index = utils_rng.randi_range(0., audio_stream_players.size() - 1)
	audio_stream_players[clikmi_sound_index].playing = true
	
# ------------------------------------------------------------------------------
# -- Delete Buffer
# ------------------------------------------------------------------------------

# -- This is already more or less being done with move toward built in
#func arrival_steer():
	#var arrival_radius := 20
	#var rel_pos = target_loc - global_position
	#var distance = rel_pos.length()
	#var steer = Vector2.ZERO
	#if distance > 0:
		#rel_pos.normalize()
		#if distance < arrival_radius:
			#rel_pos *= max_speed * (distance / arrival_radius)
		#else:
			#rel_pos *= max_speed
		#steer = rel_pos - vel
