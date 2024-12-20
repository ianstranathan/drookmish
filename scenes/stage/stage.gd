extends Node2D

@export var stage_scale = 0.9
@export var stage_dimensions: Vector2 = Vector2(4000, 4000)
@onready var cam = $Camera2D

@export var level_seconds: float = 60.0 * 5.0

#@onready var MouseContainer: Node2D = get_node("../../MouseContainer")

# ------------------------------------------------------------------------------
#@export  var MUSIC: bool = true
#@onready var music_fn: Callable = func(): BgMusic.playing = MUSIC
# ------------------------------------------------------------------------------

"""
Mouse container is split because the selection icon isn't always the mouse
this is probably not ideal
"""

signal stage_ready
signal game_over
signal leveled_up

@onready var score: int = 0

# ------------------------------------------------------------------------------
@export var STARTING_LEVEL_POINTS: float = 200.0
@onready var curr_lvl_points: float = STARTING_LEVEL_POINTS
@export var LVL_UP_MULTIPLIER: float = 2.0
# ------------------------------------------------------------------------------
@export var STARTING_LIVES_NUM: int = 3
@onready var num_lives: int = STARTING_LIVES_NUM
@export var MAX_LIVES_NUM: int = 10
# ------------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	pass

func _ready():
	MouseContainer.cam_reference = $Camera2D

	# ---------------------------------
	# --------- SIGNALS ---------------
	# ---------------------------------
	
	# -- background shader
	$bg.scale = stage_dimensions / Vector2($bg.texture.get_size())
	# ---------------------------------
	# -- Clikmi container signals
		# -- I can make the assumption that only a cliky will ever leave from this node
		# -- saves filter call, leaving here for future in case I redesign or w/e
		#$HUD.update_clikmi_multiplier_visual(
			#$clikmi_container.get_children().filter( func(x): return x is Clikmi).size()))
		
	$clikmi_container.clikmi_freed.connect(func(a_clikmi):
		update_lives(false)
		#$HUD.remove_a_clikmi()
		
		# -- hardcoded/ magic 2 needs to go
		# -- it's 2, because: crown child is always there, and the freeing clikmi is still a child
		$HUD.update_clikmi_multiplier_visual( $clikmi_container.get_children().size() - 2) 
		[$vfx_container/VoidHoleShockwaves, MouseContainer, $SelectionBg].map( func(x):
			x.clikmi_freed(a_clikmi)))

	$clikmi_container.void_hole_made.connect(func(a_clikmi): 
		$vfx_container/VoidHoleShockwaves.void_hole_made(a_clikmi))
	$clikmi_container.started_being_sucked_in.connect( func(a_clikmi):
		$SelectionBg.remove_clikmi( a_clikmi ))
	$clikmi_container.crown_changed.connect( func(nullable_clikmi):
		$HUD.crown_icon_fn( nullable_clikmi ))
		
	$clikmi_container.a_clikmi_scored_points.connect(func(a_clikmi):
		# -- increment stage score
		score += int(a_clikmi.void_hole_timer.wait_time)
		# -- 
		$HUD.score_effect(a_clikmi.global_position - cam.global_position,
						  a_clikmi.void_hole_timer.wait_time,
						  score))
	# ---------------------------------
	# -- CollectableContainer signals
	$CollectableContainer.collectable_made.connect(func(a_collectable):
		a_collectable.clikmi_num_fn = func(): return $clikmi_container.get_children().size() - 1)
		
	# -- Mouse container signals
	MouseContainer.clikmi_selected.connect(func(a_clikmi):
		$CollectableContainer.selected_clikmi_callback(a_clikmi)
		$SelectionBg.set_clikmi( a_clikmi ))
	
	# ---------------------------------
	# -- GAME UI
	
	$HUD.cam_icon_selected.connect(  func( fn: Callable ): fn.call( MouseContainer.get_selected_clikmi() ) )
	$HUD.camera_icon_hovered.connect(func( fn: Callable ): fn.call( MouseContainer.get_selected_clikmi() ) )
	$HUD.camera_hotkey_pressed.connect(func(loc: Vector2): cam.jump_to_hotkey_loc(loc))
	$HUD.crown_icon_clicked.connect(func(loc: Vector2): cam.jump_to_hotkey_loc(loc))
	$HUD.game_timer_requested.connect( func(fn: Callable):
		fn.call($GameTimer))
	$HUD.HUD_meter_leveled_up.connect(func(fn: Callable):
		emit_signal("leveled_up")
		curr_lvl_points = LVL_UP_MULTIPLIER * curr_lvl_points
		fn.call(curr_lvl_points))

	# do I want to release a selection if camera hotkey is made?
	#$HUD.camera_hotkey_made.connect(func(): pass)#mouse_area.disable_selection())
	# ---------------------------------
	# -- Clikmi Maker
	$ClikmiMaker.clikmi_instantiated.connect(func(a_clikmi): 
		$clikmi_container.add_clikmi(a_clikmi)
		$HUD.remove_a_life()
		$HUD.update_clikmi_multiplier_visual(
			$clikmi_container.get_children().filter( func(x): return x is Clikmi).size()))
	
	# ---------------------------------
	# -- Camera	
	cam.set_stage_limits( stage_dimensions )
	# ---------------------------------
	# -- Let lights get information from camera hotkey tex rects
	$camera_lights_container.set_up_light_cols($HUD.get_cam_tex_rects())
	
	init_level()
	

func init_level():
	#music_fn.call()
	#$GameTimer.wait_time = level_seconds
	#$GameTimer.timeout.connect( game_over )
	#$GameTimer.start()
	[$ClikmiMaker, $HUD].map( func(x):
		x.initialize_lives(MAX_LIVES_NUM, STARTING_LIVES_NUM))
	#$ClikmiMaker.my_init()
	$HUD.init_level_points(STARTING_LEVEL_POINTS)
	emit_signal("stage_ready")


# -- This is just counting lives to decide to end the game when out of lives
func update_lives(b: bool):
	num_lives += 1 if b else -1
	if num_lives <= 0:
		end_game()


func end_game():
	emit_signal("game_over")
	

func process_upgrade( data ):
	match data.name:
		"1UP":
			print("lvled up")
