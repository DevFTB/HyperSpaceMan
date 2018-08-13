extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (int) var game_time
signal end_game

var time_left

func _ready():
	randomize()
	time_left = game_time

func _process(delta):
	time_left = clamp(time_left - delta, 0, INF)
	if time_left <= 0:
		out_of_time()

func out_of_time():
	emit_signal("end_game", "Entropy!")