extends PanelContainer

signal btn_pressed( _name )

@export var _disabled: bool = false
# -- this is a basic reusable btn, font hover override + random pink mat on the panel
func _ready():
	material.set_shader_parameter("disabled", 1. if _disabled else 0.0)
	
	$Button.disabled = _disabled
	$Button.text = name
	$Button.pressed.connect( func(): emit_signal("btn_pressed", name))

func _on_button_mouse_entered():
	material.set_shader_parameter("t", 1.)

func _on_button_mouse_exited():
	material.set_shader_parameter("t", 0.)
