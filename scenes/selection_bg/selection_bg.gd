extends Sprite2D


var clikmi_ref

func _ready():
	set_process( false)
	visible = false


func toggle_visibility(b):
	set_process( b )
	visible = b
	
func set_clikmi( a_clikmi=null):
	if a_clikmi is Clikmi:
		if clikmi_ref and clikmi_ref != a_clikmi:
			a_clikmi.selection_bg_ref_fn()
		else:
			a_clikmi.selection_bg_ref_fn(self)
			scale = a_clikmi.get_node("Sprite2D").scale
		toggle_visibility(true)
	else:
		toggle_visibility(false)

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
		
		
#if a_clikmi and a_clikmi is Clikmi:
		#set_process( true )
		#visible = true
	#else:
		#set_process( false )
		#visible = false
