extends Control

signal game_started_clicked
signal settings_clicked
signal stats_clicked
signal quit_clicked

func _ready():
	$VBoxContainer/Play.btn_pressed.connect( func(): emit_signal("game_started_clicked"))
	$VBoxContainer/Settings.btn_pressed.connect( func(): emit_signal("settings_clicked"))
	$VBoxContainer/Stats.btn_pressed.connect( func(): emit_signal("stats_clicked"))
	$VBoxContainer/Quit.btn_pressed.connect( func(): emit_signal("quit_clicked"))
