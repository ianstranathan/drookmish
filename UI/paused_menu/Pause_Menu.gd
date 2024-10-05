extends Control

signal pause_menu_quit_clicked
signal pause_menu_retry_clicked

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	$VBoxContainer/HBoxContainer/PanelContainer2/Quit.pressed.connect(func():
		emit_signal("pause_menu_quit_clicked"))
	$VBoxContainer/HBoxContainer/PanelContainer/Retry.pressed.connect(func():
		emit_signal("pause_menu_retry_clicked"))

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
