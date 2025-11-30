extends Node2D

# Enemy definitions — each with a scene and a count
@export
var enemy_defs = [
	{ "scene": preload("uid://b17pvawgu8eef"), "count": 3 },  # Card
	{ "scene": preload("uid://bv6tetdqw3d5g"), "count": 2 },  # Crane
	{ "scene": preload("uid://c7bwmsj7rtu8t"), "count": 1 }   # Slot Machine
]


@export var min_spawn_interval: float = 0.5

@export var max_spawn_interval: float = 3.0

# [Card, Card, Card, Crane, Crane, SlotMachine]
var spawn_list: Array = []

var leftover_enemies: int = 0


func _ready():
	_prepare_spawn_list()
	leftover_enemies = spawn_list.size()

	for scene in spawn_list:
		var delay = randf_range(min_spawn_interval, max_spawn_interval)
		await get_tree().create_timer(delay).timeout
		spawn_enemy(scene)


func _prepare_spawn_list():
	spawn_list.clear()

	for def in enemy_defs:
		if not def.has("scene") or not def.has("count"):
			continue
		
		var scene: PackedScene = def["scene"]
		var count: int = def["count"]

		for i in count:
			spawn_list.append(scene)


func spawn_enemy(scene: PackedScene):
	var enemy = scene.instantiate()

	var screen_rect = get_viewport().get_visible_rect()
	var margin = 300

	var min_pos = screen_rect.position + Vector2(margin, margin)
	var max_pos = screen_rect.position + screen_rect.size - Vector2(margin, margin)

	var x = randf_range(min_pos.x, max_pos.x)
	var y = randf_range(min_pos.y, max_pos.y)
	enemy.position = Vector2(x, y)

	add_child(enemy)
	enemy.on_death.connect(enemy_died)


func enemy_died(_ignored):
	leftover_enemies -= 1
	if leftover_enemies <= 0:
		SceneManager.next_level()
