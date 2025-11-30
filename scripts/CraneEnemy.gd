extends Hittable

@export var speed = 600

@export_range(0.9, 0.999)
var damping = 0.97

@export var health = 30

## How long does the crane have to be close to the player for the crane to drop
@export
var timeNearPlayerCooldown = 1.5

## Maximum crane-player distance to be considered close
@export
var closeDistance = 200

@export
var grabDuration = 3.0

@export
var grabAnimPlayer : AnimationPlayer

@export
var damageAnimPlayer : AnimationPlayer

var limitedMove = false
var limitedDash = false

var timeNearPlayer = 0

func _ready():
	super()
	on_death.connect(Player.get_money)

func _process(delta):
	var vecToPlayer = Player.global_position - global_position
	var dist = vecToPlayer.length()
	
	if dist >= closeDistance:
		timeNearPlayer += delta
		if timeNearPlayer >= timeNearPlayerCooldown:
			# TODO: Grab
			pass
	else:
		timeNearPlayer = 0
	
	var steering = vecToPlayer.normalized()*speed*delta
	
	velocity += steering
	velocity *= damping
	
func check_catch(potentialPlayer : Area2D):
	var parent = potentialPlayer.get_parent()
	if parent is PlayerController && \
	!(parent as PlayerController).isInvulnerable && \
	!(parent as PlayerController).isDying:
		catch_player()
		
func catch_player():
	if Player.canMove:
		Player.canMove = false
		limitedMove = true
	if Player.canDash:
		Player.canDash = false
		limitedDash = true
	
	await get_tree().create_timer(grabDuration).timeout
	
	Player.canMove = true
	Player.canDash = true

func grab():
	grabAnimPlayer.play("GrabPlayer")
	
	
	
func release():
	

func take_damage(damage : int, hitterPosition : Vector2):
	health -= damage
	if health <= 0:
		die()
	else:
		damageAnimPlayer.play("DamageAnim")
		gain_invulnerability()
	
func die():
	isDying = true
	on_death.emit(self)
	grabAnimPlayer.play_backwards("GrabAnimation")
	await grabAnimPlayer.animation_finished
	queue_free()
