extends Area2D

export (NodePath) var GUI
var initial = {"MaxSpeed": 145, "Acceleration": 100, "Damage": 15, "FuelTank": 100, "Health": 150, "MineSpeed": 5}
var level_multiplier = {"MaxSpeed": 14, "Acceleration": 35, "Damage": 4, "FuelTank": 20, "Health": 30, "MineSpeed": 1.5}
export (int) var minerals
export (int) var friction
export (int) var bullet_speed
export (float) var regen_per_second = 1
export var fuel_cost = 0.05
export (PackedScene) var Bullet
export var speed_multiplier = 100
var mine_strength = ["dig", "mine", "excavate", "extract", "harvest", "vaporize", "annihilate", "terminate", "unleash infinity guantlet on"]

var tooltip = ""
var space_location = "Uncharted"
var acceleration
var velocity = Vector2(0,0)
var health
var can_shoot = true
var mine
var mining
var mine_timer = 0
var fuel_station
var fuel
var stats
var levels = {"MaxSpeed": 0, "Acceleration": 0, "Damage": 0, "FuelTank": 0, "Health": 0, "MineSpeed": 0}
var f_pressed = false
var space_pressed = false
var enemies_killed = 0
var fuel_value = 0.25
var sun_position = false
var total_minerals = 0

signal end_game

func _ready():
	stats = initial
	fuel = stats["FuelTank"]
	health = stats["Health"]
	GUI = get_node(GUI)
	GUI.init_labels()
	var main = get_parent()
	GUI.reset_all([space_location, "None", tooltip, [health, stats["Health"]], minerals, [fuel, stats["FuelTank"]], velocity.length(), main.game_time])

func _input(ev):
	if ev is InputEventKey and not ev.echo:
		if ev.scancode == KEY_F:
			f_pressed = !f_pressed
			if fuel_station and f_pressed:
				if minerals >= fuel_station.get_price() and fuel < stats["FuelTank"]:
					buy_fuel()
				else:
					GUI.update_value('Tooltip', 'Not enough minerals')
		if ev.scancode == KEY_SPACE:
			space_pressed = !space_pressed
			if mining and !space_pressed:
				stop_mining(false)
			else:
				if mine and mine.get_mine_time(stats["MineSpeed"]) and space_pressed:
					start_mining()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		accelerate(delta)
		$Particles2D.emitting = true
		$Particles2D.speed_scale = stats["Acceleration"]/15
	else:
		velocity -= velocity.normalized() * friction * delta
		$Particles2D.emitting = false
		
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot:
		shoot()
	
	if mining:
		mine_step(delta)
		
	if velocity.length() * speed_multiplier >= 200000 && $Sprite.animation != "Lightspeed":
		print("ran ls ")
		$Sprite.play("Lightspeed")
	elif velocity.length() * speed_multiplier < 200000 && $Sprite.animation != "Move":
		print("ran move")
		$Sprite.play("Move")
		
	move(delta)
	
	if sun_position and (global_position - sun_position).length() > 1750:
		sun_position = false
		update_location(space_location)
	change_health(regen_per_second * delta)
		
func mine_step(delta):
	velocity -= velocity.normalized() * friction
	mine_timer += delta
	var mine_time = mine.get_mine_time(stats["MineSpeed"])
	if mine_timer >= mine_time:
		stop_mining(true)
	else:
		var progress_text = ""
		for i in range(0, int(10 * mine_timer/mine_time)):
			progress_text += " ."
		GUI.update_value("Tooltip", "Mining" + progress_text)	
	
func buy_fuel():
	if fuel_station.buy_fuel():
		change_minerals(-fuel_station.get_price())
		change_fuel(int(fuel_value * stats["FuelTank"]))
		GUI.update_value('Tooltip', fuel_station.get_tooltip())
	
func change_fuel(amount):
	fuel = clamp(fuel + amount, 0, stats["FuelTank"])
	if fuel <= 0:
		out_of_fuel()
	GUI.update_value('Fuel', [int(fuel), stats["FuelTank"]])
	
func get_minerals():
	return minerals
	
func change_minerals(amount):
	total_minerals += max(0, amount)
	minerals += amount
	GUI.update_value('Minerals', minerals)

func accelerate(delta):
	acceleration = (get_global_mouse_position() - position).normalized() * stats["Acceleration"] * delta
	velocity += acceleration
	if velocity.length() >= stats["MaxSpeed"]:
		velocity = velocity.normalized() * stats["MaxSpeed"]
	change_fuel(-fuel_cost)
	if not $MoveSoundPlayer.playing:
    	$MoveSoundPlayer.play()

func die():
	$DeathSoundPlayer.play()
	emit_signal("end_game", "You Died!")
	
func out_of_fuel():
	emit_signal("end_game", "Out of Fuel!")
	
func win_game():
	emit_signal("end_game", "You have run out of space!")

func move(delta):
	var speed = int(velocity.length()) * speed_multiplier
	GUI.update_value('Speed', speed)
	if speed >= 300000:
		win_game()
	position += velocity * delta
	look_at(get_global_mouse_position())

func shoot():
	can_shoot = false
	$ShootTimer.start()

	var bullet = Bullet.instance()
	bullet.set_damage(stats["Damage"])
	bullet.position = position
	
	get_parent().add_child(bullet)

	var bullet_velocity =  velocity + (get_global_mouse_position() - bullet.global_position).normalized() * bullet_speed
	bullet.set_velocity(bullet_velocity)

	$ShootSoundPlayer.play(0)

func _on_ShootTimer_timeout():
	can_shoot = true
	$ShootTimer.stop()

func _on_Player_area_entered(area):
	if area.is_in_group("Fuel Station"):
		fuel_area_entered(area)
	if area.is_in_group("Mineable"):
		mine_area_entered(area)

func _on_Player_area_exited(area):
	if area.is_in_group("Fuel Station"):
		fuel_area_exited(area) 
	if area.is_in_group("Mineable"):
		mine_area_exited(area)

func get_mine_strength():
	return mine_strength[levels["MineSpeed"]]

func mine_area_entered(area):
	sun_position = false
	GUI.update_value('Tooltip', area.get_tooltip(get_mine_strength()))
	GUI.update_value('PlanetMinerals', area.get_minerals())
	update_location(area.get_sun_name(), area.get_planet_name())
	mine = area

func mine_area_exited(area):
	GUI.update_value('PlanetMinerals', "None")
	if mining:
		stop_mining(false)
	GUI.update_value('Tooltip', "")
	sun_position = area.get_sun_position()
	update_location(area.get_sun_name())
	
func start_mining():
	mining = true

func stop_mining(mined):
	mining = false
	if mined:
		change_minerals(mine.get_minerals())
		mine.mined(levels["MineSpeed"])
		if levels["MineSpeed"] == 8:
			$MineSoundPlayer2.play()
		else:
			$MineSoundPlayer1.play()
	mine_timer = 0
	GUI.update_value("Tooltip", mine.get_tooltip(get_mine_strength()))
		
func fuel_area_entered(area):
	GUI.update_value('Tooltip', area.get_tooltip())
	sun_position = false
	update_location("Fuel Station")

	fuel_station = area

func fuel_area_exited(area):
	update_location(space_location)
	GUI.update_value('Tooltip', "")
	fuel_station = false
	
func change_health(amount):
	health = clamp(health + amount, 0, stats["Health"])
	if health <= 0:
		die()
	GUI.update_value('Health', [int(health), stats["Health"]])

func get_levels():
	return levels

func buy_upgrade(upgrade, cost):
	change_minerals(-cost)
	levels[upgrade] += 1
	var level_mod = levels[upgrade]
	$UpgradeSoundPlayer.play()
	if upgrade == "FuelTank" or upgrade == "MineSpeed" or upgrade == "MaxSpeed":
		level_mod = pow(level_mod, 2)
	stats[upgrade] = initial[upgrade] + level_mod * level_multiplier[upgrade]
		
func _on_PauseMenu_pause():
	if mining:
		stop_mining(false)
		
func update_location(sun_name, planet_name=""):
	GUI.update_value("Location", sun_name + " " + planet_name)



func _on_PauseMenu_unpause():
	space_pressed = false
