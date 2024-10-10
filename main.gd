extends Node2D

@onready var stage: PackedScene = preload("res://scenes/stage/stage.tscn")

func _ready ():
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
	$start_screen.queue_free()
	var _stage = stage.instantiate()
	_stage.stage_ready.connect(func(): pass)
	_stage.game_over.connect(func():
		get_tree().paused = true;
		$MenusContainer.game_over())
	_stage.game_paused.connect(func(): 
		print("pause")
		get_tree().paused = true;
		$MenusContainer.pause())
	add_child(_stage)

	
