extends Node2D
export (float) var planet_min
export (float) var planet_max
export (float) var sun_min
export (float) var sun_max

export (PackedScene) var sun_scene
export (PackedScene) var planet_scene
	
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func init(n, spread, sun_sprites, planet_sprites):
	var sun = sun_scene.instance()
	add_child(sun)
	sun.init(rand_range(sun_min, sun_max), sun_sprites[randi()%len(sun_sprites)], int(rand_range(1.0, 2.0)* 8))
	sun.position = Vector2(0,0)
	for x in range(0, n + 1):
		var planet = planet_scene.instance()
		add_child(planet)
		
		var planet_scale = rand_range(planet_min, planet_max)
		var sprite = planet_sprites[randi()%len(planet_sprites)]
		
		var amount_of_enemies =  int(rand_range(1.0, 1.2)* n)
		
		planet.init(planet_scale, sprite, amount_of_enemies)
		planet.position = Vector2(rand_range(-1 * spread, spread), rand_range(-1 * spread, spread))
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
