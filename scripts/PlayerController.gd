extends Node2D

## Controls player movement and combat
class_name PlayerController

@export_group("COMMON")
@export
var animPlayer : AnimationPlayer

### MOVEMENT
@export_group("MOVEMENT")

## Player movement dampening multiplier if the player is moving
@export_range(0.90, 0.99)
var dampeningFactorMoving = 0.95

## Player movement dampening multiplier if the player is not moving
@export_range(0.90,0.99)
var dampeningFactorStationary = 0.90

## Player movement speed, in units per second
@export_range(50, 1000)
var moveSpeed = 50

## Player's dash speed, in units per second
@export_range(50,1000)
var dashSpeed = 1000

## Duration of the dash taking effect
@export_range(0,1)
var dashDuration = 0.3

## Duration after dash during which the player can't move
@export_range(0,2)
var dashMoveCooldown = 0.35

## Duration after dash during which the player can't use another dash
@export_range(0,30)
var dashCooldown = 2

## Should the movement be damped more if the character moves in a
## direction opposite to what the player is pressing ?
@export
var dampOppositeDirection = false

## Default (local) X position of the dash VFX
@onready
var defaultDashSpriteX = dashVFX.position.x

@export
var dashVFXAnimDistance = 20

## Minimum squared velocity size for the player to animate walking
const MIN_SPEED_SQUARED = 4000

## Player's CharacterBody
@export
var body : CharacterBody2D

## Player's sprite
@export
var sprite : Sprite2D

@export
var dashTimer : Timer

## Dash VFX sprite
@export
var dashVFX : Sprite2D

## Whether the player walking animation is currently playing or not
var playingWalk = false

## Enum for mapping movement keys
enum KEY { LEFT, RIGHT, UP, DOWN}

## Names of the input actions, sorted corresponding to KEY enum
var moveActions = ["left", "right", "up", "down"]

## Array of currently pressed movement keys, sorted chronologically
## (longest pushed buttons first)
var pressedMoveKeys : Array[KEY]

## Whether the player can perform a dash
var canDash = true

## Whether the player can move
var canMove = true

## Damping used after the player has dashed
var afterDashDamp = false

@export_group("COMBAT")
signal on_balding(baldness : int)

## Player's maximum sanity
@export
var maxSanity = 100

## Player's sanity loss
@export
var sanityLoss = 10

@onready
var currentSanity = maxSanity

@export
var playerDamage = 10

var baldness = 0

## Punch VFX sprite
@export
var punchSprite : Sprite2D

## Fist punch hitbox
@export
var fistHitbox : Area2D

## Cooldown between 
@export_range(0.1, 5)
var punchCooldown = 1

## Duration of the punch animation
@export_range(0.1, 2)
var punchDuration = 0.6

@export
var punchTimer : Timer

var canPunch = true

var defaultPunchAnimLen

var playingPunch = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	punchSprite.visible = false
	pressedMoveKeys = []
	on_balding.connect(PerkMachine.on_balding)
	defaultPunchAnimLen = animPlayer.get_animation("PunchAnim").length
	
func _physics_process(delta: float) -> void:
	_register_keys()
	if canMove:
		_process_movement()
	if afterDashDamp:
		body.velocity *= dampeningFactorMoving
	body.move_and_slide()

## Registers pressed keys
func _register_keys():
	_register_move_keys()
	if canPunch && Input.is_action_pressed("attack"):
		_punch()

## Registers inputs for player movement	
func _register_move_keys():
	for key in KEY.values():
		var index = pressedMoveKeys.find((key as KEY))
		var action = moveActions[key]
		
		if Input.is_action_pressed(action):
			if index == -1:
				pressedMoveKeys.append((key as KEY))
		elif index != -1:
			pressedMoveKeys.remove_at(index)

## Tweens the dash VFX animation
func _tweenDashVFX(dir : Vector2):
	# Dash VFX is on the LEFT if the player 
	# is moving to the RIGHT
	## TODO: Add multi-dimensional dash
	var isLeft = -1 if dir.x >= 0 else 1
	var newDash = dashVFX.duplicate()
	newDash.visible = true
	newDash.flip_h = isLeft == -1
	newDash.global_position = body.global_position + Vector2(defaultDashSpriteX * isLeft,\
	dashVFX.position.y)
	
	add_child(newDash)
	var VFXDist = newDash.position.x + (defaultDashSpriteX \
	+ dashVFXAnimDistance) * isLeft
	
	var VFXTween = get_tree().create_tween().bind_node(newDash)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	VFXTween.tween_property(newDash, "position:x", VFXDist, 0.4)
	VFXTween.parallel().tween_property(newDash,"modulate:a", 0, 0.4)
	VFXTween.tween_callback(newDash.queue_free)

## Dashes to the predefined direction
func _dash(dir : Vector2):
	canMove = false
	canDash = false
	
	var couldPunch = canPunch
	
	canPunch = false
	
	_stop_punch()
	
	animPlayer.stop()
	_tweenDashVFX(dir)
	var dashAnim = animPlayer.get_animation("DashAnim")
	dashAnim.length = dashDuration
	dashAnim.track_set_key_time(0, 1, dashDuration)
	playingWalk=false
	animPlayer.play("DashAnim")
	body.velocity = dir * dashSpeed * dampeningFactorMoving
	
	dashTimer.wait_time = dashDuration
	dashTimer.start()
	
	await dashTimer.timeout
	afterDashDamp = true
	dashTimer.wait_time = dashMoveCooldown - dashDuration
	print("Dash move cooldown " + str(dashMoveCooldown) + "; Dash duration: " + str(dashDuration))
	print("Second timer time: " + str(dashTimer.wait_time))
	dashTimer.start()
	
	await dashTimer.timeout
	afterDashDamp = false
	canMove = true
	if couldPunch:
		canPunch = true
	dashTimer.wait_time = dashCooldown - dashMoveCooldown - dashDuration
	
	dashTimer.start()
	await dashTimer.timeout
	canDash = true
	
## Applies force to the player corresponding to the movement keys pressed
func _process_movement():
	var processedHorizontal = false
	var processedVertical = false
	
	var velocity = Vector2.ZERO
	
	for key in pressedMoveKeys:
		if !processedHorizontal && key <= KEY.RIGHT:
			if key == KEY.LEFT:
				velocity.x = -1
			elif key == KEY.RIGHT:
				velocity.x = 1
			
			processedHorizontal = true
			continue
		if !processedVertical && key >= KEY.UP:
			if key == KEY.UP:
				velocity.y = -1
			elif key == KEY.DOWN:
				velocity.y = 1
			processedVertical = true
			continue
		if processedHorizontal && processedVertical:
			break
	velocity = velocity.normalized() * moveSpeed

	body.velocity += velocity
	
	if velocity == Vector2.ZERO || \
	 (dampOppositeDirection && velocity.dot(body.velocity) < 0) :
		body.velocity *= dampeningFactorStationary
	else:
		body.velocity *= dampeningFactorMoving
	
	var speedSquared = body.velocity.length_squared()
	
	if !playingPunch:
		if playingWalk && speedSquared < MIN_SPEED_SQUARED:
			playingWalk = false
			animPlayer.stop()
			animPlayer.play("IdleAnim")
		elif !playingWalk && speedSquared >= MIN_SPEED_SQUARED:
			print("Playing anim")
			playingWalk = true
			animPlayer.stop()
			animPlayer.play("WalkingAnim")
		
	if velocity.x >= 0:
		body.scale = Vector2(1,-1)
		body.rotation_degrees = 180
	else:
		body.scale = Vector2(1,1)
		body.rotation = 0

	if canDash && Input.is_action_pressed("dash"):
		_dash(velocity.normalized())
		return

func _stop_punch():
	fistHitbox.collision_layer = 0
	punchSprite.visible = false

func _punch():
	canPunch = false
	animPlayer.stop()
	playingWalk = false
	playingPunch = true
	
	print("PUNGING")
	punchSprite.visible = true
	
	var punchAnim = animPlayer.get_animation("PunchAnim")
	var animLen = min(punchCooldown - 0.05, defaultPunchAnimLen)
	
	#Sets texture change time
	punchAnim.length = animLen
	punchAnim.track_set_key_time(0,1, animLen)
	
	#Sets alpha reduction time and easing
	punchAnim.track_set_key_time(1,1,animLen)
	punchAnim.bezier_track_set_key_out_handle(1,0, Vector2(2*animLen/3,-1))
	punchAnim.bezier_track_set_key_in_handle(1,1, Vector2(-animLen/3, 0))
	
	# Sets hitbox disablement time
	punchAnim.track_set_key_time(2,1,animLen)
	
	animPlayer.play("PunchAnim")
	# Starts the cooldown timer
	punchTimer.wait_time = punchCooldown
	punchTimer.start()
	
	await animPlayer.animation_finished
	print("Is punch sprite visible ?" + str(punchSprite.visible))
	playingPunch = false
	
	await punchTimer.timeout
	canPunch = true
