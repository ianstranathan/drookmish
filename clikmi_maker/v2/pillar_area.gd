extends Area2D


@export var death_dir: Vector2

signal clikmi_crushed( a_clikmi )

func _ready():
	assert(death_dir)
	area_entered.connect( func(area): 
		if area is Clikmi:
			if (global_position - area.global_position).dot(death_dir) < 0.0:
				emit_signal("clikmi_crushed", area)
	)

