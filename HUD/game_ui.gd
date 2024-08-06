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
	$MarginContainer/PanelContainer2.game_timer = game_timer


func get_cam_tex_rects() -> Array:
	return camera_tex_rect_container.get_children()


func crown_icon_fn(nullable_clikmi):
	crown_tex_rect.crown_icon_fn(nullable_clikmi)

