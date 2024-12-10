extends Node2D

@onready var stage: PackedScene = preload("res://scenes/stage/stage.tscn")
@onready var menus_container = $MenusCanvasLayer/MenuContainer

func _ready ():
	menus_container.retry.connect(func():
		restart_game())
	# -- center void hole sprite bg
	init_bg()
	get_viewport().size_changed.connect(func(): init_bg())
	# --
	$start_screen.game_started.connect( on_game_started )

# -- Center screen callback
func init_bg():
	if $start_screen:
		$start_screen/Sprite2D.global_position = get_viewport().get_size() / 2.0


func on_game_started():
	$start_screen.visible = false
	make_and_add_stage()


func restart_game():
	pause(false)
	menus_container.reset()
	delete_last_stage()
	make_and_add_stage()


func delete_last_stage():
	# -- TODO, remove magic indexing
	$stage_container.get_child(0).queue_free()


func make_and_add_stage():
	var _stage = stage.instantiate()
	_stage.stage_ready.connect(func(): 
		pass)
	#_stage.leveled_up.connect():
	#$MenusCanvasLayer/UpgradeMenu.upgrade_selected.connect( func():
		#_stage)
	_stage.game_over.connect(func():
		pause( true, true)
		menus_container.game_over())
	$stage_container.add_child(_stage)


# ------------------------------------------------------------------------------
# -- Pausing utils
# ------------------------------------------------------------------------------
var is_paused := false # -- toggling bool

func pause(b: bool, game_over=false):
	# -- we're disabling the processing of the stage and doing menu stuff
	is_paused = b
	menus_container.pause(is_paused) if !game_over else menus_container.game_over()
	Utils.pause_node($stage_container, is_paused)


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause( !is_paused )
