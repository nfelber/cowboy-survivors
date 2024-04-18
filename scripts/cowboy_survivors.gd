extends Node2D

@onready var cowboy = $Cowboy
@onready var path_follow_2d = $Cowboy/Path2D/PathFollow2D
@onready var background = $BackgroundLayer/Background
@onready var game_over = $GameOver
@onready var score_label = $Score/ColorRect/Label

const BlobScn = preload("res://scenes/blob.tscn")
const SmallCactusScn = preload("res://scenes/cactus_small.tscn")
const BigCactusScn = preload("res://scenes/cactus_big.tscn")

const CHUNK_SIZE = 1500
const MIN_CACTI_PER_CHUNK = 20
const MAX_CACTI_PER_CHUNK = 40

var chunk_rng = RandomNumberGenerator.new()
var score = 0


func _ready():
	regenerate_nearby_chunks()


func _process(delta):
	background.region_rect.position = cowboy.position / background.transform.get_scale()


func spawn_blob():
	var new_blob = BlobScn.instantiate()
	path_follow_2d.progress_ratio = randf()
	new_blob.global_position = path_follow_2d.global_position
	add_child(new_blob)


func generate_chunk(chunk_coordinates):
	chunk_rng.seed = str(chunk_coordinates).hash()
	var nb_cacti = chunk_rng.randi_range(MIN_CACTI_PER_CHUNK, MAX_CACTI_PER_CHUNK)
	for i in nb_cacti:
		var new_cactus
		var is_big_cactus = chunk_rng.randi() % 2 == 0
		if is_big_cactus:
			new_cactus = BigCactusScn.instantiate()
		else:
			new_cactus = SmallCactusScn.instantiate()
		var offset = Vector2(chunk_rng.randf(), chunk_rng.randf())
		new_cactus.global_position = (chunk_coordinates + offset) * CHUNK_SIZE
		new_cactus.add_to_group("cacti")
		add_child(new_cactus)


func regenerate_nearby_chunks():
	for cactus in get_tree().get_nodes_in_group("cacti"):
		cactus.queue_free()
	
	var current_chunk = floor(cowboy.global_position / CHUNK_SIZE)
	for x in range(-1, 2):
		for y in range(-1, 2):
			generate_chunk(current_chunk + Vector2(x, y))


func _on_timer_timeout():
	spawn_blob()


func _on_map_generate_timer_timeout():
	regenerate_nearby_chunks()


func _on_cowboy_health_depleted():
	game_over.visible = true
	get_tree().paused = true


func _on_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_cowboy_enemy_hit(hits_in_a_row):
	score += 2**hits_in_a_row * 50
	score_label.text = "Score: %s" % score
