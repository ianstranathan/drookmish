extends Control


@onready var restart = $MarginContainer/VBoxContainer/Button
@onready var quit    = $MarginContainer/VBoxContainer/Button2
@export var main_scene = "res://main.tscn"

func _ready():
	restart.connect("pressed", func(): get_tree().change_scene_to_file(main_scene))
	quit.connect("pressed", func(): get_tree().quit())

func disable(b: bool) -> void:
	visible = false
	[restart, quit].map( func(x): x.disabled = b)
