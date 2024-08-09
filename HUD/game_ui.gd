extends CanvasLayer

signal cam_icon_selected(fn )
signal camera_hotkey_pressed(fn)
signal camera_icon_hovered( fn)
signal navigation_arrow_was_clicked( dir_str )
signal camera_hotkey_made
signal hud_initialized(arr_of_tex_rects)
signal crown_icon_clicked( a_clikmi_global_pos)
signal game_timer_timed_out

@onready var camera_tex_rect_container = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer/HBoxContainer
@onready var crown_tex_rect = $MarginContainer2/PanelContainer/HBoxContainer/MarginContainer2/TextureRect
@onready var game_timer: Timer = $"../GameTimer"

func _ready():
	# -- camera icons
	for child in camera_tex_rect_container.get_children():
		child.cam_icon_selected.connect( func(fn): emit_signal("cam_icon_selected", fn))
		child.camera_hotkey_pressed.connect( func(fn): emit_signal("camera_hotkey_pressed", fn) )
		child.camera_icon_hovered.connect( func(fn): emit_signal("camera_icon_hovered", fn) )
		child.camera_hotkey_made.connect(func(): emit_signal("camera_hotkey_made"))

	# -- crown icons
	crown_tex_rect.crown_icon_clicked.connect(func(a_clickmi_global_pos):
		emit_signal("crown_icon_clicked", a_clickmi_global_pos))

	assert(game_timer)
	# -- give ref to panel displaying time
	$MarginContainer/PanelContainer2.game_timer = game_timer


func get_cam_tex_rects() -> Array:
	return camera_tex_rect_container.get_children()


func crown_icon_fn(nullable_clikmi):
	crown_tex_rect.crown_icon_fn(nullable_clikmi)

@onready var score_effects_container = $ScoreEffectsContainer
@onready var a_score_effect_scene: PackedScene = preload("res://scenes/VFX/particle_effects/score_effect.tscn")

@onready var POINTS_TO_NEXT_LEVEL :float = 1000.0
@onready var collect_points: float = 0.0
func score_effect(a_clikmi, the_camera: Camera2D) -> void: #rel_pos_from_camera: Vector2, amount: float) -> void:
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
	collect_points += a_clikmi.void_hole_timer.wait_time
	score_particle_system.emitting = true
	score_particle_system.finished.connect( func(): 
		score_particle_system.queue_free()
		$Meter/PanelContainer.material.set_shader_parameter("points_lvl", collect_points / POINTS_TO_NEXT_LEVEL)
		)
