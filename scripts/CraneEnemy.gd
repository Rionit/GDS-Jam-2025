extends Hittable

@export var speed = 600

@export_range(0.9, 0.999)
var damping = 0.97

## How long does the crane have to be close to the player for the crane to drop
@export
var timeNearPlayerCooldown = 1.5

## Maximum crane-player distance to be considered close
@export
var closeDistance = 200

var timeNearPlayer = 0

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
	
func grab():
	
	
func take_damage(damage : int, hitterPosition : Vector2):
	
	
	
	gain_invulnerability()
