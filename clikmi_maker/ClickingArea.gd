extends Area2D

class_name ClikmiMakerArea

signal was_clicked

func click():
	emit_signal("was_clicked")
