extends Control

@export var restart_btn: Button
@export var quit_btn: Button

signal retry
signal quit

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	restart_btn.connect("pressed", func(): emit_signal("retry"))
	quit_btn.connect(   "pressed", func(): emit_signal("quit"))

var can_unpause := false

func toggle_pause_menu(b: bool) -> void:
	can_unpause = b
	visible = b
	
func _process(delta):
	if can_unpause:
		if Input.is_action_just_pressed("pause"):
			toggle_pause_menu( false )
			get_tree().paused = false
	else:
		toggle_pause_menu( true )
