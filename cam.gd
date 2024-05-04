extends Camera2D

@export var cam_tween_dist = 300

var can_move_again = true

func move( arrow_name ):
	match arrow_name:
		"Up":
			check_limits_and_tween_movement(Vector2.UP, limit_top)
		"Right":
			check_limits_and_tween_movement(Vector2.RIGHT, limit_right)
		"Down":
			check_limits_and_tween_movement(Vector2.DOWN, limit_bottom)
		"Left":
			check_limits_and_tween_movement(Vector2.LEFT, limit_left)


func check_limits_and_tween_movement(dir: Vector2, side_limit: int):
	var limit_remainder
	var half_vp_size = get_viewport().size / 2.0
	if dir == Vector2.RIGHT or dir == Vector2.LEFT: # use x component
		limit_remainder = side_limit - (global_position.x + half_vp_size.x)
	else:
		limit_remainder = side_limit - (global_position.y + + half_vp_size.y)
	
	# if limit remainder is greater than full movement, do full movement, otherwise, dir to limit
	if can_move_again:
		can_move_again = false
		var tween = get_tree().create_tween().set_parallel(true)
		if sign(side_limit) * limit_remainder > cam_tween_dist:
			tween.tween_property(self, "global_position", global_position + (cam_tween_dist * dir), 1).set_trans(Tween.TRANS_SINE)
		else:
			tween.tween_property(self, "global_position", global_position + (limit_remainder * dir), 1.4).set_trans(Tween.TRANS_SINE)
		tween.chain().tween_callback( func(): 
			can_move_again = true)

func set_stage_limits( stage_dims: Vector2):
	limit_left = -stage_dims.x / 2.0
	limit_right =  stage_dims.x / 2.0
	limit_top = -stage_dims.y / 2.0
	limit_bottom = stage_dims.y / 2.0


func jump_to_hotkey_loc( loc: Vector2):
	# -- as long as clikmi can't go out of bounds, the camera limits
	# -- will take of it.
	global_position = loc
