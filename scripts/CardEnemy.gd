extends Hittable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export
var cooldown := 3.0

const COOLDOWN_BASE = 3.0

var is_cooling_down := false

@export
var health = 30
const HEALTH_BASE = 30

var velocity_modifier = 1.0

@export
var damage_anim_player : AnimationPlayer

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
		hp_mod -= bhp.value * modif
	for dhp in d_hp:
		hp_mod += dhp.value * modif
	for bsp in b_sp:
		sp_mod -= bsp.value * modif
	for dsp in d_sp:
		sp_mod += dsp.value * modif
		
	for cd in bcd:
		cd_mod += cd.value * modif
	for cd in dcd:
		cd_mod -= cd.value * modif
	
	cooldown = COOLDOWN_BASE * (cd_mod/100)
	velocity_modifier = (sp_mod/100)
	health = HEALTH_BASE * (hp_mod/100)

func _ready():
	super()
	set_perks()
	on_death.connect(Player.get_money)
	$PhysicsHitbox.body_entered.connect(_on_hitbox_body_entered)
	
func _process(delta: float) -> void:
	if !isDying:
		if velocity == Vector2.ZERO and !is_cooling_down:
			get_tree().create_timer(cooldown).timeout.connect(throw)
			is_cooling_down = true
	move_and_slide()

func throw():
	AudioManager.play_sfx(load ("res://sound/enemies/cards/flying-fast.wav"), -15.0)
	$Hitbox.collision_mask = 2
	animation_player.play("rotate")
	var dir_to_player = (Player.global_position - global_position).normalized()
	velocity = dir_to_player * 600.0
	print("Velocity: " + str(velocity))
	is_cooling_down = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	AudioManager.play_sfx(load("res://sound/enemies/cards/hit_wall.wav"), -15.0)
	print("BODY ENTERED")
	velocity = Vector2.ZERO
	animation_player.pause()
	
func take_damage(damage : int, hitterPosition : Vector2):
	AudioManager.play_sfx(load("res://sound/enemies/cards/get_hit.wav"), -10.0)
	health -= damage
	if health <= 0:
		die()
	else:
		gain_invulnerability()
		damage_anim_player.play("DamageAnimation")
		
func die():
	AudioManager.play_sfx(load("res://sound/enemies/cards/death.wav"), -10.0)
	isDying = true
	on_death.emit(self)
	$Hitbox.collision_mask = 0
	damage_anim_player.play("DieAnimation")
	await damage_anim_player.animation_finished
	
	instantiate_money()
	
	queue_free()
	
