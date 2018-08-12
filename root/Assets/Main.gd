extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (int) var game_time
var time_left

func _ready():
	randomize()
	time_left = game_time
	

func _process(delta):
	time_left -= delta
