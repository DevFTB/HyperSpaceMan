extends Area2D

export (NodePath) var GUI

export (int) var minerals
export (float) var fuel
export (int) var fuel_capacity
export (int) var mining_time
export (int) var bullet_speed
export (int) var damage
export (int) var engine_acceleration
export (int) var max_speed
export (int) var max_health
export (int) var friction
export (int) var fuel_value
export (int) var collision_damage = 10

export (PackedScene) var Bullet
var tooltip = ""
var location = [ 'Earth', 'Sol' ]
var acceleration
var velocity
var collision
var health
var can_shoot
var can_mine
var can_buy_fuel
var isPressed = false


export (AudioStream) var shoot_sound
export (AudioStream) var move_sound

func _ready():
	velocity = Vector2(0,0)
	fuel = fuel_capacity
	health = max_health
	can_shoot = true
	GUI = get_node(GUI)
	GUI.init_labels()
	GUI.reset_all([location, "None", tooltip, [health, max_health], minerals, [fuel, fuel_capacity], velocity.length()])

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_F and not ev.echo:
		isPressed = !isPressed
		if can_buy_fuel and isPressed:
			if minerals >= can_buy_fuel.get_price():
				buy_fuel()
			else:
				GUI.update_value('Tooltip', 'Not enough minerals')
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and not collision:
		accelerate()
		$Particles2D.emitting = true
		$Particles2D.speed_scale = engine_acceleration/15
	else:
		velocity -= velocity.normalized() * friction
		$Particles2D.emitting = false
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_shoot:
		shoot()

func _process(delta):
	move(delta)
	
		
func buy_fuel():
	reduce_minerals(can_buy_fuel.get_price())
	change_fuel(fuel_value)

func change_fuel_capacity(amount):
	fuel_capacity += amount
	GUI.update_value('Fuel', [int(fuel), fuel_capacity])

func change_fuel(amount):
	fuel = clamp(fuel + amount, 0, fuel_capacity)
	GUI.update_value('Fuel', [int(fuel), fuel_capacity])
	
func reduce_minerals(amount):
	minerals -= amount
	GUI.update_value('Minerals', minerals)


func accelerate():
	acceleration = (get_global_mouse_position() - position).normalized() * engine_acceleration
	velocity += acceleration
	if velocity.length() >= max_speed:
		velocity = velocity.normalized() * max_speed
	fuel -= 0.05
	GUI.update_value('Speed', int(velocity.length() * 100))
	GUI.update_value('Fuel', [int(fuel), fuel_capacity])
	if not $MoveSoundPlayer.playing:
    	$MoveSoundPlayer.play()

func die():
	hide()
	print("you dead")
	$CollisionShape2D.disabled = true
	can_shoot = false
	$ShootTimer.stop()

func move(delta):
  
	position += velocity * delta
	look_at(get_global_mouse_position())

func shoot():
	can_shoot = false
	$ShootTimer.start()
	var bullet = Bullet.instance()
	bullet.set_damage(damage)
	bullet.position = position
	get_parent().add_child(bullet)
	
	print(bullet_speed)
	
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
	if velocity.length() <= engine_acceleration:
		velocity = -velocity.normalized() * engine_acceleration
	collision = true
	reduce_health(collision_damage)
	
func reduce_health(damage):
	health -= damage
	if health <= 0:
		die()
	GUI.update_value('Health', [health, max_health])

func _on_Player_area_exited(area):
	if area.is_in_group("Collider"):
		collision = false
	if area.is_in_group("Fuel Station"):
		fuel_area_exited(area)