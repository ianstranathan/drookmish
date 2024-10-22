extends Node2D

@export var num_clicks_to_open: int = 4
var _num_clicks :int = 0
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
@onready var seperation_time: float = 1.0
var can_click = true

@onready var area_2ds = [$sprites_container/top_pillar/Area2D, $sprites_container/bottom_pillar/Area2D]
# ---------------------------------------
@onready var shader_normalized_float_tween = Utils.shader_float_tween
# ---------------------------------------

signal clikmi_instantiated( a_clikmi )


func set_speed_uniforms(b: bool=true) -> void:
	sprites.map( func(x): 
		x.material.set_shader_parameter("spin_speed", 
		float(_num_clicks) / float(num_clicks_to_open) if b else 1.0)

		var tween = create_tween().set_parallel(true)
		shader_normalized_float_tween.call(tween, x, "decay_interpolant", 1.0)
	)

@onready var play_crushed_sound:Callable = Utils.do_fn_if_on_screen($VisibleOnScreenNotifier2D, func(): $CrushedSoundAudioStreamPlayer2D.play())

func _ready():
	$ClickingArea.was_clicked.connect(click)
	# -----------------------------------------
	area_2ds.map(func(x):
		x.clikmi_crushed.connect(func(a_clickmi):
			if screwing_together:
				a_clickmi.crush()
				play_crushed_sound.call()
				)
		# -- moved to ClickingArea
		#x.was_clicked.connect(func():
			#click())
		)
	# -----------------------------------------	
	sprites.map( func(x): x.z_index = Ordering.portal_pillar)
	set_speed_uniforms()
	# -----------------------
	$bg_energy.visible = false
	$bg_energy.z_index = Ordering.bg_portal
	$bg_energy.scale = Vector2.ZERO
	# -----------------------
	$OpenTimer.timeout.connect(func():
		tween_in_bg_portal( true )
		screw(true))

	# ------------------
	var ring_rad = $SpawnSafeZone/CollisionShape2D.shape.radius
	var pillar_half_len = $sprites_container/top_pillar/Area2D/CollisionShape2D.shape.size.x / 2.0
	pillar_disp = ring_rad - 0.8 * pillar_half_len

var screwing_together := false
func screw(_in:bool=false):
	screwing_together = _in
	var in_or_out = 0.0 if _in else 1.0
	if !_in:
		$BgEnergyAudioStreamPlayer2D.play()
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
		# -- this gives a normalized coeff -> in shader it's hit with an easing func and multiplied by some const
		shader_normalized_float_tween.call(tween, $sprites_container/bottom_pillar, "spin_speed", seperation_time, true)
		shader_normalized_float_tween.call(tween, $sprites_container/top_pillar, "spin_speed", seperation_time, true)
		
	tween.chain().tween_callback( func():
		screwing_together = false
		if _in:
			area_2ds.map(func(x): x.set_deferred("disabled", false))
			can_click = true
		else:
			area_2ds.map(func(x): x.set_deferred("disabled", true))
			tween_in_bg_portal()
	)

func add_a_clikmi():
	# -- 
	update_lives( -1 )
	# -- 
	var a_clikmi = clikmi_scene.instantiate()
	#a_clikmi.clikmi_freed.connect(func(_a_clickmi: Clikmi):
		#
		#)
	emit_signal("clikmi_instantiated", a_clikmi)
	$OpenTimer.start()
	

func tween_in_bg_portal(_in: bool = false):
	var tween = create_tween()
	var target_scale: Vector2 = Vector2(0.0, 0.0) if _in else Vector2(1.0, 1.0)
	
	
	tween.tween_property($bg_energy, "scale", target_scale, 0.7).set_trans(Tween.TRANS_ELASTIC)
	if _in:
		tween.tween_callback( func(): 
			$bg_energy.visible = false)
	else:
		$bg_energy.visible = true
		tween.tween_callback( func(): 
			add_a_clikmi())


func update_lives(incr: int):
	_lives += incr
	if _lives == 0:
		out_of_lives_visual_cue( true )
	# -- if lives went from 0 to 1
	elif incr == 1 and _lives == 1:
		out_of_lives_visual_cue( false )

var _lives: int
func initialize_lives(max_lives_num, start_lives_num):
	# -- not using max lives, keeping to make stage initialization cleaner
	_lives = start_lives_num


# -- Pillars should blink or something when there are no more lives
func out_of_lives_visual_cue(b: bool):
	# -- they're the same material/ shader, should only need to send once
	[$sprites_container/top_pillar.material, $sprites_container/bottom_pillar.material].map(
		func(x): x.set_shader_parameter("out_of_lives", 1.0 if b else 0.0)
	)


func click():
	if can_click and _lives > 0:
		_num_clicks += 1
		_num_clicks = _num_clicks % num_clicks_to_open
		if _num_clicks == 0:
			set_speed_uniforms(false)
			can_click = false
			screw()
		else:
			set_speed_uniforms()
