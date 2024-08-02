extends Node2D

var time_value: int
var target = null
@export var number_label_scene : PackedScene = preload("res://scenes/collected_number_visual/collected_number_visual.tscn")
"""
1 -> triangle
3 -> square
5 -> pentagon

tweens in like a flower in the precence of player
"""
@export var radius := 18
var num_sides

func property_value_match_fn(property: int, matches: Array, ret_values: Array):
	if property == matches[0]:
		return ret_values[0]
	elif property == matches[1]:
		return ret_values[1]
	elif property == matches[2]:
		return ret_values[2]


func time_value_fn(n):
	return property_value_match_fn(n, range(3, num_sides + 3), [1, 2, 3])

func col_fn(n) -> Color:
	return property_value_match_fn(n, range(3, num_sides + 3), 
									  [ Color(1.0, 0.0, 0.0, 0.75),
										Color(0.0, 1.0, 0.0, 0.75),
										Color(0.0, 0.0, 1.0, 0.75),])
										
@onready var polygon_area_2d = $PolygonArea2D
@onready var poly =  polygon_area_2d.get_node("Polygon2D")
@onready var root = get_tree().get_root()
func _ready():
	polygon_area_2d.area_entered.connect(on_polygon_area_entered)
	$TweenArea2D.area_entered.connect(on_tween_area_entered)
	#----------------
	num_sides = property_value_match_fn(time_value, [1,3,5], [3,4,5])
	var col :Color = col_fn(num_sides)
	$PointLight2D.color = col
	# --------------------------------
	initialize_tween_detection_area()
	initialize_polygon_area(col)
	# --------------------------------
	time_value = time_value_fn(num_sides)
	bloom_in()

func initialize_tween_detection_area():
	$TweenArea2D/CollisionShape2D.disabled = true
	

func initialize_polygon_area(a_color: Color):
	# init shape
	var points = create_regular_polygon(num_sides)
	poly.polygon = points
	poly.color = a_color
	var coll_poly = polygon_area_2d.get_node("CollisionPolygon2D")
	coll_poly.polygon = points
	coll_poly.disabled = true


func create_regular_polygon(n_sides: int) -> PackedVector2Array:
	var delta_theta = TAU  / n_sides
	var theta = 0.0
	var arr: PackedVector2Array = []
	for i in range(n_sides):
		var point = radius * Vector2(cos(theta), sin(theta))
		theta += delta_theta
		arr.append(point)
	return arr


func bloom_in() -> void:
	var tween_duration = 0.8
	poly.scale = Vector2.ZERO
	var tween = create_tween().set_parallel(true)
	tween.tween_property(poly, "scale", Vector2.ONE,   tween_duration)
	tween.tween_property(poly, "global_rotation", TAU, tween_duration)
	tween.tween_property($PointLight2D, "energy", 1.0, tween_duration)
	tween.chain().tween_callback( func(): 
		polygon_area_2d.get_node("CollisionPolygon2D").set_deferred( "disabled", false)
		$TweenArea2D/CollisionShape2D.set_deferred("disabled", false)
		)

var tt = 0.0
@onready var tt_acc_rate = Utils.rng.randf() + 0.2
@onready var tt_instance_offset = 10. * Utils.rng.randf()

var FOLLOW_SPEED = 6.0
func _physics_process(delta):
	
	if target:
		FOLLOW_SPEED += delta
		global_position = global_position.lerp(target.global_position, delta * FOLLOW_SPEED)
		#if global_position.distance_squared_to(target.global_position) < 36.0: # -- 6 pixels
			#pickup()
			#anim_player.play("pickup")
	else:
		tt += delta * tt_acc_rate
		global_rotation = TAU * sin(tt - tt_instance_offset)


func on_tween_area_entered(area: Area2D):
	if !target and area is Clikmi:
		var tween = create_tween()
		tween.tween_property(self,
		 "global_position",
		 global_position + -40. * Utils.rel_unit_pos(global_position, area.global_position),
		 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		target = area
		area.clikmi_freed.connect(func(a_clikmi): 
			if target == a_clikmi:
				target = null )


func on_polygon_area_entered(area:Area2D):
	if area == target:
		pickup()

func pickup():
	number_visual()
	queue_free()

func number_visual():
	# -- make a number
	assert(target)
	target.time_increase( time_value )
	var number_visual = number_label_scene.instantiate()
	number_visual.text = str(time_value)
	number_visual.global_position = global_position
	root.add_child(number_visual)
