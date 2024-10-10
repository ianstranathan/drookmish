extends Control


func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	get_children().map( func(child): 
		child.retry.connect(func(): pass)
		child.quit.connect(func(): get_tree().quit())
		)


func pause():
	$PausedMenu.visible = true
	

func game_over():
	$GameOverMenu.visible = true
