extends MarginContainer

# -- testing
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug_space"):
		#multiplier_change()

func multiplier_change(increased: bool):
	var _scale = 2.2 if increased else 0.5
	tween_op(0.2, Vector2(_scale, _scale), -PI/10.0, true)


func tween_op(_time: float, _scale: Vector2, rot: float, _callback = false):
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", _scale, _time)
	tween.tween_property(self, "rotation", rot, _time)
	
	if _callback:
		tween.chain().tween_callback( func():
			tween_op(0.3, Vector2(1.0, 1.0), 0.0, false))
		
