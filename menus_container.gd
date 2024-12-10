extends Control

signal retry

func _ready() -> void:
	$PauseRetryMenus.retry.connect(func(): emit_signal("retry"))

#func _ready():
	#get_children().map( 
		#func(child):
			#child.visible = false
			#child.retry.connect(func():
				#emit_signal("retry"))
			#child.quit.connect( func(): 
				#get_tree().quit()))

func pause(b: bool):
	$PauseRetryMenus.pause( b )

#func pause(b: bool):
	#$PausedMenu.pause( b )

#func game_over():
	#$GameOverMenu.visible = true
	#
#func reset_menus():
	#get_children().map( func(child):
		#child.visible = false)
