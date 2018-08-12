extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export (int) var speed


export (int) var damage
export (int) var max_health

export (float) var bullet_speed
export (float) var fire_rate

export (float) var seperation_speed

var bullet = preload("res://Assets/Enemy/_Scenes/Bullet.tscn") # Will load when parsing the script.

var health
var position_from_player

var follow_velocity
var seperation_velocity



var player



func _ready():
	seperation_velocity = Vector2(0, 0)
	follow_velocity = Vector2(0, 0)
	health = max_health
	player = get_node("/root/Main/Player")
	$"Life Bar".value = max_health
	seperate()

func _process(delta):
	move(delta)
	$"Life Bar".set_rotation(-get_transform().get_rotation())
	

func move(delta):
	position_from_player =  player.global_position - global_position
	
	follow_velocity += position_from_player.normalized() * (-position_from_player / 30) * speed 
	
	look_at(player.global_position)
	
	position += (follow_velocity + seperation_velocity) * delta

func seperate():
	seperation_velocity += Vector2(rand_range(-1, 1), rand_range(-1, 1))  * seperation_speed

func reduce_health(decrement):
	health -= decrement
	$"Life Bar".value = health
	if health <= 0:
		dead()
		

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
			seperate()
			
func dead():
	$Enemy/AnimatedSprite.play("Die")


func _on_AnimatedSprite_animation_finished():
	if($Enemy/AnimatedSprite.animation == "Die"):
		queue_free()
