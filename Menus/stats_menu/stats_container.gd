extends Control

signal back

func _ready():
	$BackButton.back.connect(func(): emit_signal("back"))
