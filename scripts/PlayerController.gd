extends Hittable

## Controls player movement and combat
class_name PlayerController

@export_group("COMMON")
@export
var animPlayer : AnimationPlayer

@export
var hairTextures : Array[Texture]

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

var playingHairloss = false

@onready var hairlossKnockback: ShapeCast2D = $HairlossKnockback

## Minimum squared velocity size for the player to animate walking
const MIN_SPEED_SQUARED = 4000

## Player's CharacterBody
#@export
#var body : CharacterBody2D

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
## Invoked when the player balds, but doesn't die.
##
## Current baldness level is passed as a parameter
signal on_balding(baldness : int)

## Invoked when player receives damage
signal on_damage_taken(damage : int)

## Player's maximum sanity
@export
var maxSanity = 300

## Player's sanity loss
@export
var sanityLoss = 10

@onready
var currentSanity = maxSanity

var baldness = 0

@export
var damageAnimPlayer : AnimationPlayer

## Punch VFX sprite
@export
var punchSprite : Sprite2D

## Fist punch hitbox
@export
var fistHitbox : Area2D

## Cooldown between 
@export_range(0.1, 5)
var punchCooldown = 1.0

## Duration of the punch animation
@export_range(0.1, 2)
var punchDuration = 0.6

@export
var punchTimer : Timer

var canPunch = true

var defaultPunchAnimLen

var playingPunch = false

var money = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	position = Vector2(180, 620)
	punchSprite.visible = false
	pressedMoveKeys = []
	on_balding.connect(PerkMachine.on_balding)
	defaultPunchAnimLen = animPlayer.get_animation("PunchAnim").length

func _physics_process(delta: float) -> void:
	if !isDying:
		_register_keys()
		if canMove:
			_process_movement()
		else:
			for key in pressedMoveKeys:
				if key == KEY.LEFT || key == KEY.RIGHT:
					if key == KEY.LEFT:
						scale.y = 1
						rotation = 0
					else:
						scale.y = -1
						rotation = PI
					break
				else:
					continue
		if afterDashDamp:
			velocity *= dampeningFactorMoving
		move_and_slide()

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
func _tween_dash_vfx(dir : Vector2):
	# Dash VFX is on the LEFT if the player 
	# is moving to the RIGHT
	var isLeft = -1 if scale.x < 0 else 1
	var newDash = dashVFX.duplicate()
	newDash.visible = true
	newDash.flip_h = isLeft == -1
	
	get_tree().current_scene.add_child(newDash)
	
	newDash.global_position = global_position + Vector2(defaultDashSpriteX * isLeft,\
	dashVFX.position.y)
	var VFXDist = newDash.position.x + (defaultDashSpriteX \
	+ dashVFXAnimDistance) * isLeft
	
	var VFXTween = get_tree().create_tween().bind_node(newDash)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	VFXTween.tween_property(newDash, "position:x", VFXDist, 0.4)
	VFXTween.parallel().tween_property(newDash,"modulate:a", 0, 0.4)
	VFXTween.tween_callback(newDash.queue_free)

## Dashes to the predefined direction
func _dash(dir : Vector2):
	AudioManager.play_sfx(load("res://sound/player/dash.mp3"), -10.0)
	canMove = false
	canDash = false
	
	var couldPunch = canPunch
	
	canPunch = false
	
	animPlayer.stop()
	animPlayer.play("RESET")
	_stop_punch()
	
	_tween_dash_vfx(dir)
	var dashAnim = animPlayer.get_animation("DashAnim")
	dashAnim.length = dashDuration
	dashAnim.track_set_key_time(0, 1, dashDuration)
	playingWalk=false
	
	animPlayer.queue("DashAnim")
	velocity = dir * dashSpeed * dampeningFactorMoving
	
	dashTimer.wait_time = dashDuration
	dashTimer.start()
	
	await dashTimer.timeout
	afterDashDamp = true
	dashTimer.wait_time = dashMoveCooldown - dashDuration
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

	self.velocity += velocity
	
	if velocity == Vector2.ZERO || \
	 (dampOppositeDirection && velocity.dot(self.velocity) < 0) :
		self.velocity *= dampeningFactorStationary
	else:
		self.velocity *= dampeningFactorMoving
	
	var speedSquared = self.velocity.length_squared()
	
	if !playingPunch && !playingHairloss:
		if playingWalk && speedSquared < MIN_SPEED_SQUARED:
			playingWalk = false
			animPlayer.stop()
			animPlayer.play("RESET")
			_stop_punch()
			animPlayer.queue("IdleAnim")
		elif !playingWalk && speedSquared >= MIN_SPEED_SQUARED:
			print("Playing anim")
			playingWalk = true
			animPlayer.stop()
			animPlayer.play("RESET")
			_stop_punch()
			animPlayer.queue("WalkingAnim")
		
	if velocity.x > 0:
		scale = Vector2(1,-1)
		rotation_degrees = 180
	elif velocity.x < 0:
		scale = Vector2(1,1)
		rotation = 0

	if canDash && Input.is_action_pressed("dash"):
		_dash(velocity.normalized())
		return

func _stop_punch():
	animPlayer.speed_scale = 1
	fistHitbox.collision_layer = 0
	punchSprite.visible = false

func _punch():
	AudioManager.play_sfx(load("res://sound/player/swing_hand.wav"))
	canPunch = false
	animPlayer.stop()
	animPlayer.play("RESET")
	playingWalk = false
	playingPunch = true
	
	var punchAnim = animPlayer.get_animation("PunchAnim")
	var animLen = min(punchCooldown - 0.05, defaultPunchAnimLen)
	
	animPlayer.speed_scale = defaultPunchAnimLen / animLen
	
	##Sets texture change time
	#punchAnim.length = animLen
	#punchAnim.track_set_key_time(0,1, animLen)
	#
	##Sets alpha reduction time and easing
	#punchAnim.track_set_key_time(1,1,animLen)
	#punchAnim.bezier_track_set_key_out_handle(1,0, Vector2(2*animLen/3,-1))
	#punchAnim.bezier_track_set_key_in_handle(1,1, Vector2(-animLen/3, 0))
	
	# Sets hitbox disablement time
	#punchAnim.track_set_key_time(2,1,animLen)
	animPlayer.queue("PunchAnim")
	
	# Starts the cooldown timer
	punchTimer.wait_time = punchCooldown
	punchTimer.start()
	
	await animPlayer.animation_finished
	animPlayer.speed_scale = 1
	playingPunch = false
	
	await punchTimer.timeout
	canPunch = true
	
# TODO: Take damage
func take_damage(damage : int, hitterPosition : Vector2):
	AudioManager.play_sfx(load("res://sound/player/get_hit.wav"))
	currentSanity -= damage
	if currentSanity <= 0:
		baldness += 1
		if baldness == 4:
			on_death.emit(self)
			queue_free()
			pass
		else:
			hairlossKnockback.force_shapecast_update()
			for i in range(hairlossKnockback.get_collision_count()):
				var collision : Area2D = hairlossKnockback.get_collider(i)
				var collisionParent = collision.get_parent()
				if collisionParent is Hittable:
					(collisionParent as Hittable).take_knockback(global_position)
			
			get_tree().create_timer(0.2).timeout.connect(_switch_hair)
			
			on_balding.emit(baldness)
			animPlayer.stop()
			animPlayer.play("RESET")
			AudioManager.play_sfx(load("res://sound/player/hair_ripping.wav"))
			AudioManager.play_sfx(load("res://sound/player/hair_pulling_scream.wav"))
			animPlayer.queue("HairLossAnim")
			maxSanity -= sanityLoss
			currentSanity = maxSanity
			playingHairloss = true
			
			await animPlayer.animation_changed
			await animPlayer.animation_finished
			
			playingHairloss = false
	else:
		on_damage_taken.emit(damage)
		take_knockback(hitterPosition)
		damageAnimPlayer.play("DamageAnim")
		gain_invulnerability()
		# TODO: Add knockback for enemy entities

func _switch_hair():
	if baldness < 3:
		$HairSprite.texture = hairTextures[baldness]
	else:
		$HairSprite.texture = null
		
func get_money(deadEnemy : Hittable):
	AudioManager.play_sfx(load("res://sound/player/coins_picked.wav"))
	money += deadEnemy.price
	GUI.update_money(money)

func has_money(requiredMoney : int):
	return money >= requiredMoney

func lose_money(money : int):
	money -= money
	GUI.update_money(money)
