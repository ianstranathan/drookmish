extends TextureRect


var mouse_in_area: bool = false
var selectable: bool = true

var crown_target: Clikmi
signal crown_icon_clicked

func _ready():
	# -- move to individual script?
	mouse_entered.connect(func(): 
		material.set_shader_parameter("hovering", 1.0)
		mouse_in_area = true)
	mouse_exited.connect(func():
		material.set_shader_parameter("hovering", 0.0)
		mouse_in_area = false)


func _input(event):
	if event.is_action_pressed("select") and mouse_in_area and selectable:
		emit_signal("crown_icon_clicked", crown_target.global_position)


func crown_icon_fn(nullable_clikmi):
	crown_target = nullable_clikmi
	selectable = true if nullable_clikmi else false
	material.set_shader_parameter("selectable", 1.0 if selectable else 0.0)
