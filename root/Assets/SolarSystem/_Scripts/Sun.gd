extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"
export (float) var sun_spawn_area_scale


func _spawn_enemies():
	if rand_range(0, 1) < 0.2:
		var new_boss = preload("res://Assets/Enemy/_Scenes/Boss.tscn").instance()
	
		var new_preset = preload("res://Assets/Enemy/Resources/Presets/Boss/Boss.tres")
		var new_pos = $Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
	
		new_boss.init(new_preset, new_pos, 1.5)
		
		add_child(new_boss)
	else:
		$AudioStreamPlayer2D.play(0)
	
		for i in range(_amount_of_enemies):
			var new_enemy = enemy.instance()
			
			var preset = preload("res://Assets/Enemy/Resources/Presets/Weak Enemies/Weak_enemy.tres")
			var enemy_pos =$Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
			
			new_enemy.init(preset, enemy_pos, 1)
	
			add_child(new_enemy)
	
	spawned_enemies = true;
	
