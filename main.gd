extends Node2D

@onready var stage: PackedScene = preload("res://scenes/stage/stage.tscn")

func _ready ():
	# -- center void hole sprite bg
	init_bg()
	get_viewport().size_changed.connect(func(): init_bg())
	# --
	$start_screen.game_started.connect( on_game_started )

	
func init_bg():
	if $start_screen:
		$start_screen/Sprite2D.global_position = get_viewport().get_size() / 2.0


func on_game_started():
	$start_screen.queue_free()
	var _stage = stage.instantiate()
	_stage.stage_ready.connect( make_pause_menu )
	add_child(_stage)


func make_pause_menu():
	pass
	
