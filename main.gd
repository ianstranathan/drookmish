extends Node2D

@onready var vp = get_viewport()
@export var stage_scale = 0.9
@export var stage_dimensions: Vector2 = Vector2(4000, 4000)
@onready var cam = $Camera2D

@export var level_seconds: float = 60.0 * 5.0

var selected_clikmi = null # used to allow camera hotkeys

@onready var mouse_area = $mouse_container/mouse_area2d

func _ready():
	mouse_area.clikmi_selected.connect(func(a_clikmi: Area2D): selected_clikmi = a_clikmi)
	mouse_area.clikmi_moved.connect( func(): selected_clikmi = null)
	mouse_area.selection_disabled.connect( func(): selected_clikmi = null)
	# ---------------------------------
	$bg.scale = stage_dimensions / Vector2($bg.texture.get_size())
	# ---------------------------------
	$clikmi_container.connect("clikmi_freed", func(a_clikmi): 
		if a_clikmi == selected_clikmi:
			mouse_area.disable_selection())
	# ---------------------------------
	$Camera2D.set_stage_limits( stage_dimensions )
	# ---------------------------------
	$void_hole_manager.void_hole_made.connect( func( call_back_fn ): call_back_fn.call(stage_dimensions))

	# ---------------------------------
	$HUD.navigation_arrow_was_clicked.connect(func(dir_str: String): $Camera2D.move( dir_str ) )
	$HUD.cam_icon_selected.connect(func( fn: Callable ): fn.call( selected_clikmi ) )
	$HUD.camera_hotkey_pressed.connect(func(loc: Vector2):$Camera2D.jump_to_hotkey_loc(loc))
	$HUD.camera_icon_hovered.connect(func(fn): fn.call( selected_clikmi ) )
	$HUD.camera_hotkey_made.connect(func(): mouse_area.disable_selection())
