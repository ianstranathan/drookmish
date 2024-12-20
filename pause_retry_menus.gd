extends Control

signal retry
signal upgrade_selected( data )

var stage_ref: Node2D

func _ready() -> void:
	reset() # turn everyone off to not get weird visibility feedback switches
	$RetryAndGameOver.retry.connect(func(): emit_signal("retry"))
	$RetryAndGameOver.quit.connect(func(): get_tree().quit())
	$UpgradeMenu.upgrade_selected.connect(func(data):
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
	visible = true
	fn.call() #if !args else fn.call(args) # -- do relevant UI


func pause_game_fn(b) -> Callable:
	return func():
		$RetryAndGameOver.visible = b
		$RetryAndGameOver.disp("Paused")
	
#func pause_game_fn(b=true):
	#$RetryAndGameOver.visible = true
	#$RetryAndGameOver.disp("Paused")

# ------------------------------------------------------------------------------

func game_over_fn():
	$RetryAndGameOver.visibile = true
	$RetryAndGameOver.disp("Failure")


func game_over():
	pause(game_over_fn, true)

# ------------------------------------------------------------------------------

func level_up():
	pause(level_up_fn, true)


func level_up_fn():
	$UpgradeMenu.visible = true
	
# ------------------------------------------------------------------------------
