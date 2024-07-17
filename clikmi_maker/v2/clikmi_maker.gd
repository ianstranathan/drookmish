extends Node2D

@export var num_clicks_to_open: int = 4
var _num_clicks :int = 0
@export var clikmi_container: Node2D
@onready var clikmi_scene: PackedScene = preload("res://clikmi/clikmi.tscn")

# ---------------------------------------------------------------------------
"""
I don't see this dynamically changing, so I'm hardcoding the scale in the shader
"""
#func _ready():
	#$maker_area2d/CollisionShape2D.shape.radius *= _scale
	#$sprites_container.get_children.map( func(x): set_size()

#func set_size(_scale: float):
	# change material uniform accordingly
	#$VoidSprite.scale = _scale
	#$VisualCueSprite.scale = _scale
# ---------------------------------------------------------------------------

"""
With each click:
	- spin speed increases
After enough clicks, tween to final disp.
"""
@onready var sprites = $sprites_container.get_children()
var pillar_disp: float
@onready var top_pillar_orig_pos: Vector2 = $sprites_container/top_pillar.global_position
@onready var bottom_pillar_orig_pos: Vector2 = $sprites_container/bottom_pillar.global_position
@onready var seperation_time: float = $CloseTimer.wait_time
var can_click = true

@export var max_spin_speed := 10.0


func set_speed_uniforms() -> void:
	sprites.map( func(x): x.material.set_shader_parameter("spin_speed",
	float(_num_clicks) / float(num_clicks_to_open)))


func _ready():
	set_speed_uniforms()
	# -----------------------
	$bg_energy.visible = false
	$OpenTimer.timeout.connect(func():
		$bg_energy.visible = false
		screw(true))
	$CloseTimer.timeout.connect(func():
		can_click= true
		)
	# ------------------
	var ring_rad = $SpawnSafeZone/CollisionShape2D.shape.radius
	var pillar_half_len = $sprites_container/top_pillar/Area2D/CollisionShape2D.shape.size.x / 2.0
	pillar_disp = ring_rad - 0.8 * pillar_half_len

func screw(_in:bool=false):
	var in_or_out = 0.0 if _in else 1.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property($sprites_container/top_pillar,
						"global_position",
						 in_or_out * (global_position - Vector2(0., pillar_disp)) + (1.0 - in_or_out) * top_pillar_orig_pos,
						 seperation_time)
	
	tween.tween_property($sprites_container/bottom_pillar,
						"global_position",
						 in_or_out * (global_position + Vector2(0., pillar_disp)) + (1.0 - in_or_out) * bottom_pillar_orig_pos,
						 seperation_time)
	
	if _in: # tween: Tween, s: Sprite2D, uniform_str: String, duration: float, reverse: bool = false):
		Utils.shader_float_tween(tween, $sprites_container/bottom_pillar, "spin_speed", seperation_time, true)
		Utils.shader_float_tween(tween, $sprites_container/top_pillar, "spin_speed", seperation_time, true)
		
	tween.chain().tween_callback( func():
		if _in:
			$CloseTimer.start()
		else:
			$bg_energy.visible = true
			var a_clikmi = clikmi_scene.instantiate()
			clikmi_container.add_clikmi( a_clikmi)
			$OpenTimer.start())


func _unhandled_input(event):
	if can_click:
		if event.is_action_pressed("select"):
			_num_clicks += 1
			_num_clicks = _num_clicks % num_clicks_to_open
			if _num_clicks == 0:
				can_click = false
				screw()
			else:
				set_speed_uniforms()
