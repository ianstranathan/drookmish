extends Control


@export var restart_btn: Button
@export var quit_btn: Button

signal retry
signal quit

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	restart_btn.connect("pressed", func(): emit_signal("retry"))
	quit_btn.connect(   "pressed", func(): emit_signal("quit"))


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
