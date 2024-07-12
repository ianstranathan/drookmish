extends Sprite2D

var can_bake: bool = false

func _ready():
	$Timer.timeout.connect(func(): can_bake = true)
	$Timer.start()
	
func _process(delta):
	if can_bake and Input.is_action_just_pressed("debug_space"):
		bake_tex()

func bake_tex() -> void:
	can_bake = false
	var img:Image = texture.get_image()
	img.save_png("res://assets/baking/baked_images/baked_image.png")
