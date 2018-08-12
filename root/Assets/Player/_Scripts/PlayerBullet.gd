extends Area2D

var damage
var velocity
	
func set_damage(damage):
	self.damage = damage
	
func set_velocity(velocity):
	self.velocity = velocity

func _process(delta):
	position += velocity * delta

func _on_PlayerBullet_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().reduce_health(damage)
		queue_free()

func _on_BulletTimer_timeout():
	queue_free()
