extends AudioStreamPlayer2D

var full_volume_db = -3
var initial_volume_db = -5
var paused_volumed_db = -10


func _ready() -> void:
	set_db("Initial")

func set_db(s: String):
	assert( s in ["Initial", "Full", "Paused"])
	match s:
		"Initial":
			volume_db = initial_volume_db
		"Full":
			volume_db = full_volume_db
		"Paused":
			volume_db = paused_volumed_db
