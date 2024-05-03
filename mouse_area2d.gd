extends Area2D

var maker = null
var can_click_on_maker: bool = true

var clikmi = null

var selected_clikmi: bool = false

var nav_arrow = null
var hovered_over_clikmi = null # -- a area2d reference
var directed_clikmi = null

signal clikmi_selected( a_clikmi )
signal clikmi_moved
signal selection_disabled

@export var selection_bg: Sprite2D

func _ready():
	selection_bg.visible = false
	area_entered.connect( on_area_entered )
	area_exited.connect(  on_area_exited )
	
func _physics_process(delta):
	global_position = get_global_mouse_position()

func _unhandled_input(event):
	# the mouse event should be consumed by either the hovered clicky or the maker
	
	if hovered_over_clikmi and event.is_action_pressed("select"):
		directed_clikmi = hovered_over_clikmi
		directed_clikmi.stop()
		emit_signal("clikmi_selected", directed_clikmi)
		
		selection_bg.global_position = directed_clikmi.global_position
		selection_bg.visible = true
	if directed_clikmi and event.is_action_released("select") and !hovered_over_clikmi:
		directed_clikmi.set_target( global_position )
		emit_signal("clikmi_moved")
		disable_selection()

	if !hovered_over_clikmi and maker and can_click_on_maker and event.is_action_pressed("select"):
		can_click_on_maker = false
		maker.click()
	elif !hovered_over_clikmi and maker and !can_click_on_maker and event.is_action_released("select"):
		can_click_on_maker = true

func on_area_entered(area: Area2D):
	if area is Clikmi and !hovered_over_clikmi:
		hovered_over_clikmi = area
		
	if area is MakerArea:
		maker = area
	#area is Clikmi
	
func on_area_exited(area):
	if area is Clikmi:
		hovered_over_clikmi = null
	
	if area == maker:
		maker = null

func disable_selection():
	selection_bg.visible = false
	directed_clikmi = null
	emit_signal("selection_disabled")
