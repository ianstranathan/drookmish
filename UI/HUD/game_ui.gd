extends CanvasLayer

signal cam_icon_selected(fn )
signal camera_hotkey_pressed(fn)
signal camera_icon_hovered( fn)
signal navigation_arrow_was_clicked( dir_str )
signal camera_hotkey_made
signal hud_initialized(arr_of_tex_rects)
signal crown_icon_clicked( a_clikmi_global_pos)
signal game_timer_timed_out
signal leveled_up
signal game_timer_requested
signal HUD_ready( fn )
signal HUD_meter_leveled_up( fn )

# --------------------------------------------------------------------------------------------------

@onready var camera_tex_rect_container = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer/HBoxContainer
@onready var crown_tex_rect = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer2/TextureRect
@onready var meter_timer = $Meter/Timer
@onready var life_tex_rect_scene: PackedScene = preload("res://UI/HUD/life_texture_rect/life_tex_rect.tscn")

var last_meter_anim_level = 0.0
@onready var score_effects_container = $ScoreEffectsContainer
@onready var a_score_effect_scene: PackedScene = preload("res://scenes/VFX/particle_effects/score_effect.tscn")
var points_to_next_level :float = 0.0
var _score: float = 0.0

@onready var panel_meter_mat: ShaderMaterial = $Meter/PanelContainer.material

@onready var meter_fill_up_particles: GPUParticles2D = $Meter/PanelContainer/StarParticles
func _ready():
	# -- When the meter particles are done animating, let stage know (will pause game for upgrade menu or w/e)
	meter_fill_up_particles.finished.connect( func():
		emit_signal("HUD_meter_leveled_up", meter_filled_up_callback_fn))

	
	panel_meter_mat.set_shader_parameter("total_points_lvl", 0.0)
	panel_meter_mat.set_shader_parameter("real_time_points_lvl", 0.0)
	# -- camera icons
	for child in camera_tex_rect_container.get_children():
		child.cam_icon_selected.connect( func(fn): emit_signal("cam_icon_selected", fn))
		child.camera_hotkey_pressed.connect( func(fn): emit_signal("camera_hotkey_pressed", fn) )
		child.camera_icon_hovered.connect( func(fn): emit_signal("camera_icon_hovered", fn) )
		child.camera_hotkey_made.connect(func(): emit_signal("camera_hotkey_made"))

	# -- crown icons
	crown_tex_rect.crown_icon_clicked.connect(func(a_clickmi_global_pos):
		emit_signal("crown_icon_clicked", a_clickmi_global_pos))

	# -- hook up game timer to game timer visual panel
	$MarginContainer/PanelContainer2.game_timer_requested.connect( func( fn: Callable):
		emit_signal("game_timer_requested", fn))

	# -- meter juice timer
	meter_timer.timeout.connect( func():
		var tween = create_tween()
		
		#-- animate street fighter-esque hit to give immediacy to filling
		var uniform_float_fn = func(v: float, m: Material, p: String):
			m.set_shader_parameter(p, v);
		
		tween.tween_method(uniform_float_fn.bind(panel_meter_mat, "real_time_points_lvl"), 
							hit_effect_meter_lvl(), meter_lvl(), 1.2).set_trans(
							Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

		# -- when the meter is done filling
		# -- if it's full, give visual effect & let the stage know (
		# -- otherwise, just increment animation vars
		tween.tween_callback( func():
			if _score >= points_to_next_level:
				# -- emit the visual cue that the meter is filled
				# -- its finished signal is connected to a callback fn
				# -- callback fn updates the meter anim vars & resets anim
				meter_fill_up_particles.emitting = true
			else:
				last_meter_anim_level = _score)
			)

var previous_points_to_next_level: float = 0.0

func hit_effect_meter_lvl() -> float:
	return (last_meter_anim_level - previous_points_to_next_level)/(points_to_next_level - previous_points_to_next_level)
	
func meter_lvl() -> float:
	return (_score- previous_points_to_next_level)/(points_to_next_level - previous_points_to_next_level)


func meter_filled_up_callback_fn(num: int):
	# -- save last points threshold to normalize meter val
	previous_points_to_next_level = points_to_next_level
	# -- update the points to next level threshold
	points_to_next_level = num
	
	# -- do the shader animation
	last_meter_anim_level = _score
	panel_meter_mat.set_shader_parameter("total_points_lvl", meter_lvl())
	panel_meter_mat.set_shader_parameter("real_time_points_lvl", hit_effect_meter_lvl())
	
	#print("hit ratio", hit_effect_meter_lvl())
	#print("meter ratio", meter_lvl())

func num_lives_from_stage(num_lives: int):
	# -- difference is taken to make initialization and adding life later
	# -- blind
	var num_life_icons_now = life_icon_container.get_children().size()
	var num_icons_to_make = num_lives - num_life_icons_now
	for i in range(num_icons_to_make):
		add_life_icon()
		
#func initialize_lives(max_lives_from_stage: int, starting_lives_num_from_stage: int):
	##max_num_lives = max_lives_from_stage
	#for i in range(starting_lives_num_from_stage):
		#add_a_life()


func get_cam_tex_rects() -> Array:
	return camera_tex_rect_container.get_children()


func crown_icon_fn(nullable_clikmi):
	crown_tex_rect.crown_icon_fn(nullable_clikmi)


func init_level_points(num: float):
	points_to_next_level = num


# -- scoring particle effect
func score_effect(clikmi_rel_pos_from_camera: Vector2, void_timer_points: float, stage_score: int) -> void:
	update_total_score_label(stage_score)
	# --
	var score_particle_system = a_score_effect_scene.instantiate()
	score_effects_container.add_child(score_particle_system)
	# --
	#score_particle_system.position = (get_viewport().get_size() / 2.0) + rel_pos_from_camera
	score_particle_system.position = (get_viewport().get_size() / 2.0) + clikmi_rel_pos_from_camera
	# -- 
	# -- target is near the bottom of the meter
	var to_meter_rel_pos = ($Meter.position + 0.93 * $Meter.get_size()) - score_particle_system.position
	var dir = Vector3(to_meter_rel_pos.x, to_meter_rel_pos.y, 0.0)
	var dist = to_meter_rel_pos.length() # -- d / v = lifetime
	var vel = score_particle_system.process_material.initial_velocity_max
	score_particle_system.lifetime = 0.95 * (dist / vel)
	score_particle_system.process_material.set_direction(dir)
	score_particle_system.amount = void_timer_points
	score_particle_system.emitting = true
	score_particle_system.finished.connect( func(): 
		score_particle_system.queue_free()
		panel_meter_mat.set_shader_parameter("total_points_lvl", 
											 meter_lvl()))
	
	# -- update the total score for meter visual
	_score = stage_score
	
	# -- interpolant for fighter game style juice in meter
	meter_timer.start()  # -- restart timer, don't tween real time mask until timer stops

# -- it probably doesn't make sense to churn data when you could (freeing TextureRect data)
# -- just make it not visible

#var max_num_lives: int
@onready var life_icon_container = $life_margin_container/PanelContainer/HBoxContainer

func add_life_icon():
	var life_icon = life_tex_rect_scene.instantiate()
	life_icon.expand_mode = 3 #EXPAND_FIT_WIDTH_PROPORTIONAL
	life_icon.stretch_mode = 4 #KEEP_ASPECT
	life_icon_container.add_child(life_icon)


#func add_a_life():
	#assert(max_num_lives)
	#if life_icon_container.get_children().size() < max_num_lives:
		#add_life_icon()


func remove_a_life():
	var life_icons = life_icon_container.get_children()
	if life_icons.size() > 0:
		life_icon_container.get_children().pop_back().queue_free()


func write_label_from_number(_label, num, x=""):
	_label.text = str(x, num,)


func update_clikmi_multiplier_visual(num):
	$MarginContainer3/HBoxContainer/Label.material.set_shader_parameter("num_clikmis", num)
	write_label_from_number($MarginContainer3/HBoxContainer/Label, num, "x")

func update_total_score_label(score: int):
	write_label_from_number($MainScoreMarginContainer/Label, score)


func current_num_lives() -> int:
	return $life_margin_container/PanelContainer/HBoxContainer.get_children().size()
