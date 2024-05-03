extends Node2D

@export var void_hole_scene: PackedScene

var number_of_void_holes = 1.0
@onready var rng = RandomNumberGenerator.new()

signal void_hole_made( a_void_hole, half_percentage_of_map, y_sign, x_sign)

func make_void_hole() -> void:
	var void_hole = void_hole_scene.instantiate()
	add_child( void_hole )
	void_hole.global_position = Vector2(100, 200)
	
	#emit_signal("void_hole_made", place_void_hole(void_hole))

func _physics_process(delta):
	if Input.is_action_just_pressed("debug_space"):
		make_void_hole()

# callback to set the void hold s.t it's not on maker
# & void hole is on map dimensions
func place_void_hole(void_hole: Area2D) -> Callable:
	return func( dimensions: Vector2 ):
		var y_is_neg_or_positive = 1.0 if rng.randf() < 0.5 else -1.0
		var y_axis_pos = y_is_neg_or_positive * rng.randf()
		var x_is_neg_or_positive = 1.0 if rng.randf() < 0.5 else -1.0
		var x_axis_pos = x_is_neg_or_positive * rng.randf()
		
		void_hole.global_position = dimensions * Vector2(x_axis_pos, y_axis_pos)
		void_hole.start_void()


func void_hole_finished(arr_of_clikmis, a_void_hole):
	# do stuff when it's finished
	a_void_hole.queue_free()
