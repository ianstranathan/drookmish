extends Sprite2D


# Called when the node enters the scene tree for the first time.
@export var pitch_modulation_range: float = 0.3
func _ready():
	var pitch_scale_modulation = Utils.rng.randf()
	var plus_or_minus = -1.0 if pitch_scale_modulation >=  0.5 else 1.0
	$AudioStreamPlayer2D.pitch_scale += plus_or_minus * pitch_scale_modulation *  pitch_modulation_range
	$AudioStreamPlayer2D.volume_db += plus_or_minus * pitch_scale_modulation *  pitch_modulation_range
	
func _on_visible_on_screen_notifier_2d_screen_entered():
	$AudioStreamPlayer2D.play()
