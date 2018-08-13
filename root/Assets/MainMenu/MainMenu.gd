extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var game_scene = preload("res://Assets/Main.tscn")
export (PackedScene) var instruction_scene

func _on_ExitButton_down():
	get_tree().quit()


func _on_InstructionButton_down():
	get_tree().change_scene_to(instruction_scene)

func _on_PlayButton_down():
	get_tree().change_scene_to(game_scene)