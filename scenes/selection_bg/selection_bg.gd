extends Sprite2D


var clikmi_ref

func _ready():
	set_process( false)
	visible = false


func set_clikmi( a_clikmi=null):
	if a_clikmi:
		set_process( true )
		visible = true
	else:
		set_process( false )
		visible = false
	clikmi_ref = a_clikmi


func remove_clikmi( a_clikmi):
	if a_clikmi == clikmi_ref:
		set_clikmi()


func _process(_delta):
	global_position = clikmi_ref.global_position


func clikmi_freed(a_clikmi):
	if a_clikmi == clikmi_ref:
		set_process( false)
		visible = false
		clikmi_ref = null
