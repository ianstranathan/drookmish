extends Area2D

class_name MakerArea

@export var death_dir: Vector2 = Vector2(0., 1.0)

signal clikmi_crushed( a_clikmi )
signal was_clicked

func _ready():
	area_entered.connect( func(area): 
		if area is Clikmi:
			if (global_position - area.global_position).dot(death_dir) < 0.0:
				emit_signal("clikmi_crushed", area)
	)

func click():
	emit_signal("was_clicked")
