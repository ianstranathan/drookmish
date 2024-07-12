extends CanvasLayer


"""
This should be able to connect a clikmi to a camera location
	1) Clikmi is selected
	2) Camera icon is clicked
	3) Any additional clicks on that camera icon will take camera to that location
"""
signal cam_icon_selected(fn )
signal camera_hotkey_pressed(fn)
signal camera_icon_hovered( fn)
signal navigation_arrow_was_clicked( dir_str )
signal camera_hotkey_made

func _ready():
	for child in $ArrowContainer.get_children():
		# connect the navigation to their mouse callbacks
		child.get_child(0).nav_arrow_clicked.connect( 
			func( dir_str): emit_signal("navigation_arrow_was_clicked", dir_str))

	for child in $MarginContainer2/PanelContainer/MarginContainer/HBoxContainer.get_children():
		child.cam_icon_selected.connect( func(fn): emit_signal("cam_icon_selected", fn))
		child.camera_hotkey_pressed.connect( func(fn): emit_signal("camera_hotkey_pressed", fn) )
		child.camera_icon_hovered.connect( func(fn): emit_signal("camera_icon_hovered", fn) )
		child.camera_hotkey_made.connect(func(): emit_signal("camera_hotkey_made"))
