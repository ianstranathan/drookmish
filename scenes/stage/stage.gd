extends Node2D

@export var stage_scale = 0.9
@export var stage_dimensions: Vector2 = Vector2(4000, 4000)
@onready var cam = $Camera2D

@export var level_seconds: float = 60.0 * 5.0

#@onready var mouse_area = $mouse_container/mouse_area2d
@onready var mouse_container = $mouse_container
# -------------------------------------------------------------------
#@export  var MUSIC: bool = true
#@onready var music_fn: Callable = func(): BgMusic.playing = MUSIC
# -------------------------------------------------------------------
@export var game_time_seconds: float = 10.0 
"""
Mouse container is split because the selection icon isn't always the mouse
this is probably not ideal
"""

signal stage_ready

func _ready():
	# ---------------------------------
	# --------- SIGNALS ---------------
	# ---------------------------------
	
	# -- background shader
	$bg.scale = stage_dimensions / Vector2($bg.texture.get_size())
	# ---------------------------------
	# -- Clikmi container signals
	$clikmi_container.clikmi_freed.connect(func(a_clikmi):
		[$vfx_container/VoidHoleShockwaves, mouse_container, $SelectionBg].map( func(x):
			x.clikmi_freed(a_clikmi)))
	$clikmi_container.void_hole_made.connect(func(a_clikmi): 
		$vfx_container/VoidHoleShockwaves.void_hole_made(a_clikmi))
	$clikmi_container.started_being_sucked_in.connect( func(a_clikmi):
		$SelectionBg.remove_clikmi( a_clikmi ))
	$clikmi_container.crown_changed.connect( func(nullable_clikmi):
		$HUD.crown_icon_fn( nullable_clikmi ))
	# ---------------------------------
	# -- Mouse container signals
	mouse_container.clikmi_selected.connect(func(a_clikmi):
		$CollectableContainer.selected_clikmi_callback(a_clikmi)
		$SelectionBg.set_clikmi( a_clikmi ))
	
	# ---------------------------------
	# -- GAME UI
	$HUD.cam_icon_selected.connect(  func( fn: Callable ): fn.call( mouse_container.get_selected_clikmi() ) )
	$HUD.camera_icon_hovered.connect(func( fn: Callable ): fn.call( mouse_container.get_selected_clikmi() ) )
	$HUD.camera_hotkey_pressed.connect(func(loc: Vector2): cam.jump_to_hotkey_loc(loc))
	$HUD.crown_icon_clicked.connect(func(loc: Vector2): cam.jump_to_hotkey_loc(loc))
	# do I want to release a selection if camera hotkey is made?
	#$HUD.camera_hotkey_made.connect(func(): pass)#mouse_area.disable_selection())
	# ---------------------------------
	# -- Clikmi Maker
	$ClikmiMaker.clikmi_instantiated.connect(func(a_clikmi): 
		$clikmi_container.add_clikmi(a_clikmi))
	# ---------------------------------
	# -- Camera	
	cam.set_stage_limits( stage_dimensions )
	# ---------------------------------
	# -- Let lights get information from camera hotkey tex rects
	$camera_lights_container.set_up_light_cols($HUD.get_cam_tex_rects())

	init_level()
	
func init_level():
	#music_fn.call()
	$GameOverMenu.hide()
	$GameTimer.wait_time = level_seconds
	$GameTimer.timeout.connect( game_over )
	$GameTimer.start()

	emit_signal("stage_ready")

func game_over():
	$mouse_container.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$GameOverMenu.show()
