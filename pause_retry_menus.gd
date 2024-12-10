extends Control

signal retry
signal upgrade_selected


func _ready() -> void:
	# -- turn everyone off to not get weird visibility switches
	reset()
	# -- 
	$RetryAndGameOver.retry.connect(func(): emit_signal("retry"))
	$RetryAndGameOver.quit.connect(func(): get_tree().quit())


func pause(b: bool):
	visible = b
	$RetryAndGameOver.visible = b
	if b:
		$RetryAndGameOver.disp("Paused")


func game_over():
	$RetryAndGameOver.disp("Failure")


func reset():
	visible = false
	get_children().map( func(x): x.visible = false)
