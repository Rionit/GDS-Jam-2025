extends Node2D

const SLOTMACHINE_BLUE = preload("uid://b2j8dvr25m2su")
const SLOTMACHINE_GREEN = preload("uid://cj503a56ks7vp")
const SLOTMACHINE_RED = preload("uid://c4ddpnlb270ix")

const textures: Array[Texture] = [SLOTMACHINE_BLUE, SLOTMACHINE_GREEN, SLOTMACHINE_RED]

@onready var vfx_sprite: Sprite2D = $MotherFlipper/VFXSprite
@onready var sprite_2d: Sprite2D = $MotherFlipper/MachineSprite
@onready var mother_flipper: Node2D = $MotherFlipper
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var max_speed := 180.0
var max_accel := 480.0
var stop_distance := 200.0
var max_cooldown : float = 0.5
var is_attacking := false

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	sprite_2d.texture = textures.pick_random()
	vfx_sprite.modulate.a = 0.0

func _process(delta: float) -> void:
	
	var dist_to_player = global_position.distance_to(Player.global_position)

	# stop when close
	if dist_to_player <= stop_distance:
		if !is_attacking:
			is_attacking = true
			get_tree().create_timer(max_cooldown).timeout.connect(attack)
		velocity = Vector2.ZERO
		return

	# Move toward player using arrive
	var steering := arrive(Player.global_position)
	velocity += steering * delta

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	position += velocity * delta
	
	var isLeft = 1 if velocity.x >= 0 else -1
	mother_flipper.scale.x = isLeft

## Arrive at a static target
func arrive(target_pos: Vector2) -> Vector2:
	var to_target = target_pos - global_position
	var distance = to_target.length()

	if distance < stop_distance:
		return Vector2.ZERO

	var slowing_distance = max_speed * max_speed / (2.0 * max_accel)
	var d = min(distance / slowing_distance, 1.0)
	var clipped_speed = d * max_speed

	var desired_vel = to_target.normalized() * clipped_speed
	return (desired_vel - velocity).normalized() * max_accel


## Seek (required for pursue)
func seek(target_pos: Vector2) -> Vector2:
	var desired = (target_pos - global_position).normalized() * max_speed
	return (desired - velocity).normalized() * max_accel


## Pursue a moving target
func pursue(target_pos: Vector2, target_vel: Vector2) -> Vector2:
	var time_to_target = (target_pos - global_position).length() / max_speed
	var predicted_pos = target_pos + target_vel * time_to_target
	return seek(predicted_pos)


func attack():
	animation_player.speed_scale = max(1 / max_cooldown, 1.0)
	animation_player.play("attack")
	await animation_player.animation_finished
	is_attacking = false
