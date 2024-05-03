extends TextureRect

signal nav_arrow_clicked( direction_string )

var _can_select: bool = false
@export var direction: String

func _ready():
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect( on_mouse_exited)


func _input(event):
	if _can_select and event.is_action_pressed("select"):
		emit_signal("nav_arrow_clicked", direction)

#func _physics_process(delta):
	#if _can_select:
		#if Input.is_action_just_pressed("select"):
			#emit_signal("nav_arrow_clicked", direction)

func on_mouse_entered():
	_can_select = true
	material.set_shader_parameter("hovered_over", 1.0)

func on_mouse_exited():
	_can_select = false
	material.set_shader_parameter("hovered_over", 0.0)

