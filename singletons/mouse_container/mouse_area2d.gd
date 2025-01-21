extends Area2D

"""
This controls area signaling
=> mouse hovers over maker or a clikmi, lets mouse container make decisions
"""

signal maker_hovered( maker_ref )
signal clikmi_hovered( clikmi_ref )

func _ready():
	area_entered.connect( on_area_entered )
	area_exited.connect(  on_area_exited )
	

func signal_area_up(area: Area2D, entered=true):
	if area is Clikmi:
		emit_signal( "clikmi_hovered", area if entered else null)
	if area is ClikmiMakerArea:
		emit_signal( "maker_hovered", area if entered else null)
	#if area.is_in_group("CameraHotkey"):
		#print("")
		
func on_area_entered( area: Area2D ):
	signal_area_up( area)


func on_area_exited( area: Area2D):
	signal_area_up( area, false)
