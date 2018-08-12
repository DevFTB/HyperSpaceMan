extends Node

export (PackedScene) var solar_system_scene
export (int) var grid_size
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

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	start_pos = get_node("/root/Main/Player").position
	game_time = get_node("/root/Main").game_time
	planet_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Planets", 2)
	sun_sprite_array = build_animations("res://Assets/SolarSystem/_Graphics/Suns", 2)

func _process(delta):
	var time_left = get_node("/root/Main").time_left
	var full_position = get_node("/root/Main/Player").position
	var pos = [int(full_position.x/grid_size), int(full_position.y/grid_size)]
	if not explored_grid.has(pos):
		explored_grid[pos] = true
		spawn(1, full_position, start_pos, 3500, sun_sprite_array, planet_sprite_array, sun_grid, grid_size)

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
		
func create_solar_system(x, y, n, spread, sun_sprites, planet_sprites):
	var solar_system = solar_system_scene.instance()
	add_child(solar_system)
	solar_system.init(n, spread, sun_sprites,planet_sprites)
	solar_system.position.x = x
	solar_system.position.y = y
	
	
#spawns solar sytem dist from pos in semiscircle (not yet implemented) away from origin
func spawn(n, pos, origin, dist, sun_sprites, planet_sprites, sun_pos_dict, grid_size):
	for i in range (0, n):
		var goal_pos = pos + ((pos - origin).normalized() * dist)
		var goal_x_grid = int(goal_pos.x/grid_size)
		var goal_y_grid = int(goal_pos.y/grid_size)
		if not sun_pos_dict.has([goal_pos.x, goal_pos.y]):
			create_solar_system(goal_x_grid * grid_size, goal_y_grid * grid_size, int(rand_range(4, 6)), int(rand_range(1000, 2500)), sun_sprites, planet_sprites)
			sun_pos_dict[[goal_pos.x, goal_pos.y]] = true


