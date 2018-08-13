extends MarginContainer

export (NodePath) var time_spent_box
export (NodePath) var enemies_killed_box
export (NodePath) var max_speed_box
export (NodePath) var minerals_collected_box
export (NodePath) var message_display
export (NodePath) var player
export (NodePath) var timer_object
export (NodePath) var PauseMenu
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var game_ended = false

onready var home_scene = preload("res://Assets/MainMenu/MainMenu.tscn")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Player_end_game(message):
	end_game(message)


	
func fade_in():
	fade(self, "modulate", Color(0, 0, 0, 0), Color(1.0,1.0,1.0, 1.0))
	fade($ColorRect, "color", Color(0.0, 0.0, 0.0, 0), Color(0.1, 0.1, 0.1 ,0.9))
	$Tween.start()

func fade(object, property, start_colour, end_colour):
	$Tween.interpolate_property(object, property, start_colour, end_colour, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)

func _on_ExitButton_button_down():
	if game_ended:
		get_tree().paused = false		
		get_tree().quit()


func _on_HomeButton_button_down():
	if game_ended:
		get_tree().paused = false
		get_tree().change_scene_to(home_scene)


func _on_Main_end_game(message):
	end_game(message)
	
func end_game(message):
	game_ended = true
	get_node(PauseMenu).free()
	fade_in()
	get_node(message_display).text = message
	get_node(enemies_killed_box).text = "Enemies Killed: " + str(get_node(player).enemies_killed)
	get_node(time_spent_box).text = "Time Spent: " + str(int(get_node(timer_object).game_time - get_node(timer_object).time_left)) + " trillion years"
	get_node(max_speed_box).text = "Max Speed: " + str(get_node(player).stats["MaxSpeed"] * 100) + "km/s"
	#get_node(minerals_collected_box) = total minerals collected
	get_tree().paused = true