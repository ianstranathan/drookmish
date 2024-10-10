extends Camera2D


var min_pos
var max_pos

func jump_to_hotkey_loc( loc: Vector2):
	# -- as long as clikmi can't go out of bounds, the camera limits
	# -- will take of it.
	global_position = loc


func move(pos: Vector2):
	assert(min_pos != null and max_pos != null)
	# -- camera must clamp its own movement due to set limits
	global_position += pos
	global_position = global_position.clamp(min_pos, max_pos)


func set_stage_limits( stage_dims: Vector2):
	var viewport_size_half_size = get_viewport().size / 2.0
	limit_left   = (-stage_dims.x / 2.0) + viewport_size_half_size.x
	limit_right  = ( stage_dims.x / 2.0) - viewport_size_half_size.x
	limit_top    = (-stage_dims.y / 2.0) + viewport_size_half_size.y
	limit_bottom = ( stage_dims.y / 2.0) - viewport_size_half_size.y
	
	min_pos = Vector2(limit_left, limit_top)
	max_pos = Vector2(limit_right, limit_bottom)
