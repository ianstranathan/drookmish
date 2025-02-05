extends Control

signal retry
signal quit_to_main( fn )
signal upgrade_selected( data )
signal paused_game( b )

var stage_ref: Node2D

var _can_pause: bool = true

func _ready() -> void:
	visible = true
	reset() # turn everyone off to not get weird visibility feedback switches
	$RetryAndGameOver.retry.connect(func(): emit_signal("retry"))
	$RetryAndGameOver.quit.connect(func(): emit_signal("quit_to_main", func():
		#visible = false
		stage_ref.visible = false
		stage_ref.get_node("HUD").visible = false
		Utils.pause_node(stage_ref, true)))
	$UpgradeMenu.upgrade_selected.connect(func(data):
		_can_pause = true
		pause(level_up_fn(false), false)
		emit_signal("upgrade_selected", data))


func _process(_delta):
	if Input.is_action_just_pressed("pause") and !$RetryAndGameOver.visible:
		pause(pause_game_fn(true), true)
	elif Input.is_action_just_pressed("pause") and $RetryAndGameOver.visible:
		pause(pause_game_fn(false), false)


func reset():
	# -- initialize visibility (Control node won't interact if not visible)
	get_children().map( func(x): x.visible = false)


func pause(fn: Callable, b: bool):
	if _can_pause and stage_ref:
		Utils.pause_node(stage_ref, b)
		fn.call()
		BgMusic.set_db("Paused") if b else BgMusic.set_db("Full")
		
func pause_game_fn(b: bool) -> Callable:
	return func():
		$RetryAndGameOver.visible = b
		$RetryAndGameOver.disp("Paused")


func game_over_fn() -> void:
	$RetryAndGameOver.visible = true
	$RetryAndGameOver.disp("Failure")


func game_over() -> void:
	pause(game_over_fn, true)


func level_up() -> void:
	pause(level_up_fn(true), true)


func level_up_fn(_b: bool) -> Callable:
	return func():
		if _b:
			$UpgradeMenu.select_upgrade()
			_can_pause = _b
