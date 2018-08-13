extends MarginContainer

onready var home_scene = preload("res://Assets/MainMenu/MainMenu.tscn")

func _ready():
	fade_in()

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_ESCAPE:
		fade_out()
		get_tree().change_scene_to(home_scene)

func fade(object, property, start_a, end_a):
	var start_color = Color(1.0, 1.0, 1.0, start_a)
	var end_color = Color(1.0, 1.0, 1.0, end_a)
	$Tween.interpolate_property(object, property, start_color, end_color, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func fade_in():
	fade(self, "modulate", 0.0, 1.0)
	
func fade_out():
	fade(self, "modulate", 1.0, 0.0)