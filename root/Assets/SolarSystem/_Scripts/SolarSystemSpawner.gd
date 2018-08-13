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
var sun_names = ["A", "B"]
var planet_names = ["1", "2"]

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	randomize()
	start_pos = get_node("/root/Main/Player").position
	game_time = get_node("/root/Main").game_time
	planet_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Planets", 2)
	sun_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Suns", 2)
	explored_grid[[0,0]] = true
#	var sun_names_file = File.new()
#	sun_names_file.open(sun_names_path, File.READ)
#	for line in sun_names_file.get_as_text().split("\n"):
#		sun_names.append(line)
#	var planet_names_file = File.new()
#	planet_names_file.open(planet_names_path, File.READ)
#	for line in planet_names_file.get_as_text().split("\n"):
#		planet_names.append(line)
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
	print(sun_sprite_array)
	solar_system.init(n, spread, sun_sprite_array,planet_sprite_array, sun_names[randi()%len(sun_names)], planet_names)
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
	spawn(1, Vector2(1, 0), Vector2(0, 0), 4000)
	spawn(1, Vector2(-1, 0), Vector2(0, 0),5000)
	spawn(1, Vector2(0, 1), Vector2(0, 0), 5000)
	spawn(1, Vector2(0,-1), Vector2(0, 0), 5000)
	spawn(1, Vector2(1, 0), Vector2(0, 0), 8000)
	spawn(1, Vector2(-1, 0), Vector2(0, 0),8000)
	spawn(2, Vector2(0, 1), Vector2(0, 0), 8000)
	spawn(2, Vector2(0,-1), Vector2(0, 0), 8000)
