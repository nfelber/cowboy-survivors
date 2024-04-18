extends CharacterBody2D

signal health_depleted
signal enemy_hit(hits_in_a_row)

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hurt_box = $HurtBox
@onready var health_bar = $HealthBar
@onready var dash_timer = $DashTimer
@onready var gun_tip = $GunTip

const BulletScn = preload("res://scenes/bullet.tscn")

const SPEED = 400
const DASHING_SPEED = 1000
const DAMAGE_RATE = 5.0

var is_aiming = false;
var is_dashing = false;
var dashing_direction = Vector2()
var health = 100.0


func _physics_process(delta):
	if is_aiming:
		var aiming_direction = position.direction_to(get_global_mouse_position())
		velocity = Vector2(0.0, 0.0)
		
		if aiming_direction.x > 0.0:
			animated_sprite.flip_h = false
		elif aiming_direction.x < 0.0:
			animated_sprite.flip_h = true
		
		var frame = animated_sprite.frame
		var progress = animated_sprite.frame_progress
		
		if aiming_direction.y < -0.4:
			animated_sprite.play("aim_up")
		elif aiming_direction.y > 0.4:
			animated_sprite.play("aim_down")
		else:
			animated_sprite.play("aim")
		
		animated_sprite.set_frame_and_progress(frame, progress)
	else:
		var moving_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = moving_direction * SPEED
		
		if velocity.x > 0.0:
			animated_sprite.flip_h = false
		elif velocity.x < 0.0:
			animated_sprite.flip_h = true
			
		if velocity.length_squared() > 0.0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
	
	if is_dashing:
		velocity = dashing_direction * DASHING_SPEED
	
	move_and_slide()
	
	var overlapping_blobs = hurt_box.get_overlapping_bodies()
	health -= DAMAGE_RATE * overlapping_blobs.size() * delta
	health_bar.value = health
	if health <= 0:
		health_depleted.emit()


func _unhandled_input(event):
	if event.is_action_pressed("aim"):
		is_aiming = not is_aiming
	
	if event.is_action_pressed("fire") and is_aiming:
		var new_bullet = BulletScn.instantiate()
		new_bullet.position = position + gun_tip.position
		new_bullet.direction = new_bullet.position.direction_to(get_global_mouse_position())
		new_bullet.enemy_hit.connect(_on_bullet_enemy_hit)
		get_parent().add_child(new_bullet)
		
	if event.is_action_pressed("dash") and not is_dashing:
		is_dashing = true
		dashing_direction = position.direction_to(get_global_mouse_position())
		collision_shape_2d.disabled = true
		dash_timer.start()


func _on_dash_timer_timeout():
	is_dashing = false
	collision_shape_2d.disabled = false


func _on_bullet_enemy_hit(hits_in_a_row):
	enemy_hit.emit(hits_in_a_row)
