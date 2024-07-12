extends Node

@onready var rng = RandomNumberGenerator.new()

func set_sprite_to_resolution(sprite_ref: Sprite2D) -> void:
	# scale = res / size
	sprite_ref.scale = Vector2(get_viewport().get_size()) / sprite_ref.texture.get_size()
	

func rel_unit_pos(A: Vector2, B: Vector2) -> Vector2:
	return (B - A).normalized()

func timers_remaining_time_normalized(timer: Timer):
	if !timer.is_stopped():
		return (timer.wait_time - timer.time_left) / timer.wait_time

func uniform_float_fn(v: float, s: Sprite2D, p: String):
	s.material.set_shader_parameter(p, v);

## Helper function to animate using shaders
## Tweens a float to a shader when a timer is too heavy handed
## Binds the args to the 'uniform_float_fn' and then tweens a float
func shader_float_tween(tween: Tween, s: Sprite2D, uniform_str: String, duration: float, reverse: bool = false):
	if reverse:
		tween.tween_method(uniform_float_fn.bind(s, uniform_str), 
						1.0, 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		tween.tween_method(uniform_float_fn.bind(s, uniform_str), 
						0.0, 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
