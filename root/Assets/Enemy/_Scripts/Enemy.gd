extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (int) var speed
export (float) var bullet_speed
export (float) var fire_rate
export (int) var damage
export (int) var max_health

var health
var position_from_player

var seperate
export (float) var seperation_velocity

var player

var bullet = preload("res://Assets/Enemy/_Scenes/Bullet.tscn") # Will load when parsing the script.

func _ready():
	health = max_health
	player = get_node("/root/Main/Player")
	seperation_velocity *= Vector2(rand_range(-1, 1), rand_range(-1, 1)) 
	$"Life Bar".value = max_health

func _process(delta):
	move(delta)
	$"Life Bar".set_rotation(-get_transform().get_rotation())

func move(delta):
	position_from_player =  player.global_position - global_position
	
	var delta_movement = position_from_player.normalized() * speed * delta
	
	if seperate == true:
		delta_movement += seperation_velocity * delta
	
	look_at(player.global_position)
	
	if health <= 0:
		queue_free()
	
	look_at(player.global_position)
	
	position += delta_movement

func reduce_health(decrement):
	health -= decrement
	$"Life Bar".value = health
	if health <= 0:
		queue_free()

func shoot(direction):
	var new_bullet = bullet.instance()
	new_bullet.position = position
	new_bullet.set_damage(damage)

	
	new_bullet.set_direction_and_speed(direction, bullet_speed + speed)
	get_parent().add_child(new_bullet)

func _on_FireTimer_timeout():
	shoot(position_from_player.normalized())


func _on_SeperationTimer_timeout():
	for i in $Enemy.get_overlapping_areas():
		if(i.is_in_group("Enemy")):
			seperate = true
