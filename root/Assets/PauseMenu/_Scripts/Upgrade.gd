extends MarginContainer

signal upgrade_pressed

export (NodePath) var level_label
export (NodePath) var cost_label
export (NodePath) var title_label
export (String) var upgrade_name
export (NodePath) var export_bar

func _ready():
	export_bar = get_node(export_bar)
	level_label = get_node(level_label)
	cost_label = get_node(cost_label)
	title_label = get_node(title_label)	
	title_label.text = upgrade_name

func update_level(level, max_level):
	level_label.text = "LVL " +  str(level) + "/" + str(max_level)
	export_bar.set_value(level)
	
func update_cost(cost):
	cost_label.text = str(cost)
	

func _on_UpgradeButton_button_down():
	emit_signal("upgrade_pressed")