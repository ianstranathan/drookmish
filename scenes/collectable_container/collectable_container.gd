extends Node2D

"""
Hovers arond the selected clikmi and spawns collectables within a radius
"""

@onready var polygon_timer_collectable_scene: PackedScene = preload("res://scenes/timer_collectable/polygon_timer_pickup.tscn")
@onready var grow_boost_collectible_scene: PackedScene = preload("res://grow_boost_collectible/nutrient.tscn")
#@onready var rng_fn: Callable = Utils.rng.randi_range
@onready var rngf: Callable = Utils.rng.randf

signal collectible_making_started( fn: Callable )
signal collectable_made(a_collectable)

var selected_clikmi: Clikmi

func selected_clikmi_callback(a_clikmi):
	if a_clikmi and selected_clikmi != a_clikmi:
		selected_clikmi = a_clikmi
		make_collectables()


# -- the collectibles should follow some fn curve
func make_collectables() -> void:
	assert(selected_clikmi)
	emit_signal("collectible_making_started", make_n_collectibles)

@export var radius = 220.0
func rnd_pos() -> Vector2:
	var random_float = rng_f(0.6) # [0.6, 1.6]
	var rng_radius = random_float * radius
	return selected_clikmi.global_position + rng_radius * Vector2(cos(TAU * rng_f()), sin(TAU * rng_f()))


func rnd_threshhold_fn():
	# -- brute force returning something between 0 and 0.5
	var rnd = randf()
	while rnd > 0.5:
		rnd = randf()
	return rnd

@onready var rnd_threshold = rnd_threshhold_fn()
func make_n_collectibles(num_to_make: int = 1):
	for i in range(num_to_make):
		add_collectable()
	
	var _rnd = randf()
	if _rnd < rnd_threshold:
		rnd_threshold = rnd_threshhold_fn()
		add_grow_boost()


func add_grow_boost():
	var child = grow_boost_collectible_scene.instantiate()
	child.global_position = rnd_pos()
	add_child( child )


func rng_f( _min = 0.0 ) -> float:
	return rngf.call() + _min


@onready var possible_time_values = [1, 3, 5]
@onready var rngi: Callable = func(): return Utils.rng.randi_range(0, 2)
func add_collectable():
	var polygon_timer_collectable = polygon_timer_collectable_scene.instantiate()
	
	# -- let the stage know about the collectable to notify it when it's collected
	emit_signal("collectable_made", polygon_timer_collectable)
	#polygon_timer_collectable.bonus_state_fn = add_collectable()
	var index = rngi.call()
	polygon_timer_collectable.time_value = possible_time_values[ index ]
	add_child( polygon_timer_collectable )
	polygon_timer_collectable.global_position = rnd_pos()
