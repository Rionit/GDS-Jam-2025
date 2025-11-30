extends Control

const HEAD_1 = preload("uid://cvgl2r36o4ouv")
const HEAD_2 = preload("uid://d4iktmothva75")
const HEAD_3 = preload("uid://b7fh3upa4leob")
const HEAD_4 = preload("uid://c1y0dkkyjruig")

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

var is_hidden : bool = true
var current_baldness := 0

## How long until first perk stops spinning
@export_range(3, 120, 3) var spin_length: int = 12

@onready var icon_spinner_1: IconSpinner = %IconSpinner1
@onready var icon_spinner_2: IconSpinner = %IconSpinner2
@onready var icon_spinner_3: IconSpinner = %IconSpinner3
@onready var head: TextureRect = %Head

func _ready() -> void:
	hide()
	
func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack"):
		#AudioManager.play_music(load("res://sound/levels/music_bg.wav"))
		#AudioManager.fade_in_music()
		
		#Player.money += 100
		#GUI.update_money(Player.money)
	
	if event.is_action_pressed("debug"):
		if is_hidden:
			show()
		else:
			hide()
		is_hidden = !is_hidden

func spin_machine():
	icon_spinner_1.cycles = spin_length
	icon_spinner_1.spin()
	icon_spinner_2.cycles = spin_length + 6
	icon_spinner_2.spin()
	icon_spinner_3.cycles = spin_length + 12
	icon_spinner_3.spin()

func get_final_perk() -> Perk:
	return all_perks.pick_random()

func change_head() -> void:
	match(current_baldness):
		0:
			head.texture = HEAD_1
		1: 
			head.texture = HEAD_2
		2: 
			head.texture = HEAD_3
		3: 
			head.texture = HEAD_4
		_: 
			head.texture = HEAD_4

func on_balding(new_baldness: int) -> void:
	current_baldness = new_baldness
	change_head()
