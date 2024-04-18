extends CharacterBody2D

@onready var cowboy = get_node("/root/Game/Cowboy")
@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 200;

func _physics_process(delta):
	var direction = global_position.direction_to(cowboy.global_position)
	velocity = direction * SPEED
	move_and_slide()
	
	if velocity.x > 0.0:
		animated_sprite.flip_h = false
	elif velocity.x < 0.0:
		animated_sprite.flip_h = true
		
	animated_sprite.play("move")

func take_damage():
	animated_sprite.play("explode")
	set_physics_process(false)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "explode":
		queue_free()
