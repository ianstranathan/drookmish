extends Node2D

"""
Hovers arond the selected clikmi and spawns collectables within a radius
"""

@onready var polygon_timer_collectable_scene: PackedScene = preload("res://scenes/timer_collectable/polygon_timer_pickup.tscn")
#@onready var rng_fn: Callable = Utils.rng.randi_range
@onready var rngf: Callable = Utils.rng.randf

@export var num_timer_pickups_in_area = 1
var selected_clikmi: Clikmi


func selected_clikmi_callback(a_clikmi):
	if a_clikmi and selected_clikmi != a_clikmi:
		selected_clikmi = a_clikmi
		make_a_bunch_of_collectables()


# -- the collectibles should follow some fn curve
func make_a_bunch_of_collectables() -> void:
	var radius = 300.0;
	assert(selected_clikmi)
	for i in range(num_timer_pickups_in_area):
		var random_float = rng_f(0.6)
		var rng_radius = random_float * radius
		var pos = selected_clikmi.global_position + rng_radius * Vector2(cos(TAU * rng_f()), sin(TAU * rng_f()))
		add_collectable( pos, random_float)

func rng_f( _min = 0.0 ) -> float:
	return rngf.call() + _min

@onready var possible_time_values = [1, 3, 5]

func add_collectable( pos: Vector2, random_01_1: float):
	var index = clamp(round(2.0 * random_01_1), 0, 1)
	var polygon_timer_collectable = polygon_timer_collectable_scene.instantiate()
	polygon_timer_collectable.time_value = possible_time_values[index]
	add_child( polygon_timer_collectable )
	polygon_timer_collectable.global_position = pos
	
