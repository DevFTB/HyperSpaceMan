extends Label

var text_template

func _ready():
	text_template = text

func update_value(values):
	text = text_template % values

					