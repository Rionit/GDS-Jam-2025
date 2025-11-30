extends Hittable

@export var speed = 500
const SPEED_BASE = 500

@export_range(0.9, 0.999)
var damping = 0.99

@export var health = 30
const HEALTH_BASE = 30

## How long does the crane have to be close to the player for the crane to drop
@export
var timeNearPlayerCooldown = 1.25

## Maximum crane-player distance to be considered close
@export
var closeDistance = 350

@export
var grabDuration = 3.0

@export
var grabAnimPlayer : AnimationPlayer

@export
var damageAnimPlayer : AnimationPlayer

@export
var grabTimer : Timer

var isUp = true

var limitedMove = false
var limitedDash = false
var addedDamp = false

var timeNearPlayer = 0

func set_perks():
	var hp_mod = 100
	var sp_mod = 100
	var modif = PerkMachine.current_perk_modifier
	
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
		
	speed = SPEED_BASE * (sp_mod/100)
	health = HEALTH_BASE * (hp_mod/100)
	

func _ready():
	super()
	set_perks()
	on_death.connect(Player.get_money)
	grabTimer.timeout.connect(release)
	weaponHitbox.area_entered.connect(check_catch)

func _process(delta):
	if isUp:
		var vecToPlayer = Player.global_position - global_position
		var dist = vecToPlayer.length()
		
		var x = closeDistance / dist
		$ShadowSprite.modulate.a = max(0.3, min(x, 0,8))
		
		if dist <= closeDistance:
			timeNearPlayer += delta
			if timeNearPlayer >= timeNearPlayerCooldown:
				grab()
		else:
			timeNearPlayer = 0
		
		var steering = vecToPlayer.normalized()*speed*delta
		
		velocity += steering
		velocity *= damping
		move_and_slide()
	
func check_catch(potentialPlayer : Area2D):
	var parent = potentialPlayer.get_parent()
	if parent is PlayerController && \
	!(parent as PlayerController).isInvulnerable && \
	!(parent as PlayerController).isDying:
		catch_player()

func catch_player():
	AudioManager.play_sfx(load("res://sound/enemies/crane/stop.wav"))
	if Player.canMove:
		Player.canMove = false
		limitedMove = true
	if Player.canDash:
		Player.canDash = false
		limitedDash = true
	if !Player.afterDashDamp:
		Player.afterDashDamp = true
		addedDamp = true
	
	
	
	await grabTimer.timeout
	
	if limitedMove:
		Player.canMove = true
	if limitedDash:
		Player.canDash = true
	if addedDamp:
		Player.afterDashDamp = false
		
	limitedMove = false
	limitedDash = false
	addedDamp = false

func grab():
	AudioManager.play_sfx(load("res://sound/enemies/crane/grab.wav"), -10.0)
	isUp = false
	timeNearPlayer = 0
	$ShadowSprite.visible = false
	grabAnimPlayer.play("GrabPlayer")
	grabTimer.wait_time = grabDuration
	grabTimer.start()
	
func release():
	AudioManager.play_sfx(load("res://sound/enemies/crane/down.wav"), -20.0)
	grabAnimPlayer.play_backwards("ReleaseReversed")
	await grabAnimPlayer.animation_finished
	isUp = true
	$ShadowSprite.visible = true

func take_damage(damage : int, hitterPosition : Vector2):
	AudioManager.play_sfx(load("res://sound/enemies/crane/get_hit.wav"), -20.0)
	health -= damage
	if health <= 0:
		die() 
	else:
		damageAnimPlayer.play("DamageAnim")
		gain_invulnerability()
	
func die():
	AudioManager.play_sfx(load("res://sound/enemies/crane/death.wav"), -15.0)
	if limitedMove:
		Player.canMove = true
	if limitedDash:
		Player.canDash = true
	if addedDamp:
		Player.afterDashDamp = false
		
	instantiate_money()
	isDying = true
	on_death.emit(self)
	grabAnimPlayer.play_backwards("ReleaseReversed")
	await grabAnimPlayer.animation_finished
	queue_free()
