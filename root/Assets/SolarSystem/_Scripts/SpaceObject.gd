extends Area2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var min_animation_speed
export (float) var max_animation_speed
export (PackedScene) var enemy

var _amount_of_enemies

var spawned_enemies

var sun_name


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
	
	_amount_of_enemies = amount_of_enemies 
	spawned_enemies = false
	
	sun_name = solar_name

func set_amount_of_enemies(amount):
	_amount_of_enemies = amount

func _spawn_enemies():
	$AudioStreamPlayer2D.play(0)
	
	for i in range(_amount_of_enemies):
		var new_enemy = enemy.instance()
		new_enemy.position = $Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
		add_child(new_enemy)
				
	spawned_enemies = true	

func _on_EnemySpawnArea_area_entered(area):
	if(area.get_name() == "Player" && not spawned_enemies):
		_spawn_enemies()
