extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"

func _spawn_enemies():
	var new_boss = preload("res://Assets/Enemy/_Scenes/Boss.tscn").instance()
	
	var new_preset = preload("res://Assets/Enemy/Resources/Presets/Boss/Boss.tres")
	var new_pos = $Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
	
	new_boss.init(new_preset, new_pos, 1.5)
	
	add_child(new_boss)
	
	spawned_enemies = true;
	
func get_sun_position():
	return self.global_position
	
