extends Area2D

class_name Clikmi

@onready var utils_rng = Utils.rng
@onready var void_hole_timer: Timer = $VoidHoleTimer
@onready var void_hole_timer_time_left_fn = Utils.timers_remaining_time_normalized

# better to have direct ref to something you're querying all the time
@onready var label_panel = $PanelContainer
@onready var label_panel_label = $PanelContainer/Label

@export var void_hole_scene: PackedScene
@export var spirit_sprite: PackedScene
#------------------------

var dir := Vector2.ZERO
var target_loc = null
@export var speed := 200.0

var cam_rect: TextureRect

#----------------------------
signal sucked_in
signal clikmi_freed
signal void_hole_made
signal released_light_pos
#----------------------------
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
var move_state = MoveDirs.IDLE

func eight_dir(vec : Vector2) -> void:
	# divide a hemisphere into 8 sections (1 for each slivers of east and west, 2 for north east, west and north)
	var section = PI / 8.0
	var angle = vec.angle_to(Vector2.RIGHT)
	if angle > 0:
		if angle <= section:
			move_state = MoveDirs.EAST
		elif angle <= 3.0 * section:
			move_state = MoveDirs.NORTH_EAST
		elif angle <= 5.0 * section:
			move_state = MoveDirs.NORTH
		elif angle <= 7.0 * section:
			move_state = MoveDirs.NORTH_WEST
		else:
			move_state = MoveDirs.WEST
	elif angle < 0:
		if angle >= -section:
			move_state = MoveDirs.EAST
		elif angle >= -3.0 * section:
			move_state = MoveDirs.SOUTH_EAST
		elif angle >= -5.0 * section:
			move_state = MoveDirs.SOUTH
		elif angle >= -7.0 * section:
			move_state = MoveDirs.SOUTH_WEST
		else:
			move_state = MoveDirs.WEST
	else:
		# -- case where angle is essentially zeo (vector2.right)
		if target_loc:
			move_state = MoveDirs.EAST
		else:
			move_state = MoveDirs.IDLE


func make_void_hole():
	var void_hole = void_hole_scene.instantiate();
	emit_signal("void_hole_made", self)
	get_tree().root.call_deferred("add_child", void_hole);
	void_hole.global_position = global_position;
	void_hole.z_index = Ordering.black_hole


@export var void_hole_wait_time: float
func _ready():
	z_index = Ordering.clikmi_index
	$PanelContainer.visible = false
	void_hole_timer.wait_time = void_hole_wait_time
	# simplify this, it needs to be a minimum of the union of the void hole's timers
	# but probably needs to be tuned for fun
	void_hole_timer.timeout.connect( func():
		make_void_hole())
	$Sprite2D.material.set_shader_parameter("col_switch", 0.)


func _physics_process(delta):
	# move the clikmi to it's target location
	if target_loc:
		euler_update(delta)
		
	if !void_hole_timer.is_stopped() and !void_hole_timer.is_paused():
		set_void_hole_label()


func stop():
	dir = Vector2.ZERO
	anim_player.play("idle")

#static _ALWAYS_INLINE_ double move_toward(double p_from, double p_to, double p_delta) {
	#return abs(p_to - p_from) <= p_delta ? p_to : p_from + SIGN(p_to - p_from) * p_delta;
#}
@onready var vel := Vector2.ZERO
@export var max_speed : float = 300
@onready var delta_accl : = max_speed / 6.0
func euler_update( delta: float ):
	vel_resolution()
	global_position += delta * vel
	#global_position +=  speed * delta * dir
	# remove target if sufficiently close to destination
	#if is_on_target():
		#arrived_anim_callback()
		#target_loc = null
		
@export var tolerance = 50 # in pixels squared
func vel_resolution():
	var dist_sqr = (target_loc - global_position).length_squared()
	if dist_sqr > tolerance:
		vel = vel.move_toward(max_speed * dir, max_speed / 20.0)
	elif dist_sqr <= tolerance * 3.0:
		vel = vel.move_toward(Vector2.ZERO, max_speed / 3.0)
	
	if vel.is_equal_approx(Vector2.ZERO):
		anim_player.play("idle")
		target_loc = null
	
#func is_on_target() -> bool:
	#return (target_loc - global_position).length_squared() < tolerance
#@export var tolerance = 150 # in pixels squared
#func is_near_target() -> bool:
	#return (target_loc - global_position).length_squared() < tolerance
	#if dir != Vector2.ZERO:
			#velocity = velocity.move_toward(max_speed * dir, delta_accl)
		#else:
			#velocity = velocity.move_toward(Vector2.ZERO, delta_decl)
	
func arrived_anim_callback():
	anim_player.play("idle")


func set_target( pos: Vector2):
	target_loc = pos
	dir = (pos - global_position).normalized()
	eight_dir( dir )
	match move_state:
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

func start_sucking_in( void_hole_pos, void_hole_anim_duration ):
	# -- turn off void hole timer to prevent instantiating void holes 
	# -- while tweening inside 
	void_hole_timer.stop()
	
	# -- tween spin and scale
	var tween = create_tween().set_parallel(true)#get_tree().create_tween()
	# -- clikmi sucked in animation should be slightly shorter than the void hole
	tween.tween_property(anim_player, "speed_scale", 5.0, 0.5 * void_hole_anim_duration).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, void_hole_anim_duration).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "global_position", void_hole_pos, 0.8 * void_hole_anim_duration).set_trans(Tween.TRANS_BOUNCE)
	
	# tell that this clikmi is unselectable
	#emit_signal("clikmi_freed", self)
	$CollisionShape2D.set_deferred("disabled", true)
	$PanelContainer.visible = false
	tween.chain().tween_callback( func(): 
		emit_signal("sucked_in")
		#queue_free()
		my_queue_free())
	anim_player.play("spin")

func set_dir():
	var rel_pos = target_loc - global_position
	var unit_rel_pos :Vector2 = rel_pos.normalized()


#func set_hotkey_color( col: Vector4, assoc_cam_rect: TextureRect):
	##if cam_rect: # if a cam_rect has this saved,
		##cam_rect.unbind_from_a_clikmi(self) # tell it to forget about you
	##cam_rect = assoc_cam_rect
	#$Sprite2D.material.set_shader_parameter("color", col)
#
#func remove_hotkey_color():
	#$Sprite2D.material.set_shader_parameter("color", 0.0)


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

var released_spirit = false
func crush():
	# -- case: area is detected by both pillar pieces and the clikmi hasn't queued free yet
	# ==> can't release spirit if have already released spirit
	# -- spirit resource is added to tree -> it's independent of the resource
	# -- lifetime of the clikmi
	if !released_spirit:
		var tree = get_tree()
		var spirit = spirit_sprite.instantiate()
		tree.root.add_child(spirit)
		spirit.global_position = global_position
		
		# -- give it a random direction
		var sprit_loc_xy = Vector2(Utils.rng.randf_range(-500.0, 500.0), Utils.rng.randf_range(-500.0, 500.0))
		# -- give it a random lifetime
		var spirit_lifetime = Utils.rng.randf_range(4.0, 8.0)
		spirit.global_rotation = Vector2.UP.angle_to(sprit_loc_xy)
		
		var tween = tree.create_tween()
		tween.tween_property(spirit, "global_position", sprit_loc_xy, spirit_lifetime)
		tween.tween_callback(func(): 
			spirit.queue_free())
		my_queue_free()
		released_spirit = true

func set_label_material_params( ):
	pass
	
	
func set_void_hole_label():
	label_panel.material.set_shader_parameter("t", void_hole_timer_time_left_fn.call(void_hole_timer))
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


func time_increase( time_num: int) -> void:
	void_hole_timer.wait_time += time_num

@onready var audio_stream_players = $clikmi_sounds_container.get_children()
func play_clikmi_sound() -> void:
	var clikmi_sound_index = utils_rng.randi_range(0., audio_stream_players.size() - 1)
	audio_stream_players[clikmi_sound_index].playing = true

#@onready var clikmi_wav_sounds
#func init_clikmi_sounds():
	#var sounds_path = "res://assets/SFX/Effects/clikmi_vocalizations/"
	#var dir_contents = []
	#Utils.dir_contents(sounds_path, func(file_name):
		#if ".import" not in file_name:
			#var path = sounds_path + file_name
			#var wav_audio_stream = AudioStreamWAV.new()
			#Utils.load_wav_audio_stream_from_path(path, wav_audio_stream)
			#clikmi_wav_sounds.append(wav_audio_stream)
			#)
#
#func play_clikmi_sound():
	#var clikmi_sound_index = utils_rng.randi_range(0., clikmi_wav_sounds.size() - 1)
	#audio_stream_player.stream = clikmi_wav_sounds[clikmi_sound_index]
	#audio_stream_player.playing = true
