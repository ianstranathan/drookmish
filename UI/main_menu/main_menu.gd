extends Control

signal btn_pressed( _name )

func _ready() -> void:
	$VBoxContainer.get_children().map( func(c):
		c.btn_pressed.connect( func(_name): emit_signal("btn_pressed", _name)))
