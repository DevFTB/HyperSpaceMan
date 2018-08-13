extends Node2D
#end game stats vs start game stats
export (float) var time_scale_factor
var preset

var health
var vector_to_player

var seperation_velocity
var follow_velocity

var player
var main

var dead

func init(_preset, _position, _scale):
	preset = _preset
	position = _position
	$Enemy/CollisionShape2D.apply_scale(Vector2(_scale,_scale))
	$Enemy/AnimatedSprite.apply_scale(Vector2(_scale,_scale))
	

func _ready():
	init_sprite()
	
	player = get_node("/root/Main/Player")
	main = get_node("/root/Main")

	seperation_velocity = Vector2(0, 0)
	health = preset.max_health +  (preset.max_health * (time_scale_factor-1)  * (1- (main.time_left/main.game_time)))
	
	$Enemy/FireTimer.wait_time = 1/ preset.fire_rate
	
	$"Life Bar".max_value = preset.max_health
	$"Life Bar".value = preset.max_health
	
	seperate()

func _process(delta):
	vector_to_player =  player.global_position - global_position
	seperation_velocity -= seperation_velocity.normalized() * preset.seperation_drag * delta
	move(delta)
	$"Life Bar".set_rotation(-get_transform().get_rotation())
	

func move(delta):
	
	if (not dead):
		follow_velocity = (vector_to_player.normalized()) * preset.movement_speed
		look_at(player.global_position)
	
	position += (follow_velocity + seperation_velocity) * delta 

func shoot(direction):
	for i in range (0, preset.amount_of_bullets):
		var new_bullet = preset.bullet.instance()
		new_bullet.position = position
		new_bullet.set_damage(preset.damage +  (preset.damage * (time_scale_factor-1)  * (1- (main.time_left/main.game_time))))
		print(preset.damage +  (preset.damage * (time_scale_factor-1)  * (1- (main.time_left/main.game_time))))
	
		new_bullet.set_direction_and_speed(direction, preset.bullet_speed + follow_velocity.length())
		get_parent().add_child(new_bullet)

func seperate():
	seperation_velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1))  * preset.seperation_speed

func reduce_health(decrement):
	health -= decrement
	$"Life Bar".value = health
	if health <= 0:
		die()

func die():
	dead = true
	player.enemies_killed += 1
	$Enemy/CollisionShape2D.disabled = true
	$Enemy/AnimatedSprite.play("Die")

func init_sprite():
	var index = int(rand_range(0, preset.sprite_frames_paths.size()))

	var sprite_frames_path = preset.sprite_frames_paths[index]
	
	var loaded_sprite_frames = load(sprite_frames_path)
	$Enemy/AnimatedSprite.frames = loaded_sprite_frames

func _on_FireTimer_timeout():
	if(not dead):
		shoot(vector_to_player.normalized())


func _on_SeperationTimer_timeout():
	for i in $Enemy.get_overlapping_areas():
		if(i.is_in_group("Enemy")):
			seperate()
			

func _on_AnimatedSprite_animation_finished():
	if($Enemy/AnimatedSprite.animation == "Die"):
		queue_free()
