extends PanelContainer

#@onready var time_since_engine_started: Callable = Time.get_ticks_msec
#@onready var start_time = time_since_engine_started.call()
@onready var time_label: Label = $MarginContainer/Label
var game_timer: Timer

func time_string()-> String:
	var t_msecs = game_timer.time_left * 1000.0
	var msecs = fmod(t_msecs, 1000.0)
	var seconds = fmod( floor(t_msecs / 1000.0), 60.0)
	var minutes = fmod( floor(t_msecs / 60000.0), 60.0)
	
	# leading number coeff in string interpolation is the padding
	# 3 -> minimum of 3 chars long
	return "%02d:%02d:%03d" % [minutes, seconds, msecs] 

func _physics_process(delta):
	if game_timer:
		time_label.text = time_string()
