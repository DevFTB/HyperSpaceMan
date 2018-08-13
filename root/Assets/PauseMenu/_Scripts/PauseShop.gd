extends MarginContainer

signal pause
signal unpause

export var max_level = 7
export (NodePath) var player
export (Array, NodePath) var upgrade_paths
export (NodePath) var mineral_label

var costs = [30, 50, 100, 200, 500, 2000, 5000, "Max"]
var upgrade_names = ["MaxSpeed", "Acceleration", "Damage", "FuelTank", "Health", "MineSpeed"]
var upgrades
var enabled = false
var button_down = false
var minerals
var levels

onready var instruction_scene = preload("res://Assets/Instructions/Instructions.tscn")
onready var home_scene = preload("res://Assets/MainMenu/MainMenu.tscn")


func _ready():
	init_labels()
	
func init_labels():
	player = get_node(player)
	mineral_label = get_node(mineral_label)
	upgrades = {}
	for i in upgrade_names.size():
		upgrades[upgrade_names[i]] = get_node(upgrade_paths[i])
	get_player_vars()
	reset_all()
	
func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_ESCAPE and not ev.echo:
		button_down = !button_down
		if button_down:
			if get_tree().paused:
				unpause()
			else:
				pause()
	
func unpause():
	emit_signal('unpause')	
	fade_out()
	get_tree().paused = false

func pause():
	minerals = player.get_minerals()
	update_minerals(minerals)
	emit_signal('pause')
	fade_in()
	get_tree().paused = true

func fade_in():
	fade(self, "modulate", 0.0, 1.0)
	fade($ColorRect, "color", 0.0, 0.15)
	$Tween.start()
	

func fade_out():
	fade(self, "modulate", 1.0, 0.0)
	fade($ColorRect, "color", 0.15, 0.0)
	$Tween.start()

func fade(object, property, start_a, end_a):
	var start_color = Color(1.0, 1.0, 1.0, start_a)
	var end_color = Color(1.0, 1.0, 1.0, end_a)
	$Tween.interpolate_property(object, property, start_color, end_color, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)

	
func update_level(upgrade, level):
	upgrades[upgrade].update_level(level, max_level)
	
func update_cost(upgrade, cost):
	upgrades[upgrade].update_cost(cost)

func update_level_and_cost(upgrade, level, cost):
	update_level(upgrade, level)
	update_cost(upgrade, cost)
	
func reset_all():
	for i in upgrade_names:
		update_level_and_cost(i, 0, costs[0])

func update_level_up(upgrade):
	update_level_and_cost(upgrade, levels[upgrade], costs[levels[upgrade]])

func get_player_vars():
	minerals = player.get_minerals()
	levels = player.get_levels()

func update_minerals(value):
	mineral_label.text = "Minerals: " + str(value)
	
func upgrade(upgrade):
	if get_tree().paused:
		var current = levels[upgrade]
		if current < max_level:
			var cost = costs[current]
			if minerals >= cost:
				player.buy_upgrade(upgrade, cost)
				get_player_vars()
				update_minerals(minerals)
				update_level_up(upgrade)

func _on_MaxSpeed_upgrade_pressed():
	upgrade("MaxSpeed")

func _on_Acceleration_upgrade_pressed():
	upgrade("Acceleration")

func _on_Damage_upgrade_pressed():
	upgrade("Damage")

func _on_FuelTank_upgrade_pressed():
	upgrade("FuelTank")	

func _on_Health_upgrade_pressed():
	upgrade("Health")
	
func _on_MineSpeed_upgrade_pressed():
	upgrade("MineSpeed")

func _on_InstructionsButton_down():
	if get_tree().paused:
		get_tree().paused = false	
		get_tree().change_scene_to(instruction_scene)

func _on_ExitButton_down():
	if get_tree().paused:
		get_tree().paused = false		
		get_tree().quit()

func _on_HomeButton_down():
	if get_tree().paused:
		get_tree().paused = false
		get_tree().change_scene_to(home_scene)

