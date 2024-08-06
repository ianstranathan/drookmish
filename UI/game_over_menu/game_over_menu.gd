extends CanvasLayer

#@export var _main: PackedScene = preload("res://main.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	# -- change scene to next level
	$Menu.restart_clicked.connect(func():pass)
		# -- will delete the current scene immediately
		# -- https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html
		#get_tree().change_scene_to_packed(_main))
		
	$Menu.quit_clicked.connect(func():
		get_tree().quit())

func game_over():
	$Menu.enable()
