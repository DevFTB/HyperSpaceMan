extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
	

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func init(scale, sprites, amount_of_enemies, solar_name):
	$Sprite.frames = SpriteFrames.new()
	$Sprite.frames.add_animation("rotate")
	$Sprite.frames.set_animation_speed("rotate", rand_range(min_animation_speed, max_animation_speed))
	for i in range(0, len(sprites)):
		$Sprite.frames.add_frame("rotate", load(sprites[i]), i)
	$Sprite.set_frame(randi()%($Sprite.frames.get_frame_count("rotate")))
	$Sprite.play()
	$Sprite.apply_scale(Vector2(scale, scale))
	$CollisionShape2D.apply_scale(Vector2(scale, scale))
	$EnemySpawnArea.apply_scale(Vector2(scale, scale))
	$Path2D.apply_scale(Vector2(scale, scale))
	sun_name = solar_name
	

func _spawn_enemies():
	var new_boss = preload("res://Assets/Enemy/_Scenes/Boss.tscn").instance()
	
	var new_preset = preload("res://Assets/Enemy/Resources/Presets/Boss/Boss.tres")
	var new_pos = $Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
	
	new_boss.init(new_preset, new_pos, 3)
	
	add_child(new_boss)
				
	spawned_enemies = true;
	
