extends Control

signal retry
signal quit_to_main( fn )
signal upgrade_selected( data )

var stage_ref: Node2D

func _ready() -> void:
	reset() # turn everyone off to not get weird visibility feedback switches
	$RetryAndGameOver.retry.connect(func(): emit_signal("retry"))
	$RetryAndGameOver.quit.connect(func(): emit_signal("quit_to_main", func():
		visible = false
		stage_ref.visible = false
		stage_ref.get_node("HUD").visible = false
		Utils.pause_node(stage_ref, true)))
	$UpgradeMenu.upgrade_selected.connect(func(data):
		pause(level_up_fn(false), false)
		emit_signal("upgrade_selected", data))


func _process(_delta):
	if Input.is_action_just_pressed("pause") and !$RetryAndGameOver.visible:
		pause(pause_game_fn(true), true)
	elif Input.is_action_just_pressed("pause") and $RetryAndGameOver.visible:
		pause(pause_game_fn(false), false)


func reset():
	# -- initialize visibility (Control node won't interact if not visible)
	visible = false
	get_children().map( func(x): x.visible = false)


func pause(fn: Callable, b: bool):
	if stage_ref:
		# -- turn off the stage branch of scene tree
		Utils.pause_node(stage_ref, b)
	
	# -- need to turn on parent node's visibility
	visible = b
	fn.call() #if !args else fn.call(args) # -- do relevant UI


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
		$UpgradeMenu.select_upgrade()
		#$UpgradeMenu.visible = b
