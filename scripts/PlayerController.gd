extends Node2D

## Controls player movement and combat
class_name PlayerController

@export
var body : CharacterBody2D

@export
var sprite : Sprite2D

enum KEY { LEFT, RIGHT, UP, DOWN}

var pressedMoveKeys : Array[KEY]

var moveActions = ["left", "right", "up", "down"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressedMoveKeys = []
	pass # Replace with function body.


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
		if !processedHorizontal:
			if key == KEY.LEFT:
				velocity.x = -delta * 1000
			elif key == KEY.RIGHT:
				velocity.x = delta * 1000
			processedHorizontal = true
		if !processedVertical:
			if key == KEY.UP:
				velocity.y -= delta * 1000
			elif key == KEY.DOWN:
				velocity.y += delta * 1000
			processedVertical = true
	body.velocity += velocity
	
	sprite.flip_h = body.velocity.x >= 0
