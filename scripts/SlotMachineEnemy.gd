extends Hittable

const SLOTMACHINE_BLUE = preload("uid://b2j8dvr25m2su")
const SLOTMACHINE_GREEN = preload("uid://cj503a56ks7vp")
const SLOTMACHINE_RED = preload("uid://c4ddpnlb270ix")

const textures: Array[Texture] = [SLOTMACHINE_BLUE, SLOTMACHINE_GREEN, SLOTMACHINE_RED]

@onready var vfx_sprite: Sprite2D = $MotherFlipper/VFXSprite
@onready var sprite_2d: Sprite2D = $MotherFlipper/MachineSprite
@onready var mother_flipper: Node2D = $MotherFlipper
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $AttackTimer

var max_speed := 300
const MAX_SPEED_BASE = 300

var max_accel := 800
var stop_distance := 200.0
var max_cooldown : float = 0.5
const COOLDOWN_BASE = 0.5

var is_attacking := false

var health : int = 30
const HEALTH_BASE = 30


var is_orb_clockwise := false

func set_perks():
	var hp_mod = 100
	var sp_mod = 100
	var cd_mod = 100
	var modif = PerkMachine.current_perk_modifier
	
	var bcd = PerkMachine.return_perk(Perk.PerkEnum.B_ENEMY_COOLDOWN)
	var dcd = PerkMachine.return_perk(Perk.PerkEnum.D_ENEMY_COOLDOWN)
	
	var b_hp = PerkMachine.return_perk(Perk.PerkEnum.B_ENEMY_HEALTH)
	var d_hp = PerkMachine.return_perk(Perk.PerkEnum.D_ENEMY_HEALTH)
	
	var b_sp = PerkMachine.return_perk(Perk.PerkEnum.B_ENEMY_MOVEMENT)
	var d_sp = PerkMachine.return_perk(Perk.PerkEnum.D_ENEMY_MOVEMENT)
	
	for bhp in b_hp:
		hp_mod -= bhp * modif
	for dhp in d_hp:
		hp_mod += dhp * modif
	for bsp in b_sp:
		sp_mod -= bsp * modif
	for dsp in d_sp:
		sp_mod += dsp * modif
		
	for cd in bcd:
		cd_mod += cd * modif
	for cd in dcd:
		cd_mod -= cd * modif
	
	max_cooldown = COOLDOWN_BASE * (cd_mod/100)
	max_speed = MAX_SPEED_BASE * (sp_mod/100)
	health = HEALTH_BASE * (hp_mod/100)

func _ready() -> void:
	super()
	on_death.connect(Player.get_money)
	sprite_2d.texture = textures.pick_random()
	vfx_sprite.modulate.a = 0.0

func _process(delta: float) -> void:
	if !isDying:
		if !isKnockedBack:
			var dist_to_player = global_position.distance_to(Player.global_position)

			# Move toward player using arrive
			var steering := arrive(Player.global_position)

			# stop when close
			if dist_to_player <= stop_distance:
				# start attack
				if !is_attacking:
					is_attacking = true
					if attack_timer.time_left == 0:
						attack_timer.wait_time = max_cooldown
						attack_timer.timeout.connect(attack)
						attack_timer.start()

				# orbit around player
				var offset = global_position - Player.global_position

				var tangent = Vector2(-offset.y, offset.x).normalized()
				
				# randomly switch orb direction
				if randf() < 0.01:
					is_orb_clockwise = !is_orb_clockwise
				
				if is_orb_clockwise:
					tangent *= -1
				
				var orbit_speed = max_speed * 0.7 
				var desired_vel = tangent * orbit_speed

				steering = (desired_vel - velocity).normalized() * max_accel

			#velocity += steering * delta
		#
			#if velocity.length() > max_speed:
				#velocity = velocity.normalized() * max_speed

			self.velocity += steering * delta

			var isLeft = 1 if velocity.x >= 0 else -1
			mother_flipper.scale.x = isLeft
		else:
			velocity *= 0.93
		move_and_slide()

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
	AudioManager.play_sfx(load("res://sound/enemies/slot_machines/lever_swing.wav"), -2.0)
	animation_player.speed_scale = max(1 / max_cooldown, 1.0)
	animation_player.play("attack")
	await animation_player.animation_finished
	attack_timer.timeout.disconnect(attack)
	is_attacking = false

func take_damage(damage : int, hitterPosition : Vector2):
	AudioManager.play_sfx(load("res://sound/enemies/slot_machines/get_hit.wav"), -5.0)
	health -= damage
	if health <= 0:
		on_death.emit((self as Hittable))
		die()
	else:
		take_knockback(hitterPosition)
		animation_player.play("damage")
		gain_invulnerability()
	
func die():
	AudioManager.play_sfx(load("res://sound/enemies/slot_machines/death.wav"), -7.0)
	
	isDying = true
	print("DYING!")
	
	instantiate_money()

	attack_timer.timeout.disconnect(attack)
	attack_timer.stop()
	
	$BodyHitbox.collision_layer = 0
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("death")
	velocity = Vector2.ZERO
	await animation_player.animation_finished
	
	queue_free()
