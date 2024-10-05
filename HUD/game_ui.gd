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

@onready var camera_tex_rect_container = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer/HBoxContainer
@onready var crown_tex_rect = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer2/TextureRect
@onready var meter_timer = $Meter/Timer
@onready var life_tex_rect_scene: PackedScene = preload("res://HUD/life_tex_rect.tscn")

var last_meter_anim_level = 0.0
func _ready():
	$Meter/PanelContainer.material.set_shader_parameter("total_points_lvl", 0.0)
	$Meter/PanelContainer.material.set_shader_parameter("real_time_points_lvl", 0.0)
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
		var uniform_float_fn = func(v: float, m: Material, p: String):
			m.set_shader_parameter(p, v);
		tween.tween_method(uniform_float_fn.bind($Meter/PanelContainer.material, "real_time_points_lvl"), 
						last_meter_anim_level/points_to_next_level, 
						meter_level_collected_points/points_to_next_level, 1.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_callback( func():
			last_meter_anim_level = meter_level_collected_points
			)
		)

func get_cam_tex_rects() -> Array:
	return camera_tex_rect_container.get_children()


func crown_icon_fn(nullable_clikmi):
	crown_tex_rect.crown_icon_fn(nullable_clikmi)

@onready var score_effects_container = $ScoreEffectsContainer
@onready var a_score_effect_scene: PackedScene = preload("res://scenes/VFX/particle_effects/score_effect.tscn")

var points_to_next_level :float = 200.0
var meter_level_collected_points: float = 0.0

func collected_meters_threshold():
	#meter_level_collected_points
	emit_signal("leveled_up", points_to_next_level, func(next_levels_threshold): points_to_next_level = next_levels_threshold)


# -- scoring particle effect
func score_effect(a_clikmi, the_camera: Camera2D, stage_score: int) -> void: #rel_pos_from_camera: Vector2, amount: float) -> void:
	update_total_score_label(stage_score)
	# -------
	var rel_pos_from_camera = a_clikmi.global_position - the_camera.global_position
	var score_particle_system = a_score_effect_scene.instantiate()
	score_effects_container.add_child(score_particle_system)
	 
	score_particle_system.position = (get_viewport().get_size() / 2.0) + rel_pos_from_camera
	# -- target is near the bottom of the meter
	var to_meter_rel_pos = ($Meter.position + 0.93 * $Meter.get_size()) - score_particle_system.position
	var dir = Vector3(to_meter_rel_pos.x, to_meter_rel_pos.y, 0.0)
	var dist = to_meter_rel_pos.length() # -- d / v = lifetime
	var vel = score_particle_system.process_material.initial_velocity_max
	score_particle_system.lifetime = 0.95 * (dist / vel)
	score_particle_system.process_material.set_direction(dir)
	score_particle_system.amount = a_clikmi.void_hole_timer.wait_time
	meter_level_collected_points += a_clikmi.void_hole_timer.wait_time
	score_particle_system.emitting = true
	
	# -- restart timer, don't tween real time mask until timer stops
	meter_timer.start()
	
	score_particle_system.finished.connect( func(): 
		score_particle_system.queue_free()
		$Meter/PanelContainer.material.set_shader_parameter("total_points_lvl", meter_level_collected_points / points_to_next_level)
		)


func write_label_from_number(_label, num, x=""):
	_label.text = str(x, num,)


func update_clikmi_multiplier_visual(num):
	write_label_from_number($MarginContainer3/HBoxContainer/Label, num, "x")


func update_total_score_label(score: int):
	write_label_from_number($MainScoreMarginContainer/Label, score)


var max_num_lives: int
func current_num_lives() -> int:
	return $life_margin_container/HBoxContainer.get_children().size()

func add_a_life():
	var life_icon = life_tex_rect_scene.instantiate()
	$life_margin_container.add_child(life_icon)


func life_count_update(b: bool):
	if b:
		if max_num_lives:
			add_a_life()
		else:
			emit_signal("max_life_num_requested", func(x): 
				max_num_lives = x;
				if current_num_lives() < max_num_lives:
					add_a_life())
