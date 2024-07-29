extends Area2D


@export var time_value: int
@onready var anim_player := $AnimationPlayer

# -- DELETE / REPLACE THIS
@onready var coll_rad : float = 20.0

@onready var target = null
@export var number_label_scene : PackedScene = preload("res://scenes/collected_number_visual/collected_number_visual.tscn")
"""
Animation that tweens away then rapidly toward the clikmi picking it up
	
Ideas:
	- more interesting paths
	 - upgrade that controls area 2d radius
"""

@onready var root = get_tree().get_root()
func _ready():
	assert(time_value)
	
	$AnimatedSprite2D.frame = Utils.rng.randi_range(0, 4)
	area_entered.connect( on_area_entered )
	
	#anim_player.animation_finished.connect(func(anim_name):
		#anim_player.stop()
		#number_visual())

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


var FOLLOW_SPEED = 6.0


func _physics_process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, delta * FOLLOW_SPEED)
		if global_position.distance_squared_to(target.global_position) < 36.0: # -- 6 pixels
			anim_player.play("pickup")


func number_visual():
	# -- make a number
	target.time_increase( time_value )
	var number_visual = number_label_scene.instantiate()
	number_visual.text = str(time_value)
	number_visual.global_position = global_position
	root.add_child(number_visual)
	#number_visual.tween_out(Utils.rel_unit_pos(global_position, target.global_position))
	
