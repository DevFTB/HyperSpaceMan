extends Area2D

var direction
var speed
var damage



func set_damage(damage):
	self.damage = damage

func _process(delta):
	position += direction * speed * delta

func set_direction_and_speed(direction, speed):
	self.direction = direction
	self.speed = speed

func _on_Bullet_area_entered(area):
	if area.get_name() == "Player":
		
		area.reduce_health(damage)
		queue_free()

func _on_BulletTimer_timeout():
	queue_free()


