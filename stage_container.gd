extends Node2D


func reset():
	get_children().map( func(c): c.queue_free())
