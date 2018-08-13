extends "res://Assets/Enemy/_Scripts/Enemy.gd"
export (int) var angle_change
var current_dir = 0

func init(_preset, _position, _scale):
	preset = _preset
	position = _position
	apply_scale(Vector2(_scale, _scale))

func move(delta):
	
	if (not dead):
		follow_velocity = (vector_to_player.normalized()) * preset.movement_speed
		$Enemy.rotate(PI * delta)
	
	position += (follow_velocity + seperation_velocity) * delta 

func shoot(direction):		
	for i in range(0, preset.amount_of_bullets):
		
		var new_bullet = preset.bullet.instance()
		
		var angle = (i * ((2 * PI)/(preset.amount_of_bullets))) + (current_dir * angle_change)
		current_dir += 1
		
		var bullet_position = position
		new_bullet.position = bullet_position
		
		new_bullet.set_damage(preset.damage)
		
		var bullet_direction = Vector2(1,0).rotated(angle) 
		
		print(bullet_direction)
		
		new_bullet.set_direction_and_speed(bullet_direction , follow_velocity.length() + preset.bullet_speed)
		
		get_parent().add_child(new_bullet)
		
func die():
	dead = true
	player.enemies_killed += 1
	$Enemy/CollisionShape2D.disabled = true
	$Enemy/AnimatedSprite.play("Die")
	$AudioStreamPlayer2D.stop()
