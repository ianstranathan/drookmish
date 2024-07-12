extends Area2D

func _ready():
	area_entered.connect(func(area): if area is Clikmi:
		area.crush())
		
