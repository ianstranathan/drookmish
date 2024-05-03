extends Node2D

signal clikmi_freed( a_clikmi )

func add_clikmi(a_clikmi):
	add_child( a_clikmi )
	a_clikmi.clikmi_freed.connect( func(_a_clikmi): emit_signal("clikmi_freed", _a_clikmi))
