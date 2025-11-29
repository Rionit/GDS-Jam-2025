extends Resource
class_name Perk

## Path to a texture
@export var texture: Texture2D

## Display name for the perk
@export var perk_name: String = ""

## True = buff, False = debuff
@export var is_buff: bool = true

## Numerical value of the perk
@export var value: float = 0.0

## Description of what the perk does
@export_multiline var description: String = ""
