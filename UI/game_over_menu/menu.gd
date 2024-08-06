extends Control


@onready var restart = $MarginContainer/VBoxContainer/Button
@onready var quit    = $MarginContainer/VBoxContainer/Button2

signal restart_clicked
signal quit_clicked

func _ready():

	restart.connect("pressed", func(): emit_signal("restart_clicked"))
	quit.connect(   "pressed", func(): emit_signal("quit_clicked"))
# --------------------------------------------------------------------
# -- parent is set to process only when paused, this makes the following code
# -- unecessary
# --------------------------------------------------------------------
	#disable(true)

#func disable(b: bool) -> void:
	#visible = !b
	#[restart, quit].map( func(x): x.disabled = b)

#func enable() -> void:
	#disable(false)
