extends Area2D

export (NodePath) var GUI
export var initial = {"MaxSpeed": 100, "Acceleration": 100, "Damage": 15, "FuelTank": 100, "Health": 1000, "MineSpeed": 5}
export var level_multiplier = {"MaxSpeed": 10, "Acceleration": 10, "Damage": 25, "FuelTank": 20, "Health": 100, "MineSpeed": 1.5}
export (int) var minerals
export (int) var friction
export (int) var bullet_speed
export (int) var fuel_value
export var fuel_cost = 0.05
export (PackedScene) var Bullet
export var speed_multiplier = 100
export var mine_strength = ["dig", "mine", "excavate", "extract", "harvest", "vaporize", "annihilate", "terminate", "unleash infinity guantlet on"]

var tooltip = ""
var location = [ 'Earth', 'Sol' ]
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

export (AudioStream) var shoot_sound
export (AudioStream) var move_sound
export (AudioStream) var mine_sound
export (AudioStream) var upgrade_sound

func _ready():
	stats = initial
	print(stats)
	fuel = stats["FuelTank"]
	health = stats["Health"]
	GUI = get_node(GUI)
	GUI.init_labels()
	GUI.reset_all([location, "None", tooltip, [health, stats["Health"]], minerals, [fuel, stats["FuelTank"]], velocity.length()])

func _input(ev):
	if ev is InputEventKey and not ev.echo:
		if ev.scancode == KEY_F:
			f_pressed = !f_pressed
			if fuel_station and f_pressed:
				if minerals >= fuel_station.get_price():
					buy_fuel()
				else:
					GUI.update_value('Tooltip', 'Not enough minerals')
		if ev.scancode == KEY_SPACE:
			space_pressed = !space_pressed
			if mining and !space_pressed:
				stop_mining(false)
			else:
				if mine and mine.get_mine_time(stats["MineSpeed"]) and space_pressed:
					print(mine.get_mine_time(stats["MineSpeed"]))
					start_mining()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		accelerate(delta)
		$Particles2D.emitting = true
		$Particles2D.speed_scale = stats["Acceleration"]/15
	else:
		velocity -= velocity.normalized() * friction
		$Particles2D.emitting = false
		
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot:
		shoot()
	
	if mining:
		mine_step(delta)
		
	move(delta)
		
func mine_step(delta):
	velocity -= velocity.normalized() * friction
	mine_timer += delta
	var mine_time = mine.get_mine_time(stats["MineSpeed"])
	var progress_text = ""
	for i in range(0, int(20 * mine_timer/mine_time)):
		progress_text += " ."
	GUI.update_value("Tooltip", "Mining" + progress_text)
	if int(mine_timer) >= mine_time:
		stop_mining(true)		

func buy_fuel():
	if fuel_station.buy_fuel():
		change_minerals(-fuel_station.get_price())
		change_fuel(fuel_value)
		GUI.update_value('Tooltip', fuel_station.get_tooltip())
	
func change_fuel(amount):
	fuel = clamp(fuel + amount, 0, stats["FuelTank"])
	GUI.update_value('Fuel', [int(fuel), stats["FuelTank"]])
	
func get_minerals():
	return minerals
	
func change_minerals(amount):
	minerals += amount
	GUI.update_value('Minerals', minerals)

func accelerate(delta):
	acceleration = (get_global_mouse_position() - position).normalized() * stats["Acceleration"]
	velocity += acceleration
	if velocity.length() >= stats["MaxSpeed"]:
		velocity = velocity.normalized() * stats["MaxSpeed"]
	change_fuel(-fuel_cost)
	if not $MoveSoundPlayer.playing:
    	$MoveSoundPlayer.play()

func die():
	hide()
	$CollisionShape2D.disabled = true
	can_shoot = false
	$ShootTimer.stop()

func move(delta):
	GUI.update_value('Speed', int(velocity.length() * speed_multiplier))
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
	GUI.update_value('Tooltip', area.get_tooltip(get_mine_strength()))
	GUI.update_value('PlanetMinerals', area.get_minerals())
	mine = area

func mine_area_exited(area):
	GUI.update_value('Tooltip', "")
	GUI.update_value('PlanetMinerals', "None")
	if mining:
		stop_mining(false)
	
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
	fuel_station = area

func fuel_area_exited(area):
	GUI.update_value('Tooltip', "")
	fuel_station = false
	
func reduce_health(damage):
	health -= damage
	if health <= 0:
		die()
	GUI.update_value('Health', [health, stats["Health"]])

func get_levels():
	return levels

func buy_upgrade(upgrade, cost):
	change_minerals(-cost)
	levels[upgrade] += 1
	var level_mod = levels[upgrade]
	$UpgradeSoundPlayer.play()
	if upgrade == "FuelTank" or upgrade == "MineSpeed":
		level_mod = pow(level_mod, 2)
	stats[upgrade] = initial[upgrade] + level_mod * level_multiplier[upgrade]
		