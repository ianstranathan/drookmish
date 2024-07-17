extends Area2D


func _ready():
	area_entered.connect( func(area):
		if area is Clikmi:
			area.entered_safe_zone())

	area_exited.connect( func(area):
		if area is Clikmi:
			area.left_safe_zone())


