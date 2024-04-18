extends Marker2D

@onready var animated_sprite : AnimatedSprite2D = get_node("../AnimatedSprite2D")

func _process(delta):
	if animated_sprite.animation == "aim_up":
		position = Vector2(37, -33)
	elif animated_sprite.animation == "aim_down":
		position = Vector2(37, 6)
	else:
		position = Vector2(37, -14)
		
	if animated_sprite.flip_h == true:
		position.x *= -1
