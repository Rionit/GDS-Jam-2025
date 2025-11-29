extends Node2D

## Controls player movement and combat
class_name PlayerController

## Player movement dampening multiplier if the player is moving
@export_range(0.90, 0.99)
var dampeningFactorMoving = 0.99

## Player movement dampening multiplier if the player is not moving
@export_range(0.90,0.99)
var dampeningFactorStationary = 0.96

## Should the movement be damped more if the character moves in a
## direction opposite to what the player is pressing ?
@export
var dampOppositeDirection = false

## Minimum squared velocity size for the player to animate walking
const MIN_SPEED_SQUARED = 2500

## Player's CharacterBody
@export
var body : CharacterBody2D

## Player's sprite
@export
var sprite : Sprite2D

@export
var walkingAnim : AnimationPlayer

## Whether the player walking animation is currently playing or not
var playingWalk = false

## Enum for mapping movement keys
enum KEY { LEFT, RIGHT, UP, DOWN}

## Names of the input actions, sorted corresponding to KEY enum
var moveActions = ["left", "right", "up", "down"]

## Array of currently pressed movement keys, sorted chronologically
## (longest pushed buttons first)
var pressedMoveKeys : Array[KEY]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressedMoveKeys = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_register_keys()
	_process_movement(delta)
	
	body.move_and_slide()

## Registers pressed keys
func _register_keys():
	_register_move_keys()

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

## Applies force to the player corresponding to the movement keys pressed
func _process_movement(delta : float):
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
	velocity = velocity.normalized() * delta * 1300
	body.velocity += velocity
	
	if velocity == Vector2.ZERO || \
	 (dampOppositeDirection && velocity.dot(body.velocity) < 0) :
		body.velocity *= dampeningFactorStationary
	else:
		body.velocity *= dampeningFactorMoving
	
	var speedSquared = body.velocity.length_squared()
	
	if playingWalk && speedSquared < MIN_SPEED_SQUARED:
		playingWalk = false
		walkingAnim.stop()
		
	elif !playingWalk && speedSquared >= MIN_SPEED_SQUARED:
		print("Playing anim")
		playingWalk = true
		walkingAnim.play("WalkingAnim")
	sprite.flip_h = velocity.x >= 0
