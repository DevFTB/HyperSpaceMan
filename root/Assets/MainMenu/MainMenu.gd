extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var game_scene = preload("res://Assets/Main.tscn")
onready var instruction_scene = preload("res://Assets/Instructions/Instructions.tscn")

func _ready():
	fade_in()

func _on_ExitButton_down():
	fade_out()
	get_tree().quit()


func _on_InstructionButton_down():
	fade_out()
	get_tree().change_scene_to(instruction_scene)

func _on_PlayButton_down():
	fade_out()
	get_tree().change_scene_to(game_scene)
	
func fade(object, property, start_a, end_a):
	var start_color = Color(1.0, 1.0, 1.0, start_a)
	var end_color = Color(1.0, 1.0, 1.0, end_a)
	$Tween.interpolate_property(object, property, start_color, end_color, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func fade_in():
	fade(self, "modulate", 0.0, 1.0)
	
func fade_out():
	fade(self, "modulate", 1.0, 0.0)