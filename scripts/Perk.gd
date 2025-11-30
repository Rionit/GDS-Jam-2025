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

enum PerkEnum {
	B_ENEMY_COOLDOWN,
	B_ENEMY_HEALTH,
	B_ENEMY_MOVEMENT,
	B_PLAYER_COOLDOWN,
	B_PLAYER_MOVEMENT,
	D_ENEMY_COOLDOWN,
	D_ENEMY_HEALTH,
	D_ENEMY_MOVEMENT,
	D_PLAYER_COOLDOWN,
	D_PLAYER_MOVEMENT
}

@export
var type : PerkEnum


func format_text(multiplier : int) -> String:
	var val_color := "#7cf57c" if is_buff else "#ff5c5c"  # green if buff, red if debuff

	var bbcode := ""
	bbcode += "[color=#ffd700][b]" + perk_name + "[/b][/color]\n"
	bbcode += "[i]" + description + "[/i]\n"
	bbcode += "[color=" + val_color + "]Value: [b]" + str(value * multiplier) + "[/b][/color]"
	return bbcode
