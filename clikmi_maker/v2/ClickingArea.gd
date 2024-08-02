extends Area2D

class_name MakerArea

signal was_clicked

func click():
	emit_signal("was_clicked")
