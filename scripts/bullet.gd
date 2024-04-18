extends Area2D

signal enemy_hit(hits_in_a_row)

const SPEED = 1000
const MAX_TRAVELLED_DISTANCE = 5000
const MAX_HITS = 3

var direction = Vector2()
var travelled_distance = 0
var hits = 0


func _physics_process(delta):
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta
	if travelled_distance > MAX_TRAVELLED_DISTANCE:
		queue_free()


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
		hits += 1
		enemy_hit.emit(hits)
	else:
		hits = MAX_HITS
	
	if hits >= MAX_HITS:
		queue_free()
