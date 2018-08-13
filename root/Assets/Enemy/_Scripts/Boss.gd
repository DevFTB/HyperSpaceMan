extends Enemy

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func shoot():	

	for i in range(0,4):
		var new_bullet = bullet.instance()
		new_bullet.position = position
		new_bullet.set_damage(damage)
	
		new_bullet.set_direction_and_speed(direction * (90 * i), bullet_speed + movement_speed)
		get_parent().add_child(new_bullet)

	
