extends Node2D
export (float) var planet_min
export (float) var planet_max
export (float) var sun_min
export (float) var sun_max
export (int) var sun_enemies_mean
export (float) var sun_enemies_randomness
export (int) var planet_enemies_mean
export (float) var planet_enemies_randomness
export (float) var planet_randomness

export (PackedScene) var sun_scene
export (PackedScene) var planet_scene
export (PackedScene) var fuel_station_scene

	
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func init(n, spread, sun_sprites, planet_sprites, sun_name, planet_names):
	#comment grid code out if sprites format changes or this spefic code no longer applies to format
	var planet_width = load(planet_sprites[0][0]).get_width() * planet_max
	var planet_grid ={}
	#*1.5 for clear radius around sun
	var sun_width = (load(sun_sprites[0][0]).get_width() * sun_max) * 2
	var sun_to_planet = sun_width/(planet_width + (planet_width * (planet_randomness/2)))
	for i in range(-ceil(sun_to_planet/2), ceil(sun_to_planet/2)):
		for j in range(-ceil(sun_to_planet/2), ceil(sun_to_planet/2)):
			planet_grid[Vector2(i, j)] = true
	
	#
	var sun = sun_scene.instance()
	add_child(sun)
	sun.init(rand_range(sun_min, sun_max), sun_sprites[randi()%len(sun_sprites)], sun_enemies_mean + int(rand_range(-1 * sun_enemies_randomness, sun_enemies_randomness) * sun_enemies_mean), sun_name)
	sun.position = Vector2(0,0)
	var spawn_pos = Vector2(rand_range(-1 * spread, spread), rand_range(-1 * spread, spread))
	var spawn_grid_pos = (spawn_pos/((planet_width) + (planet_width * planet_randomness))).floor()
	if not planet_grid.has(spawn_grid_pos):

		planet_grid[spawn_grid_pos] = true
		#
		var fuel_station = fuel_station_scene.instance()
		add_child(fuel_station)
		fuel_station.init(sun_name)
		
		fuel_station.position = spawn_grid_pos * (planet_width + (planet_width * (planet_randomness)))
		fuel_station.position.x += rand_range(-1 * planet_width * planet_randomness, planet_width * planet_randomness)
		fuel_station.position.y += rand_range(-1 * planet_width * planet_randomness, planet_width * planet_randomness)
		
	for x in range(0, n):
		#
		spawn_pos = Vector2(rand_range(-1 * spread, spread), rand_range(-1 * spread, spread))
		spawn_grid_pos = (spawn_pos/((planet_width) + (planet_width * planet_randomness))).floor()
		if not planet_grid.has(spawn_grid_pos):

			planet_grid[spawn_grid_pos] = true
			#
			var planet = planet_scene.instance()
			add_child(planet)
			var planet_scale = rand_range(planet_min, planet_max)
			var sprite = planet_sprites[randi()%len(planet_sprites)]
			
			var amount_of_enemies =  planet_enemies_mean + int(rand_range(-1 * planet_enemies_randomness, planet_enemies_randomness) * planet_enemies_mean)
			
			planet.init(planet_scale, sprite, amount_of_enemies, sun_name)
			planet.position = spawn_grid_pos * (planet_width + (planet_width * planet_randomness))
			planet.position.x += rand_range(-1 * planet_width * planet_randomness, planet_width * planet_randomness)
			planet.position.y += rand_range(-1 * planet_width * planet_randomness, planet_width * planet_randomness)
			planet.planet_name = planet_names[randi()%len(planet_names)]
		

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
