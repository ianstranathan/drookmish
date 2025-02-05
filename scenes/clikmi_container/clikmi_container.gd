extends Node2D

signal clikmi_freed(    a_clikmi )
signal void_hole_made(  a_clikmi )
signal started_being_sucked_in(a_clikmi )
signal crown_changed( a_clikmi )
signal a_clikmi_scored_points( a_clikmi )
signal clikmi_crushed

@onready var crown = $Crown

func _ready():
	crown.visible = false
	set_process( false )

var highest_time: float = 0.0
var clikmi_with_highest_time: Clikmi


func add_clikmi(a_clikmi):
	a_clikmi.clikmi_crushed.connect(func():
		emit_signal("clikmi_crushed"))
	a_clikmi.clikmi_freed.connect(   func( _a_clikmi): 
		clikmi_died_process_crown(_a_clikmi)
		emit_signal("clikmi_freed",   _a_clikmi))
	a_clikmi.void_hole_made.connect( func( _a_clikmi, _a_void_hole):
		emit_signal("void_hole_made", _a_clikmi, _a_void_hole))
	a_clikmi.started_being_sucked_in.connect(func(_a_clikmi, t):
		emit_signal("started_being_sucked_in", _a_clikmi, t)
		clikmi_died_process_crown(_a_clikmi))
	a_clikmi.timer_collectable_collected.connect(func(a_wait_time, _a_clikmi):
		# -- process just updates crown position
		if !clikmi_with_highest_time:
			clikmi_with_highest_time = _a_clikmi
			init_crown_vars( true, a_wait_time)
			emit_signal("crown_changed", clikmi_with_highest_time)
		elif a_wait_time > highest_time:
			highest_time = a_wait_time
			clikmi_with_highest_time = _a_clikmi
			emit_signal("crown_changed", clikmi_with_highest_time)
		)
	a_clikmi.scored_points.connect( func(_a_clikmi):
		emit_signal("a_clikmi_scored_points", _a_clikmi))
	add_child( a_clikmi )

func clikmi_died_process_crown(a_clikmi):
	if a_clikmi == clikmi_with_highest_time:
		find_next_highest_time(a_clikmi)

# -- there can be asynchronous queue frees, so ignore the clikmi in question
func find_next_highest_time(a_clikmi: Clikmi):
	var clikmis = get_children().filter( func(x): if x is Clikmi: return x)
	if clikmis.size() != 0:
		highest_time = clikmis.reduce( func(accum, another_clikmi):
										if another_clikmi != a_clikmi and another_clikmi.crownable:
											clikmi_with_highest_time = another_clikmi
											return max(another_clikmi.get_void_hole_time(), accum)
										return accum
										, 0.0)
		if highest_time == 0.0:
			clikmi_with_highest_time = null
			init_crown_vars( false )
	else:
		clikmi_with_highest_time = null
		init_crown_vars( false )

	emit_signal("crown_changed", clikmi_with_highest_time)

func init_crown_vars(b: bool, t: float = 0.0):
	crown.visible = b
	highest_time = t
	set_process( b )

var offset := Vector2(0.0, -30.0)

func _process(_delta):
	if crown.global_position != clikmi_with_highest_time.global_position:
		crown.global_position = clikmi_with_highest_time.global_position + offset
	
