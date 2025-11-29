extends Control

const B_ENEMY_COOLDOWN : Perk = preload("uid://hehmmh3njgau")
const B_ENEMY_HEALTH : Perk = preload("uid://dv07j32e8p6e1")
const B_ENEMY_MOVEMENT : Perk = preload("uid://cgusafvcn5lhy")
const B_PLAYER_COOLDOWN : Perk = preload("uid://pytgf6k7oovj")
const B_PLAYER_MOVEMENT : Perk = preload("uid://bvjntnyjqyjsf")
const D_ENEMY_HEALTH : Perk = preload("uid://dqnm8i764sdfh")
const D_ENEMY_MOVEMENT : Perk = preload("uid://bsuxm83bqseb")
const D_PLAYER_COOLDOWN : Perk = preload("uid://ccyf8t218mlh4")
const D_PLAYER_MOVEMENT : Perk = preload("uid://dy27shbo06qf3")

enum PerkEnum {
	B_ENEMY_COOLDOWN,
	B_ENEMY_HEALTH,
	B_ENEMY_MOVEMENT,
	B_PLAYER_COOLDOWN,
	B_PLAYER_MOVEMENT,
	D_ENEMY_HEALTH,
	D_ENEMY_MOVEMENT,
	D_PLAYER_COOLDOWN,
	D_PLAYER_MOVEMENT
}

## Array containing all [Perk] resources
var all_perks: Array[Perk] = [
	B_ENEMY_COOLDOWN,
	B_ENEMY_HEALTH,
	B_ENEMY_MOVEMENT,
	B_PLAYER_COOLDOWN,
	B_PLAYER_MOVEMENT,
	D_ENEMY_HEALTH,
	D_ENEMY_MOVEMENT,
	D_PLAYER_COOLDOWN,
	D_PLAYER_MOVEMENT
]

@onready var icon_spinner_1: IconSpinner = %IconSpinner
@onready var icon_spinner_2: IconSpinner = %IconSpinner2
@onready var icon_spinner_3: IconSpinner = %IconSpinner3

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		icon_spinner_1.cycles = 9
		icon_spinner_1.spin()
		icon_spinner_2.cycles = 12
		icon_spinner_2.spin()
		icon_spinner_3.cycles = 15
		icon_spinner_3.spin()
