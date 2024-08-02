extends Area2D

var clikmis_in_area = []
func _ready():
	area_entered.connect( func(area):
		if area is Clikmi:
			area.entered_safe_zone()
			if clikmis_in_area.size() == 0:
				#if !$AudioStreamPlayer2D.is_playing():
					#$AudioStreamPlayer2D.play()
				$Sprite2D.material.set_shader_parameter("clikmi_is_inside", 1.0)
			clikmis_in_area.append(area)
			)
			

	area_exited.connect( func(area):
		if area is Clikmi:
			clikmis_in_area.erase(area)
			if clikmis_in_area.size() == 0:
				#$AudioStreamPlayer2D.stop()
				$Sprite2D.material.set_shader_parameter("clikmi_is_inside", 0.0)
			area.left_safe_zone())


