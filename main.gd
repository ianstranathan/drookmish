extends Node2D

@onready var stage: PackedScene = preload("res://scenes/stage/stage.tscn")
@onready var menus_container = $MenusCanvasLayer/MenusContainer

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
	set_process( false )
	set_physics_process( false )
	
func restart_game():
	pause(false)
	menus_container.reset_menus()
	delete_last_stage()
	make_and_add_stage()
	

func delete_last_stage():
	$stage_container.get_child(0).queue_free()


func make_and_add_stage():
	var _stage = stage.instantiate()
	_stage.stage_ready.connect(func(): pass)
	_stage.game_over.connect(func():
		pause( true, true)
		menus_container.game_over())
	$stage_container.add_child(_stage)

func _input(event: InputEvent) -> void:
	pass

# ------------------------------------------------------------------------------
# -- Pausing utils
# ------------------------------------------------------------------------------
var is_paused := false

func pause(b: bool, game_over=false):
	is_paused = b
	menus_container.pause(is_paused) if !game_over else menus_container.game_over()
	Utils.pause_node($stage_container, is_paused)


func _process(_delta):
	if is_paused:
		if Input.is_action_just_pressed("pause"):
			pause( false )
	else:
		if Input.is_action_just_pressed("pause"):
			pause( true )
