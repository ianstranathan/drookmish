extends Node2D

@export var cam_reference : Camera2D

signal clikmi_selected( a_clikmi )
var selected_clikmi
var hovered_clikmi
var hovered_maker

func _ready():
	Input.set_custom_mouse_cursor(load("res://assets/icons/cursor/cursor_grab.png"))
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # -- using a software cursor for shader utils
	# -- area signals
	$mouse_area2d.maker_hovered.connect( func(area):
		hovered_maker = area)
	$mouse_area2d.clikmi_hovered.connect( func(area):
		hovered_clikmi = area)
	# -- want mouse to be last draw
	$mouse_cursor.z_index = Ordering.software_mouse


func _process(delta):
	global_position = get_global_mouse_position()

var is_pressed = false
var last_mouse_pos

"""
Seperating clikmi code into unhandled even and mouse appearance code
into _input

unhandled will be eaten by icons/ control nodes
this allows camera toggling
"""
func _input(event):
	if event.is_action_pressed("select") and !is_pressed:
		is_pressed = true
		last_mouse_pos = event.position
		$mouse_cursor.material.set_shader_parameter("grabbing", 1.0)
	elif event.is_action_released("select") and is_pressed:
		is_pressed = false
		$mouse_cursor.material.set_shader_parameter("grabbing", 0.0)

func _unhandled_input(event):
	if event.is_action_pressed("select"):
		if hovered_maker:
			hovered_maker.click()
		elif selected_clikmi:
			selected_clikmi.set_target( global_position )
			emit_signal("clikmi_selected", null)
			selected_clikmi = null
		if hovered_clikmi and !selected_clikmi:
			selected_clikmi = hovered_clikmi
			emit_signal("clikmi_selected", selected_clikmi)
			selected_clikmi.play_clikmi_sound()
	if event is InputEventMouseMotion and is_pressed and !hovered_clikmi and cam_reference:
		pan_cam(event.position)

func get_selected_clikmi():
	return selected_clikmi


func pan_cam(event_pos):
	cam_reference.move(-(event_pos - last_mouse_pos))
	last_mouse_pos = event_pos


func clikmi_freed(a_clikmi):
	if a_clikmi == selected_clikmi:
		selected_clikmi = null


# ---------------------------------------------------
# Delete buffer
# ---------------------------------------------------
#func _unhandled_input(event):
	## -- grab and selection
	#print("yo")
	#if event.is_action_pressed("select") and !is_pressed:
		##is_pressed = true
		##last_mouse_pos = event.position
		##$mouse_cursor.material.set_shader_parameter("grabbing", 1.0)
		#
		#if hovered_clikmi and !selected_clikmi:
			#selected_clikmi = hovered_clikmi
			#emit_signal("clikmi_selected", selected_clikmi)
			#selected_clikmi.play_clikmi_sound()
		#elif selected_clikmi:
			#selected_clikmi.set_target( global_position )
			#emit_signal("clikmi_selected", null)
			#selected_clikmi = null
		#if hovered_maker:
			#hovered_maker.click()
			#
	##elif event.is_action_released("select") and is_pressed:
		##is_pressed = false
		##$mouse_cursor.material.set_shader_parameter("grabbing", 0.0)
		##
	## camera panning
	#if event is InputEventMouseMotion and is_pressed and !hovered_clikmi:
		#pan_cam(event.position)
