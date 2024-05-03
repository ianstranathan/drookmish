extends Area2D

class_name Clikmi

@export var tolerance = 50 # in pixels squared
var dir := Vector2.ZERO
var target_loc = null
@export var speed := 200.0

var cam_rect: TextureRect

#----------------------------
signal sucked_in
signal clikmi_freed
@onready var suck_in_timer: Timer = $SuckInTimer
@onready var timer_fn = Utils.timers_remaining_time_normalized
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
		move_state = MoveDirs.IDLE

func _ready():
	suck_in_timer.timeout.connect(func(): 
		emit_signal("sucked_in")
		emit_signal("clikmi_freed", self)
		queue_free())


func _physics_process(delta):
	# move the clikmi to it's target location
	if target_loc:
		euler_update(delta)
	
	if !suck_in_timer.is_stopped():
		anim_player.speed_scale = lerp(1.0, 4.0, timer_fn.call(suck_in_timer))

func stop():
	dir = Vector2.ZERO
	anim_player.play("idle")


func euler_update( delta: float ):
	global_position +=  speed * delta * dir
	# remove target if sufficiently close to destination
	if is_on_target():
		arrived_anim_callback()
		target_loc = null


func is_on_target() -> bool:
	return (target_loc - global_position).length_squared() < tolerance


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

func start_sucking_in():
	$SuckInTimer.start()
	anim_player.play("spin")

func set_dir():
	var rel_pos = target_loc - global_position
	var unit_rel_pos :Vector2 = rel_pos.normalized()


func hotkey_color( col: Vector4, assoc_cam_rect: TextureRect):
	if cam_rect:
		cam_rect.unbind_from_a_clikmi(self)
	cam_rect = assoc_cam_rect
	$Sprite2D.material.set_shader_parameter("color", col)

func remove_hotkey_color():
	$Sprite2D.material.set_shader_parameter("color", 0.0)
