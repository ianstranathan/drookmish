extends Sprite2D


func _ready():
	frame_changed.connect( on_frame_changed )

func on_frame_changed() -> void:
	material.set_shader_parameter("frame_num",  frame)
