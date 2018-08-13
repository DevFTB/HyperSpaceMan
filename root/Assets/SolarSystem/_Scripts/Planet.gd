extends "res://Assets/SolarSystem/_Scripts/SpaceObject.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var planet_name
var sun_position

func get_planet_name():
	return planet_name

func set_sun_position(position):
	sun_position = position
	
func get_sun_position():
	return sun_position
	
	