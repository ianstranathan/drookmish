extends Control

signal upgrade_selected( data )
@onready var upgrade_container = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer;

# -- TODO:
# -- There should be consistent coloring (palette cos offset) for each upgrade
# -- It's currently being set on the object (texture rect) itself, should be managed here

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
]

func shuffle_and_set_upgrades():
	pass


@onready var upgrade_label: Label = $MarginContainer/VBoxContainer/UpgradeDescriptionLabel

func _ready() -> void:
	#visible = false
	
	# -- each texture rect should have different upgrades
	var shuffled_upgrades = upgrade_arr.duplicate()
	shuffled_upgrades.shuffle()
	
	# -- for each upgrade tex rect
	upgrade_container.get_children().map(
		func(x):
			# -- the index of the text rect
			var pseudo_index = upgrade_container.get_children().find(x)
			x.set_data( shuffled_upgrades[pseudo_index] )
			x.clicked.connect( func(data):
				# -- just relay up signal
				emit_signal("upgrade_selected", data))
			x.hovering.connect(func(upgrade_description: String):
				if upgrade_label.text != upgrade_description:
					$MarginContainer/VBoxContainer/UpgradeDescriptionLabel.text = upgrade_description
				))
