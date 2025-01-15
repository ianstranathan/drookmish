extends Sprite2D


var is_reversed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	$Timer.timeout.connect( func():
		# -- set the shader to be whatever the end time is
		material.set_shader_parameter("_time", $Timer.wait_time)
		$FadeTimer.start())
	$FadeTimer.timeout.connect( func():
		queue_free())
	
	$Area2D.area_entered.connect( func(area: Area2D):
		if area is Clikmi:
			affect_clikmi( area ))


func _process(delta: float) -> void:
	if !$Timer.is_stopped():
		material.set_shader_parameter("_time", $Timer.wait_time - $Timer.time_left)
	elif !$FadeTimer.is_stopped():
		# -- fade time is [0, 1]
		material.set_shader_parameter("fade_time", ($FadeTimer.wait_time - $FadeTimer.time_left) / $FadeTimer.wait_time)


func affect_clikmi (clikmi: Clikmi):
	# -- this is ugly
	if !$Timer.is_stopped():
		if !is_reversed:
			clikmi.grow()
		else:
			clikmi.boost()
	elif !$FadeTimer.is_stopped():
		if !is_reversed:
			clikmi.boost()
		else:
			clikmi.grow()
