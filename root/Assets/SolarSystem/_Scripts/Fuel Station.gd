extends Area2D

export (int) var fuel_amount
export (int) var fuel_price
export (float) var randomness
export (String) var tooltip
export (String) var no_fuel_tooltip

var sun_name

func _ready():
	fuel_price = fuel_price + int(rand_range(fuel_price * randomness, -fuel_price * randomness))
	fuel_amount = fuel_amount + int(rand_range(fuel_amount * randomness, -fuel_amount * randomness))

func init(solar_name):
	sun_name = solar_name
	
func get_tooltip():
	if fuel_amount > 0:
		return tooltip % fuel_price
	else:
		return no_fuel_tooltip
	
func get_price():
	return fuel_price

func buy_fuel():
	if fuel_amount > 0:
		fuel_amount -= 1
		return true
	return false
