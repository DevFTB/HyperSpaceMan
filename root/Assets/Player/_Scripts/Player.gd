extends Area2D

export (NodePath) var GUI
export var initial = {"MaxSpeed": 500, "Acceleration": 100, "Damage": 15, "FuelTank": 100, "Health": 100, "MiningSpeed": 10}
export var level_multiplier = {"MaxSpeed": 150, "Acceleration": 25, "Damage": 25, "FuelTank": 50, "Health": 100, "MiningSpeed": 5}
export (int) var minerals
export (int) var friction
export (int) var bullet_speed
export (int) var fuel_value
export var collision_damage = 10
export var fuel_cost = 0.05
export (PackedScene) var Bullet

var tooltip = ""
var location = [ 'Earth', 'Sol' ]
var acceleration
var velocity = Vector2(0,0)
var collision
var health
var can_shoot = true
var can_mine
var can_buy_fuel
var fuel
var stats
var levels = {"MaxSpeed": 0, "Acceleration": 0, "Damage": 0, "FuelTank": 0, "Health": 0, "MiningSpeed": 0}
var isPressed = false

export (AudioStream) var shoot_sound
export (AudioStream) var move_sound

func _ready():
	stats = initial
	print(stats)
	fuel = stats["FuelTank"]
	health = stats["Health"]
	GUI = get_node(GUI)
	GUI.init_labels()
	GUI.reset_all([location, "None", tooltip, [health, stats["Health"]], minerals, [fuel, stats["FuelTank"]], velocity.length()])

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_F and not ev.echo:
		isPressed = !isPressed
		if can_buy_fuel and isPressed:
			if minerals >= can_buy_fuel.get_price():
				buy_fuel()
			else:
				GUI.update_value('Tooltip', 'Not enough minerals')

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and not collision:
		accelerate(delta)
		$Particles2D.emitting = true
		$Particles2D.speed_scale = stats["Acceleration"]/15
	else:
		velocity -= velocity.normalized() * friction
		$Particles2D.emitting = false
		
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot:
		shoot()
	move(delta)
		
func buy_fuel():
	reduce_minerals(can_buy_fuel.get_price())
	change_fuel(fuel_value)
	
func change_fuel(amount):
	fuel = clamp(fuel + amount, 0, stats["FuelTank"])
	GUI.update_value('Fuel', [int(fuel), stats["FuelTank"]])
	
func get_minerals():
	return minerals
	
func reduce_minerals(amount):
	minerals -= amount
	GUI.update_value('Minerals', minerals)

func accelerate(delta):
	acceleration = (get_global_mouse_position() - position).normalized() * stats["Acceleration"]
	velocity += acceleration
	if velocity.length() >= stats["Health"]:
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
	GUI.update_value('Speed', int(velocity.length() * 100))
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
	if area.is_in_group("Collider"):
		collide()
	if area.is_in_group("Fuel Station"):
		fuel_area_entered(area)
	
func fuel_area_entered(area):
	GUI.update_value('Tooltip', area.get_tooltip())
	can_buy_fuel = area

func fuel_area_exited(area):
	GUI.update_value('Tooltip', "")
	can_buy_fuel = false

func collide():
	velocity = -velocity
	if velocity.length() <= stats["Acceleration"]:
		collision = true
		reduce_health(collision_damage)
	
func reduce_health(damage):
	health -= damage
	if health <= 0:
		die()
	GUI.update_value('Health', [health, stats["Health"]])

func _on_Player_area_exited(area):
	if area.is_in_group("Collider"):
		collision = false
	if area.is_in_group("Fuel Station"):
		fuel_area_exited(area) 

func get_levels():
	return levels

func buy_upgrade(upgrade, cost):
	reduce_minerals(cost)
	levels[upgrade] += 1
	stats[upgrade] = initial[upgrade] + levels[upgrade] * level_multiplier[upgrade]