extends Control


signal retry
signal quit


@export var fail_col: Color = Color(1, 0., 0., 1.)
@export var pause_col: Color = Color(1, .9, 0.4, 1.)

func _ready() -> void:
	$VBoxContainer/HBoxContainer/PanelContainer/Retry.connect("pressed", func(): 
		emit_signal("retry"))
	$VBoxContainer/HBoxContainer/PanelContainer2/Quit.connect("pressed", func(): 
		emit_signal("quit"))



func message_settings_fn(_font_size: int, font_col: Color):
	$VBoxContainer/PanelContainer/message.set("theme_override_colors/font_color", font_col)
	$VBoxContainer/PanelContainer/message.set("theme_override_font_sizes/font_size", _font_size)


func disp(message: String):
	assert(message == "Failure" or message == "Paused")
	
	match message:
		"Failure":
			message_settings_fn(90, fail_col)
		"Paused":
			message_settings_fn(60, fail_col)
	#
	$VBoxContainer/PanelContainer/message.text = message
	#
	$VBoxContainer/PanelContainer/message.material.set_shader_parameter("is_paused_message",
		0.0 if message == "Failure" else 1.0)
	#
	var tween = create_tween()
	# tween: Tween, mat: Material, uniform_str: String, duration: float
	Utils.material_shader_float_tween(tween,
									  $VBoxContainer/PanelContainer/message.material,
									  "tt", 
									  3.)
