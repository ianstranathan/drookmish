extends Area2D

@export var time_value: int
@onready var target = null
@export var number_label_scene : PackedScene = preload("res://scenes/collected_number_visual/collected_number_visual.tscn")
"""
1 -> triangle
3 -> square
5 -> pentagon

tweens in like a flower in the precence of player
"""
@export var radius := 18
var num_sides :int = 3

#y = A sin(B(x + C)) + D

func property_value_match_fn(property: int, matches: Array, ret_values: Array):
	if property == matches[0]:
		return ret_values[0]
	elif property == matches[1]:
		return ret_values[1]
	elif property == matches[2]:
		return ret_values[2]
	else:
		var r
		print("no match")
func time_value_fn(n):
	return property_value_match_fn(n, range(3, num_sides + 3), [1, 3, 5])

func col_fn(n) -> Color:
	return property_value_match_fn(n, range(3, num_sides + 3), 
									  [ Color(1.0, 0.0, 0.0, 1.0),
										Color(0.0, 1.0, 0.0, 1.0),
										Color(0.0, 0.0, 1.0, 1.0),])

func _ready():
	var points = create_regular_polygon(num_sides)
	$Polygon2D.polygon = points
	$CollisionPolygon2D.polygon = points
	var col :Color = col_fn(num_sides)
	$PointLight2D.color = col
	$Polygon2D.color = col
	
	time_value = time_value_fn(num_sides)
	bloom_in()

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
	$Polygon2D.scale = Vector2.ZERO
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Polygon2D, "scale", Vector2.ONE,   tween_duration)
	tween.tween_property($Polygon2D, "global_rotation", TAU, tween_duration)
	tween.tween_property($PointLight2D, "energy", 1.0, tween_duration)
	tween.chain().tween_callback( func(): 
		$CollisionPolygon2D.set_deferred( "disabled", false)
		)

var tt = 0.0
@onready var tt_acc_rate = Utils.rng.randf() + 0.2
@onready var tt_instance_offset = 10. * Utils.rng.randf()

var FOLLOW_SPEED = 6.0
func _physics_process(delta):
	tt += delta * tt_acc_rate
	global_rotation = TAU * sin(tt - tt_instance_offset)
	if target:
		FOLLOW_SPEED += delta
		global_position = global_position.lerp(target.global_position, delta * FOLLOW_SPEED)
		if global_position.distance_squared_to(target.global_position) < 36.0: # -- 6 pixels
			pickup()
			#anim_player.play("pickup")
			
func on_area_entered(area: Area2D):
	if area is Clikmi and area!= target:
		var tween = create_tween()
		tween.tween_property(self,
		 "global_position",
		 global_position + -40. * Utils.rel_unit_pos(global_position, area.global_position),
		 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		target = area
		area.clikmi_freed.connect(func(a_clikmi): 
			if target == a_clikmi:
				target = null )
	

func pickup():
	queue_free()
