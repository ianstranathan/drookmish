extends Node2D

"""
Hovers arond the selected clikmi and spawns collectables within a radius
"""

@onready var polygon_timer_collectable_scene: PackedScene = preload("res://scenes/timer_collectable/polygon_timer_pickup.tscn")
#@onready var rng_fn: Callable = Utils.rng.randi_range
@onready var rngf: Callable = Utils.rng.randf

signal collectable_made(a_collectable)

var selected_clikmi: Clikmi

func selected_clikmi_callback(a_clikmi):
	if a_clikmi and selected_clikmi != a_clikmi:
		selected_clikmi = a_clikmi
		make_collectables()


# -- the collectibles should follow some fn curve
func make_collectables( num_to_make: int = 1) -> void:
	var radius = 300.0;
	assert(selected_clikmi)
	for i in range(num_to_make):
		var random_float = rng_f(0.6)
		var rng_radius = random_float * radius
		var pos = selected_clikmi.global_position + rng_radius * Vector2(cos(TAU * rng_f()), sin(TAU * rng_f()))
		add_collectable( pos )

func rng_f( _min = 0.0 ) -> float:
	return rngf.call() + _min

@onready var possible_time_values = [1, 3, 5]
@onready var rngi: Callable = func(): return Utils.rng.randi_range(0, 2)
func add_collectable( pos: Vector2, ):
	var polygon_timer_collectable = polygon_timer_collectable_scene.instantiate()
	
	# -- let the stage know about the collectable to notify it when it's collected
	emit_signal("collectable_made", polygon_timer_collectable)
	#polygon_timer_collectable.bonus_state_fn = add_collectable()
	var index = rngi.call()
	polygon_timer_collectable.time_value = possible_time_values[ index ]
	add_child( polygon_timer_collectable )
	polygon_timer_collectable.global_position = pos
	
