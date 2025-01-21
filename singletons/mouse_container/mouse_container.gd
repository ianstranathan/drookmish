extends Node2D


@export var cam_reference : Camera2D

signal clikmi_selected( a_clikmi )
var selected_clikmi
var hovered_clikmi
var hovered_maker

@onready var grabbing_img: Resource = load("res://assets/icons/cursor/cursor_grabbing.png")
@onready var open_palm_img: Resource = load("res://assets/icons/cursor/cursor_grab.png")

func _ready():
	Input.set_custom_mouse_cursor(load("res://assets/icons/cursor/cursor_grab.png"))

	$mouse_area2d.maker_hovered.connect( func(area):
		hovered_maker = area)
	$mouse_area2d.clikmi_hovered.connect( func(area):
		hovered_clikmi = area)


# -- sprite and coll shape aren't quite matching up
@onready var offset_length = $mouse_area2d/CollisionShape2D.shape.radius
@onready var offset = 0.7 * Vector2(offset_length, offset_length)
func _process(_delta):
	global_position = get_global_mouse_position() + offset


var left_mouse_btn_is_pressed = false
var right_mouse_btn_is_pressed = false
var last_mouse_pos

"""
Seperating clikmi code into unhandled even and mouse appearance code
into _input

unhandled will be eaten by icons/ control nodes
this allows camera toggling
"""

var hovering_over_cam_tex_rect = false

func _input(event):
	if event.is_action_pressed("select") and !left_mouse_btn_is_pressed:
		left_mouse_btn_is_pressed = true
		last_mouse_pos = event.position
		Input.set_custom_mouse_cursor(grabbing_img)
		left_mouse_btn_fn()
	elif event.is_action_released("select") and left_mouse_btn_is_pressed:
		left_mouse_btn_is_pressed = false
		Input.set_custom_mouse_cursor(open_palm_img)
	elif event.is_action_pressed("right_click") and selected_clikmi and !right_mouse_btn_is_pressed:
		right_mouse_btn_is_pressed = true
		right_mouse_btn_fn()
	elif event.is_action_released("right_click") and right_mouse_btn_is_pressed:
		right_mouse_btn_is_pressed = false
	elif event is InputEventMouseMotion and left_mouse_btn_is_pressed and !hovered_clikmi and cam_reference:
		pan_cam(event.position)


func left_mouse_btn_fn():
	if hovered_maker:
		hovered_maker.click()
	# --
	#elif hovered_clikmi and hovered_clikmi != selected_clikmi and !hovering_over_cam_tex_rect:
		#selected_clikmi.set_target( hovered_clikmi )
		#emit_signal("clikmi_selected", null)
		#selected_clikmi = null
	# -- 
	elif selected_clikmi and !hovering_over_cam_tex_rect:
		
		if hovered_clikmi and hovered_clikmi != selected_clikmi and !hovering_over_cam_tex_rect:
			selected_clikmi.set_target( hovered_clikmi )
			#emit_signal("clikmi_selected", null)
			#selected_clikmi = null
		else:
			selected_clikmi.set_target( global_position )
			#emit_signal("clikmi_selected", null)
			#selected_clikmi = null
		emit_signal("clikmi_selected", null)
		selected_clikmi = null
	if hovered_clikmi and !selected_clikmi:
		selected_clikmi = hovered_clikmi
		emit_signal("clikmi_selected", selected_clikmi)
		selected_clikmi.play_clikmi_sound()


func right_mouse_btn_fn():
	if hovered_clikmi and hovered_clikmi != selected_clikmi and !hovering_over_cam_tex_rect:
		selected_clikmi.set_target( hovered_clikmi )
		emit_signal("clikmi_selected", null)
		selected_clikmi = null


func get_selected_clikmi():
	return selected_clikmi


func pan_cam(event_pos):
	cam_reference.move(-(event_pos - last_mouse_pos))
	last_mouse_pos = event_pos


func clikmi_freed(a_clikmi):
	if a_clikmi == selected_clikmi:
		selected_clikmi = null
