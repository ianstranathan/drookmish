extends Panel

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0

signal void_hole_spawning

var void_hole

func _ready():
	pass

func _physics_process(delta) -> void:
	time += delta
	msec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	$HBoxContainer/minutes.text = "%02d:" % minutes
	$HBoxContainer/seconds.text = "%02d." % seconds
	$HBoxContainer/mseconds.text = "%02d" % msec


func stop() -> void:
	set_process(false)


func get_time_formatted() -> String:
	return "%02d:%02d.%03d" % [minutes, seconds, msec]
