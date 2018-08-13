extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"
export (float) var sun_spawn_area_scale

func init(scale, sprites, amount_of_enemies, solar_name, minerals):
	$Sprite.frames = SpriteFrames.new()
	$Sprite.frames.add_animation("rotate")
	$Sprite.frames.set_animation_speed("rotate", rand_range(min_animation_speed, max_animation_speed))
	for i in range(0, len(sprites)):
		$Sprite.frames.add_frame("rotate", load(sprites[i]), i)
	$Sprite.set_frame(randi()%($Sprite.frames.get_frame_count("rotate")))
	$Sprite.play()
	$Sprite.apply_scale(Vector2(scale, scale))
	$CollisionShape2D.apply_scale(Vector2(scale * sun_spawn_area_scale, scale * sun_spawn_area_scale))
	$EnemySpawnArea.apply_scale(Vector2(scale, scale))
	$Path2D.apply_scale(Vector2(scale, scale))
	sun_name = solar_name
	$Particles2D.apply_scale(Vector2(scale, scale))
	
	self.minerals = minerals
	
	_amount_of_enemies = amount_of_enemies
	

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
	
