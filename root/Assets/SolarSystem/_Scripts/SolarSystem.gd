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
export (int) var sun_minerals_mean
export (float) var sun_minerals_randomness
export (int) var planet_minerals_mean
export (float) var planet_minerals_randomness

export (PackedScene) var sun_scene
export (PackedScene) var planet_scene
export (PackedScene) var fuel_station_scene

var spread
var sun_sprites
var planet_sprites
var sun_name
var planet_names
var planet_width
var sun_width
var sun_to_planet
var sun

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
>>>>>>> master

var planet_grid = {}

func init(n, spread, sun_sprites, planet_sprites, sun_name, planet_names):
	self.spread = spread
	self.sun_sprites = sun_sprites
	self.planet_sprites = planet_sprites
	self.sun_name = sun_name
	self.planet_names = planet_names
	#comment grid code out if sprites format changes or this spefic code no longer applies to format
	planet_width = load(planet_sprites[0][0]).get_width() * planet_max
	#*1.5 for clear radius around sun
	sun_width = (load(sun_sprites[0][0]).get_width() * sun_max) * 2
	sun_to_planet = sun_width/(planet_width + (planet_width * (planet_randomness/2)))
	for i in range(-ceil(sun_to_planet/2), ceil(sun_to_planet/2)):
		for j in range(-ceil(sun_to_planet/2), ceil(sun_to_planet/2)):
			planet_grid[Vector2(i, j)] = true
	
		
	for x in range(0, n):
		spawn_planet()
		
func spawn_fuel_station():
	var spawn_pos = Vector2(rand_range(-1 * spread, spread), rand_range(-1 * spread, spread))
	var spawn_grid_pos = (spawn_pos/((planet_width) + (planet_width * planet_randomness))).floor()
	if not planet_grid.has(spawn_grid_pos):
		
		planet_grid[spawn_grid_pos] = true
		
		var fuel_station = fuel_station_scene.instance()
		add_child(fuel_station)
		fuel_station.init(sun_name)

		fuel_station.position = spawn_grid_pos * (planet_width + (planet_width * (planet_randomness)))
		fuel_station.position += Vector2(get_random(planet_width, planet_randomness), get_random(planet_width, planet_randomness))
			
func spawn_planet():
	var spawn_pos = Vector2(rand_range(-1 * spread, spread), rand_range(-1 * spread, spread))
	var spawn_grid_pos = (spawn_pos/((planet_width) + (planet_width * planet_randomness))).floor()
	if not planet_grid.has(spawn_grid_pos):
		
		planet_grid[spawn_grid_pos] = true
		
		var planet = planet_scene.instance()
		add_child(planet)
		var planet_scale = rand_range(planet_min, planet_max)
		var sprite = planet_sprites[randi()%len(planet_sprites)]
		
		var amount_of_enemies = int(get_random_from_mean(planet_enemies_mean, planet_enemies_randomness))
		var amount_of_minerals = int(get_random_from_mean(planet_minerals_mean, planet_minerals_randomness))
		
		planet.init(planet_scale, sprite, amount_of_enemies, sun_name, amount_of_minerals)
		planet.position = spawn_grid_pos * (planet_width + (planet_width * planet_randomness))
		planet.position += Vector2(get_random(planet_width, planet_randomness), get_random(planet_width, planet_randomness))
		planet.planet_name = planet_names[randi()%len(planet_names)]

func spawn_sun():
	sun = sun_scene.instance()
	add_child(sun)
	var sun_scale = rand_range(sun_min, sun_max)
	var sprite = sun_sprites[randi()%len(sun_sprites)]
	var amount_of_enemies = int(get_random_from_mean(sun_enemies_mean, sun_enemies_randomness))
	var amount_of_minerals = int(get_random_from_mean(sun_minerals_mean, sun_minerals_randomness))
	sun.init(sun_scale, sprite, amount_of_enemies, sun_name, amount_of_enemies)
	sun.position = Vector2(0,0)
			
func get_random(mean, randomness):
	return rand_range(-randomness, randomness) * mean

func get_random_from_mean(mean, randomness):
	return get_random(mean, randomness) + mean

