extends CanvasLayer

signal game_started


func _ready():
	$MainMenu.btn_pressed.connect(func(_name): handle_menu_input(_name))


func handle_menu_input( _name: String):
	match _name:
		"Play":
			emit_signal("game_started")
		"Quit":
			get_tree().quit()

# ------------------------------------------------------------------------------

#@onready var menus = get_children().filter( func(x): if x is Control: return x)
#@onready var  curr_menu: Control = $start_menu_container

#var last_menu
#func change_menu( menu_changed_to: Control):
	#last_menu = curr_menu
	#curr_menu.visible       = false
	#menu_changed_to.visible = true
	#curr_menu = menu_changed_to

#menus.map( func(x): if x != curr_menu: x.visible = false)
#
## -- Start menu signals
#$start_menu_container.game_started_clicked.connect( func(): emit_signal("game_started"))
#$start_menu_container.settings_clicked.connect( func(): change_menu($settings_container))
#$start_menu_container.stats_clicked.connect( func(): change_menu($stats_container))
#$start_menu_container.quit_clicked.connect( func(): get_tree().quit())
#
## -- Settings menu signals
#[$settings_container, $stats_container].map( func(x): x.back.connect(func(): change_menu( last_menu)))
