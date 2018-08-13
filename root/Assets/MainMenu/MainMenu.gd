extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (PackedScene) var game_scene
export (PackedScene) var instruction_scene

func _ready():
	OS.set_window_maximized(true)
	$CanvasLayer/MarginContainer.visible = false
	
	pass

func _process(delta):
	if not $VideoPlayer.is_playing() && $VideoPlayer.is_visible_in_tree():
		$CanvasLayer/MarginContainer.visible = true
		$VideoPlayer.visible = false

func _on_ExitButton_down():
	get_tree().quit()


func _on_InstructionButton_down():
	get_tree().change_scene_to(instruction_scene)

func _on_PlayButton_down():
	get_tree().change_scene_to(game_scene)