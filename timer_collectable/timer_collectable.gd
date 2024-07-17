extends Area2D

var target = null
var speed = 200.0

@export var time_value: int

"""
TODO:
	more interesting paths to clikmi
"""

func _ready():
	assert(time_value)
	$Sprite2D/Label.text = str(time_value)
	area_entered.connect( on_area_entered )


func rel_pos(target_pos=null):
	if target_pos:
		return (target_pos - global_position).normalized()
	return (target.global_position - global_position).normalized()


func on_area_entered(area: Area2D):
	if area is Clikmi:
		if !target: # -- only want to animate once
			var tween = create_tween()
			# -- move away from the target, then target is set
			tween.tween_property(self, "global_position", global_position + 40.0 * -rel_pos(area.global_position), 0.75).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.tween_callback( func():
				target = area)


func _physics_process(delta):
	if target:
		speed += 5.0 * delta
		global_position += delta * rel_pos() * speed
		if (target.global_position - global_position).length() < 4.0:
			target.recieved_timer_collectable(time_value)
			queue_free()
