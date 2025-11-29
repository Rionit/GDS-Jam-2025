extends Node2D

const SLOTMACHINE_BLUE = preload("uid://b2j8dvr25m2su")
const SLOTMACHINE_GREEN = preload("uid://cj503a56ks7vp")
const SLOTMACHINE_RED = preload("uid://c4ddpnlb270ix")

const textures : Array[Texture] = [SLOTMACHINE_BLUE, SLOTMACHINE_GREEN, SLOTMACHINE_RED] 

@onready var sprite_2d: Sprite2D = $MachineSprite

func _ready() -> void:
	sprite_2d.texture = textures.pick_random()
	
func _process(delta: float) -> void:
	# TODO: go towrads player
	pass

func attack():
	print("attacked!")
