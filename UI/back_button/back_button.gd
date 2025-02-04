extends PanelContainer

signal back

func _ready():
	$Button.pressed.connect( func(): emit_signal("back"))
	$Button.mouse_entered.connect( func(): hover_icon(true))
	$Button.mouse_exited.connect( func(): hover_icon(false))


func hover_icon(b):
	material.set_shader_parameter("hover", 1.0 if b else 0.0)
