extends Node2D

@onready var stage_scene: PackedScene = preload("res://scenes/stage/stage.tscn")
@onready var menus_container = $MenusCanvasLayer/MenuContainer

func _ready ():
	# --------------------------------------------------------------------------
	menus_container.retry.connect(func():
		restart_game())
	menus_container.upgrade_selected.connect(func(data):
		# -- there should only  ever be one stage, but mapping over children
		# -- is nicer syntax imo than naming it or indexing it
		$stage_container.get_children().map( func(x):
			x.process_upgrade( data )))
	# --------------------------------------------------------------------------
	
	# -- center start screeen
	$start_screen/Sprite2D.global_position = get_viewport().get_size() / 2.0
	
	#get_viewport().size_changed.connect(func(): pass)
	#$Vector2(get_viewport().get_size()) / $start_screen/ColorRect.texture.get_size()
	# -- start game signal
	$start_screen.game_started.connect( on_game_started )
	

func on_game_started():
	$start_screen.visible = false
	make_and_add_stage()


func restart_game():
	menus_container.reset()
	delete_last_stage()
	make_and_add_stage()


func delete_last_stage():
	$stage_container.get_children().map( func(x): x.queue_free())


func make_and_add_stage():
	var _stage = stage_scene.instantiate()
	
	# -- let the menu container have a reference to it to pause it
	menus_container.stage_ref = _stage
	# -- this doesn't need to know anything else (when it's freed,
	# -- it will either end or be replaced and the pointer will 
	# -- just be changed in this same make_and_add_stage func
	
	_stage.stage_ready.connect(func(): 
		pass)
	_stage.leveled_up.connect( func():
		menus_container.level_up())
	_stage.game_over.connect(func():
		menus_container.game_over())
	$stage_container.add_child(_stage)
