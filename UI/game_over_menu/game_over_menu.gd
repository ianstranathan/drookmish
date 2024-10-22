extends Control

@export var restart_btn: Button
@export var quit_btn: Button

signal retry
signal quit

func _ready():
	restart_btn.connect("pressed", func(): emit_signal("retry"))
	quit_btn.connect(   "pressed", func(): 
		emit_signal("quit"))
