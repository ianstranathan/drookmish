extends Control

signal upgrade_selected( data )

"""
Upgrade container frees child resources after upgrade is selected
Remakes resources when upgrade menu is activated
"""

@onready var upgrade_container = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer;
@onready var upgrade_label: Label = $MarginContainer/VBoxContainer/UpgradeDescriptionLabel


var upgrade_arr: Array = [
	{"name": "1UP",
	"offset": 0.0, 
	"label":  "Get an additional life"},
	{"name": "PLACEHOLDER 1",
	"offset": 0.3, 
	"label":  "1. Description here"},
	{"name": "PLACEHOLDER 2",
	"offset": 0.8, 
	"label":  "2. Description here"},
	{"name": "PLACEHOLDER 3",
	"offset": 0.5, 
	"label":  "3. Description here"},
	{"name": "PLACEHOLDER 4",
	"offset": 0.15, 
	"label":  "4. Description here"},
	{"name": "PLACEHOLDER 5",
	"offset": 0.61, 
	"label":  "5. Description here"},
	{"name": "PLACEHOLDER 6",
	"offset": 100.0, 
	"label":  "6. Description here"}]


func _ready() -> void:
	upgrade_container.get_children().map( func(_upgrade_tex_btn): 
		_upgrade_tex_btn.clicked.connect(  signal_out_upgrade_selection)
		_upgrade_tex_btn.hovering.connect( update_upgrade_description ))


func set_upgrade_data_on_btn(_upgrade_tex_rect : TextureButton):
	# -- select the index of upgrade container child in the shuffled upgrade arr
	_upgrade_tex_rect.set_data( upgrade_arr[
		upgrade_container.get_children().find(_upgrade_tex_rect)] )


func update_upgrade_description(upgrade_description):
	if upgrade_label.text != upgrade_description:
		$MarginContainer/VBoxContainer/UpgradeDescriptionLabel.text = upgrade_description

var can_select_lives_upgrade: Callable # -- set by main, function ptr to get  num lives
func signal_out_upgrade_selection( data ):
	if data.name == "1UP":
		if can_select_lives_upgrade.call():
			emit_signal("upgrade_selected", data)
	else:
		emit_signal("upgrade_selected", data)


func select_upgrade():
	upgrade_arr.shuffle() # -- change indices in upgrade arr
	upgrade_container.get_children().map( func(child): set_upgrade_data_on_btn(child))
	visible = true
