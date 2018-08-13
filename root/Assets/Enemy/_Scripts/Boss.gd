extends "res://Assets/Enemy/_Scripts/Enemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func init(_preset, _position, _scale):
	preset = _preset
	position = _position
	apply_scale(Vector2(_scale, _scale))

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	
	pass

func move(delta):
	
	if (not dead):
		follow_velocity = (vector_to_player.normalized()) * preset.movement_speed
		$Enemy.rotate(PI * delta)
	
	position += (follow_velocity + seperation_velocity) * delta 

func shoot(direction):		
	for i in range(0, preset.amount_of_bullets):
		
		var new_bullet = preset.bullet.instance()
		
		var angle = i * ((2 * PI)/(preset.amount_of_bullets)) + get_node("Enemy").get_transform().get_rotation()	
		
		
		var bullet_position = position
		new_bullet.position = bullet_position
		
		new_bullet.set_damage(preset.damage)
		
		var bullet_direction = Vector2(1,0).rotated(angle) 
		
		print(bullet_direction)
		
		new_bullet.set_direction_and_speed(bullet_direction , follow_velocity.length() + preset.bullet_speed)
		
		get_parent().add_child(new_bullet)
		

