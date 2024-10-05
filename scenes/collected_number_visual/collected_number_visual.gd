extends Label

var tween_time: float = 1.2

func _ready():
	tween_out(Vector2.UP)
	
func tween_out(dir: Vector2):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self,
						 "global_position",
						 global_position + dir * 50.0,
						tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,
						 "modulate",
						 Color(1., 1., 1., 0.),
						tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(self,
						 #"rotation",
						 #rotation + 2. * PI * Utils.rng.randf(),
						#tween_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback( func():
		queue_free())
