extends PanelContainer


@export var text: String = "Play"

signal btn_pressed

func _ready():
	#$Button.disabled = true
	$Button.text = text
	$Button.pressed.connect( func(): emit_signal("btn_pressed"))

func _on_button_mouse_entered():
	material.set_shader_parameter("t", 1.)

func _on_button_mouse_exited():
	material.set_shader_parameter("t", 0.)

