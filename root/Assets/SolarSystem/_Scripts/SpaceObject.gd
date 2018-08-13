extends Area2D
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var min_animation_speed
export (float) var max_animation_speed
export (String) var tooltip
export (String) var no_minerals_tooltip

export (Array, String) var debris_texture_paths

var enemy = preload("res://Assets/Enemy/_Scenes/Enemy.tscn")

var _amount_of_enemies

var spawned_enemies = false

var sun_name

var minerals 

var mine_time

var mined_level

func init(scale, sprites, amount_of_enemies, solar_name, minerals):
	var new_frames = $Sprite.frames.duplicate()
	new_frames.set_animation_speed("rotate", rand_range(min_animation_speed, max_animation_speed))
	for i in range(0, len(sprites)):
		new_frames.add_frame("rotate", load(sprites[i]), i)
		
	
	new_frames.add_animation("debris")
	
	for i in range(0, len(debris_texture_paths)):
		new_frames.add_frame("debris", load(debris_texture_paths[i]), i)
		
	new_frames.set_animation_speed("debris", 1)	
	$Sprite.frames = new_frames
	$Sprite.set_frame(randi()%($Sprite.frames.get_frame_count("rotate")))
	$Sprite.play("rotate")
	
	$Sprite.apply_scale(Vector2(scale, scale))
	$TerminatorSprite.apply_scale(Vector2(scale, scale))
	$CollisionShape2D.apply_scale(Vector2(scale, scale))
	$EnemySpawnArea.apply_scale(Vector2(scale, scale))
	$Path2D.apply_scale(Vector2(scale, scale))
	$IDontFeelSoGood.apply_scale(Vector2(scale, scale))
	$Explode.apply_scale(Vector2(scale, scale))
	
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

	match mine_level:
		7:
			$IDontFeelSoGood.emitting = true
			no_minerals_tooltip = "Thanos waz here"
			fade($Sprite, 0)
		6:
			no_minerals_tooltip = "TARGET TERMINATED"
			$TerminatorSprite.visible = true
			$TerminatorSprite.play()
			
		4, 5: 
			$Explode.emitting = true
			$Sprite.play("debris")
		_:
			fade($Sprite, 1 - 0.1 * mine_level)
		
func fade(sprite, alpha):
	var start_colour = Color(1.0, 1.0, 1.0, 1.0)
	var end_colour = Color(0.35, 0.35, 0.35, alpha)
	$Tween.interpolate_property(sprite, "modulate", start_colour, end_colour, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_EnemySpawnArea_area_entered(area):
	if(area.get_name() == "Player" && not spawned_enemies):
		_spawn_enemies()

func _on_TerminatorSprite_animation_finished():
	$Explode.emitting = true
	fade($TerminatorSprite, 0)
	$Sprite.play("debris")

func get_sun_name():
	return sun_name

func get_planet_name():
	return ""

