extends Node


func timers_remaining_time_normalized(timer: Timer):
	if !timer.is_stopped():
		return (timer.wait_time - timer.time_left) / timer.wait_time

