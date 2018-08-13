extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_EnemySpawnArea_body_entered(body):
	print("don")
	if(body.get_name == "Player"):
		_spawn_enemies()
