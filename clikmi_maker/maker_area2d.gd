extends Area2D

class_name MakerArea

signal clicked_on

func click():
	emit_signal("clicked_on")
