extends Node

export (PackedScene) var solar_system_scene
export (int) var grid_size
export (int) var min_distance
export (int) var max_distance
export (int) var min_planets
export (int) var max_planets
export (int) var min_solar_range
export (int) var max_solar_range
#solar system randomness within grid cells
export (float) var solar_system_randomness
#export(String, FILE, "*.txt") var sun_names_path
#export(String, FILE, "*.txt") var planet_names_path
#export (Texture) var sprite6
#var planet_sprites
#var sun_sprites
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var sun_grid = {}
var explored_grid = {}
var start_pos
var game_time
var planet_sprite_array
var sun_sprite_array 
var sun_names_temp = ["Kepler", "HD", "2MASS", "KOI", "WASP", "K2", "HIP", "EPIC", "KELT", "Sol", "CoRoT", "Gliese", "OGLE", "Qatar", "HAT", "GJ", "KELT"]
var sun_names = []
	
func generate_n_digit_numbers(n, amount):
	var result = []
	for i in range(amount):
		result.append(generate_number(n))
	return result
	
func generate_number(length):
	if length == 0:
		return ""
	return generate_number(length-1) + str(int(rand_range(0, 10)))

func generate_sun_names():
	for i in sun_names_temp:
		for j in range(2, 5):
			for k in generate_n_digit_numbers(j, 7):
				sun_names.append(i + "-" + k)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	generate_sun_names()
	planet_sprite_array = []
	for i in range (1, 3):
		for j in range(1, 6):
			if not (i == 2 and j == 5):
				var building_array = []
				if i == 1:
					for k in range(0, 7):
						building_array.append("res://Assets/SolarSystem/_Graphics/Planets/t" + str(i) + "p" + str(j) + "/t" + str(i) + "0" + str(k) + ".png")
				else:
					for k in range(0, 6):
						building_array.append("res://Assets/SolarSystem/_Graphics/Planets/t" + str(i) + "p" + str(j) + "/t" + str(i) + "0" + str(k) + ".png")
				planet_sprite_array.append(building_array)
	print(planet_sprite_array)
	sun_sprite_array = [["res://Assets/SolarSystem/_Graphics/Suns/s1/sun00.png", "res://Assets/SolarSystem/_Graphics/Suns/s1/sun01.png", "res://Assets/SolarSystem/_Graphics/Suns/s1/sun02.png", "res://Assets/SolarSystem/_Graphics/Suns/s1/sun03.png", "res://Assets/SolarSystem/_Graphics/Suns/s1/sun04.png", "res://Assets/SolarSystem/_Graphics/Suns/s1/sun05.png"]]

	start_pos = get_node("/root/Main/Player").position
	game_time = get_node("/root/Main").game_time
	#planet_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Planets", 2)
	#sun_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Suns", 2)
	explored_grid[[0,0]] = true
	
	var solar_system = solar_system_scene.instance()
	add_child(solar_system)
	#solar_system.get_node("Sun").spawned_enemies = true
	solar_system.planet_enemies_mean = 1
	solar_system.planet_enemies_randomness = 0
	solar_system.init(10, 1500,sun_sprite_array, planet_sprite_array, "Tutorial")
	solar_system.sun.spawned_enemies = true
	solar_system.position = Vector2(600, 600)
	start_spawn()

func _process(delta):
	var full_position = get_node("/root/Main/Player").position
	var pos = [int(full_position.x/grid_size), int(full_position.y/grid_size)]
	if not explored_grid.has(pos):
		var time_left = get_node("/root/Main").time_left
		explored_grid[pos] = true
		spawn(2, full_position, start_pos, ((time_left * min_distance) + max_distance * (game_time - time_left))/game_time)
		
func build_animations(path, i):
	var animations = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		if i == 1:
			while (file_name != ""):
				if file_name.right(len(file_name) - 4) == ".png":
					animations.append(path + "/" + file_name)
				file_name = dir.get_next()
		else:
			while (file_name != ""):
				if not file_name.ends_with("."):
					animations.append(build_animations(path + "/"+ file_name, i - 1))
				file_name = dir.get_next()
		return animations
		
func create_solar_system(x, y, n, spread):
	var solar_system = solar_system_scene.instance()
	add_child(solar_system)
	solar_system.init(n, spread, sun_sprite_array,planet_sprite_array, sun_names[randi()%len(sun_names)])
	solar_system.position.x = x
	solar_system.position.y = y
	
	
#spawns solar sytem dist from pos in semicircle away from origin
func spawn(n, pos, origin, dist):
	for i in range (0, n):
		var rand_rotate
		rand_rotate = rand_range(-0.5 * PI, 0.5 * PI)
		var goal_pos = (pos + ((pos - origin).normalized() * dist).rotated(rand_rotate))
		var goal_x_grid = int(goal_pos.x/(grid_size * 2))
		var goal_y_grid = int(goal_pos.y/(grid_size * 2))
		if not sun_grid.has([goal_x_grid, goal_y_grid]):
			create_solar_system(goal_x_grid * (grid_size * 2) + rand_range(-1 * solar_system_randomness * grid_size, solar_system_randomness * grid_size), goal_y_grid * (grid_size * 2) + rand_range(-1 * solar_system_randomness * grid_size, solar_system_randomness * grid_size), int(rand_range(min_planets, max_planets + 1)), int(rand_range(min_solar_range, max_solar_range)))
			sun_grid[[goal_x_grid, goal_y_grid]] = true
	
func start_spawn():
	spawn(3, Vector2(1, 0), Vector2(0, 0), 5500)
	spawn(3, Vector2(-1, 0), Vector2(0, 0),5500)
	spawn(3, Vector2(0, 1), Vector2(0, 0), 5500)
	spawn(3, Vector2(0,-1), Vector2(0, 0), 5500)
