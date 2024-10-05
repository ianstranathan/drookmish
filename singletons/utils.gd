extends Node

@onready var rng = RandomNumberGenerator.new()

func set_sprite_to_resolution(sprite_ref: Sprite2D) -> void:
	# scale = res / size
	sprite_ref.scale = Vector2(get_viewport().get_size()) / sprite_ref.texture.get_size()
	

func do_fn_if_on_screen(_notifier: VisibleOnScreenNotifier2D, fn: Callable) -> Callable:
	return func():
		if _notifier.is_on_screen():
			fn.call()

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

"""
Refactor this to not break where it's already being used
Sprite should be optional param (sometimes you're just using a material data structure)
"""
func shader_float_tween(tween: Tween, s: Sprite2D, uniform_str: String, duration: float, reverse: bool = false):
	if reverse:
		tween.tween_method(uniform_float_fn.bind(s, uniform_str), 
						1.0, 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		tween.tween_method(uniform_float_fn.bind(s, uniform_str), 
						0.0, 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)


func material_uniform_float_fn(v: float, mat: Material, p: String):
	mat.set_shader_parameter(p, v);
	
func material_shader_float_tween(tween: Tween, mat: Material, uniform_str: String, duration: float):
	tween.tween_method( material_uniform_float_fn.bind(mat, uniform_str), 
						0.0, 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	

func dir_contents(path, fn):
	var dir = DirAccess.open(path)
	assert(dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				#arr.append(file_name)
				#print("Found directory: " + file_name)
			else:
				fn.call(file_name)
				#print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func load_wav_audio_stream_from_path(path, audio_stream: AudioStreamWAV):
	assert(FileAccess.file_exists(path))
	var file = FileAccess.open(path, FileAccess.READ)
	audio_stream.buffer = file.get_buffer( file.get_length())
