extends Node2D

export (int) var movement_speed

export (int) var damage
export (int) var max_health

export (float) var bullet_speed
export (float) var fire_rate

export (float) var seperation_speed
export (float) var seperation_drag

export (PackedScene) var bullet

var health
var vector_to_player

var seperation_velocity

var player

func _ready():

	player = get_node("/root/Main/Player")

	seperation_velocity = Vector2(0, 0)
	
	health = max_health
	
	$"Life Bar".value = max_health
	
	seperate()

func _process(delta):
	vector_to_player =  player.global_position - global_position
	seperation_velocity -= seperation_velocity.normalized() * seperation_drag * delta
	move(delta)
	$"Life Bar".set_rotation(-get_transform().get_rotation())
	

func move(delta):
	
	look_at(player.global_position)
	
	var follow_velocity = vector_to_player.normalized() * (vector_to_player.abs().length())
	
	position += (follow_velocity + seperation_velocity) * delta

func shoot(direction):
	var new_bullet = bullet.instance()
	new_bullet.position = position
	new_bullet.set_damage(damage)

	new_bullet.set_direction_and_speed(direction, bullet_speed + movement_speed)
	get_parent().add_child(new_bullet)

func seperate():
	seperation_velocity = Vector2(rand_range(-1, 1), rand_range(-1, 1))  * seperation_speed

func reduce_health(decrement):
	health -= decrement
	$"Life Bar".value = health
	if health <= 0:
		dead()

func dead():
	$Enemy/AnimatedSprite.play("Die")

func _on_FireTimer_timeout():
	
	shoot(vector_to_player.normalized())


func _on_SeperationTimer_timeout():
	for i in $Enemy.get_overlapping_areas():
		if(i.is_in_group("Enemy")):
			seperate()
			

func _on_AnimatedSprite_animation_finished():
	if($Enemy/AnimatedSprite.animation == "Die"):
		queue_free()
