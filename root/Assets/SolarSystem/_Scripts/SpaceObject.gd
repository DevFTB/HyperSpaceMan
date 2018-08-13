extends Area2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var min_animation_speed
export (float) var max_animation_speed
export (String) var tooltip
export (String) var no_minerals_tooltip

var enemy = preload("res://Assets/Enemy/_Scenes/Enemy.tscn")

var _amount_of_enemies

var spawned_enemies = false

var sun_name

var minerals 

var mine_time

var mined_level

func init(scale, sprites, amount_of_enemies, solar_name, minerals):
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
	$Particles2D.apply_scale(Vector2(scale, scale))
	
	_amount_of_enemies = amount_of_enemies 
	
	sun_name = solar_name
	self.minerals = minerals

func set_amount_of_enemies(amount):
	_amount_of_enemies = amount

func _spawn_enemies():
	$AudioStreamPlayer2D.play(0)
	
	for i in range(_amount_of_enemies):
		var new_enemy = enemy.instance()
		
		var preset = preload("res://Assets/Enemy/Resources/Presets/Weak Enemies/Weak_enemy.tres")
		var enemy_pos =$Path2D.curve.get_point_position(rand_range(0 , $Path2D.curve.get_point_count()))
		
		new_enemy.init(preset, enemy_pos, 1)

		add_child(new_enemy)
				
	spawned_enemies = true;
	
func get_minerals():
	return minerals

func get_tooltip(mine_strength):
	if minerals > 0:
		return "Press SPACE to %s planet" % mine_strength
	else:
		return no_minerals_tooltip

func get_mine_time(mine_speed):
	return minerals/mine_speed

func mined(mine_level):
	minerals = 0
	var start_colour = Color(1.0, 1.0, 1.0, 1.0)
	var end_colour = Color(0.35, 0.35, 0.35, 1 - 0.15 * mine_level)
	$Tween.interpolate_property($Sprite, "modulate", start_colour, end_colour, 4.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	$Particles2D.emitting = false
	if mine_level == 8:
		$Particles2D.emitting = true
		no_minerals_tooltip = "Thanos waz here"
	if mine_level == 7:
		no_minerals_tooltip = "TARGET TERMINATED"

func _on_EnemySpawnArea_area_entered(area):
	if(area.get_name() == "Player" && not spawned_enemies):
		_spawn_enemies()
