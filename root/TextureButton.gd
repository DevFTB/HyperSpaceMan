extends TextureButton

export (String) var text

func _ready():
	$Label.text = text
	$Label.rect_size = rect_size

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
