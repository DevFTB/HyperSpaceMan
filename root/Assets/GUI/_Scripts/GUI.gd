extends VBoxContainer

export (Array, NodePath) var label_paths
var label_names = ['Location', 'PlanetMinerals', 'Tooltip', 'Health', 'Minerals', 'Fuel', 'Speed']
var labels

func _ready():
	fade_in()
	
func fade_out():
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	$Tween.interpolate_property(self, "modulate", start_color, end_color, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func fade_in():
	var start_color = Color(1.0, 1.0, 1.0, 0.0)
	var end_color = Color(1.0, 1.0, 1.0, 1.0)
	$Tween.interpolate_property(self, "modulate", start_color, end_color, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func init_labels():
	labels = {}
	for i in label_names.size():
		labels[label_names[i]] = get_node(label_paths[i])

func update_value(label, values):
	labels[label].update_value(values)

func reset_all(values):
	for i in label_names.size():
		update_value(label_names[i], values[i])


func _on_pause():
	fade_out()


func _on_unpause():
	fade_in()
