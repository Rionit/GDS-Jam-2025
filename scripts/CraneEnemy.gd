extends Hittable

@export var speed = 400

@export_range(0.9, 0.999)
var damping = 0.98

@export var health = 30

## How long does the crane have to be close to the player for the crane to drop
@export
var timeNearPlayerCooldown = 1.5

## Maximum crane-player distance to be considered close
@export
var closeDistance = 10

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

var timeNearPlayer = 0

func _ready():
	super()
	on_death.connect(Player.get_money)
	grabTimer.timeout.connect(release)

func _process(delta):
	if isUp:
		var vecToPlayer = Player.global_position - global_position
		var dist = vecToPlayer.length()
		
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
		print("Steering vector = " + str(steering))
	
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
	
	await grabTimer.timeout
	
	if limitedMove:
		Player.canMove = true
	if limitedDash:
		Player.canDash = true
		
	limitedMove = false
	limitedDash = false

func grab():
	isUp = false
	timeNearPlayer = 0
	$ShadowSprite.visible = false
	grabAnimPlayer.play("GrabPlayer")
	grabTimer.wait_time = grabDuration
	grabTimer.start()
	
func release():
	grabAnimPlayer.play_backwards("ReleaseReversed")
	await grabAnimPlayer.animation_finished
	isUp = true

func take_damage(damage : int, hitterPosition : Vector2):
	health -= damage
	if health <= 0:
		die()
	else:
		damageAnimPlayer.play("DamageAnim")
		gain_invulnerability()
	
func die():
	if limitedMove:
		Player.canMove = true
	if limitedDash:
		Player.canDash = true
		
	
		
	isDying = true
	on_death.emit(self)
	grabAnimPlayer.play_backwards("ReleaseReversed")
	await grabAnimPlayer.animation_finished
	queue_free()
