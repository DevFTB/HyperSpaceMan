extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (PackedScene) var game_scene

func _ready():
	OS.set_window_maximized(true)
	$CanvasLayer/MarginContainer.visible = false
	
	pass

func _process(delta):
	if not $VideoPlayer.is_playing() && $VideoPlayer.is_visible_in_tree():
		$CanvasLayer/MarginContainer.visible = true
		$VideoPlayer.visible = false
		
	
		


func _on_Play_button_down():
	get_tree().change_scene_to(game_scene)
