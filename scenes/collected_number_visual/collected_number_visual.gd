extends Label

func _ready():
	tween_out(Vector2.DOWN)
	
func tween_out(dir: Vector2):
	# -- change the target to currect target (the clikmi) plus some random offset
	# -- make it rotate back and forth randomly
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self,
						 "global_position",
						 global_position + -dir * 75. * (0.1 + Utils.rng.randf()),
						0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,
						 "modulate",
						 Color(1., 1., 1., 0.),
						0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback( func():
		queue_free())
