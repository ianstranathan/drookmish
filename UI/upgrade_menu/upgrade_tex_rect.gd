extends TextureButton


signal clicked( data )
signal hovering( label )
var my_upgrade_data: Dictionary

func _ready() -> void:
	# -- init icon to half transparency
	material.set_shader_parameter("hovered_over", 0.0)
	# -- full transparency on mouse hover
	mouse_entered.connect( func():
		if my_upgrade_data.size() != 0:
			emit_signal("hovering", my_upgrade_data.label)
		material.set_shader_parameter("hovered_over", 1.0))
	# -- half transparency on mouse hover
	mouse_exited.connect( func():
		material.set_shader_parameter("hovered_over", 0.0))
	# -- let someone know this btn got clicked
	pressed.connect( func(): emit_signal("clicked", my_upgrade_data))


func set_data(data: Dictionary):
	my_upgrade_data = data
	# -- offset to visually make upgrades distinct
	material.set_shader_parameter("offset_time", my_upgrade_data["offset"])
