extends Sprite2D


var clikmi_ref

func _ready():
	visible = false

func set_clikmi( a_clikmi=null):
	if a_clikmi:
		visible = true
	else:
		visible = false
	clikmi_ref = a_clikmi
		
func _process(delta):
	if clikmi_ref:
		global_position = clikmi_ref.global_position

func clikmi_freed(a_clikmi):
	if a_clikmi == clikmi_ref:
		visible = false
		clikmi_ref = null
