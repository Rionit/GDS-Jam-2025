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
const D_ENEMY_COOLDOWN = preload("uid://cevxevox1wawp")
const D_ENEMY_HEALTH : Perk = preload("uid://dqnm8i764sdfh")
const D_ENEMY_MOVEMENT : Perk = preload("uid://bsuxm83bqseb")
const D_PLAYER_COOLDOWN : Perk = preload("uid://ccyf8t218mlh4")
const D_PLAYER_MOVEMENT : Perk = preload("uid://dy27shbo06qf3")

const BUFFS = [ B_ENEMY_COOLDOWN,  B_ENEMY_HEALTH, B_ENEMY_MOVEMENT, B_PLAYER_COOLDOWN, B_PLAYER_MOVEMENT ]
const DEBUFFS = [ D_ENEMY_COOLDOWN,  D_ENEMY_HEALTH, D_ENEMY_MOVEMENT, D_PLAYER_COOLDOWN, D_PLAYER_MOVEMENT ]
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

const SOUND_BG = preload("uid://bxyy0ae8omrax")

var currentNumRolls = 0

var current_perk_modifier = 1

var is_hidden : bool = true
var current_baldness := 0

var base_buff_chance = 35
var baldness_chance_increase = 15

var perks : Array[Perk] = []
var currentPrice = 0

var spinning_columns = 0


## How long until first perk stops spinning
@export_range(3, 120, 3) var spin_length: int = 12

@export var roll_again_button : Button
@export var play_button : Button
@export var roll_button_cost : Label

@onready var icon_spinner_1: IconSpinner = %IconSpinner1
@onready var icon_spinner_2: IconSpinner = %IconSpinner2
@onready var icon_spinner_3: IconSpinner = %IconSpinner3
@onready var head: TextureRect = %Head

func _ready() -> void:
	
	hide()
	play_button.pressed.connect(SceneManager.deactivate_perk_machine)
	roll_again_button.pressed.connect(spin_machine)
	
	icon_spinner_1.on_spinned.connect(stop_spinning_callback)
	icon_spinner_2.on_spinned.connect(stop_spinning_callback)
	icon_spinner_3.on_spinned.connect(stop_spinning_callback)

func fade_in_buttons():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(play_button, "position:y", 32.0, 1.5)
	tween.parallel().tween_proprerty(play_button, "modulate:a", 1.0, 1.5)
	tween.parallel().tween_property(roll_again_button, "position:y", 35.0, 1.5)
	tween.parallel().tween_proprerty(roll_again_button, "modulate:a", 1.0, 1.5)
	

func _unhandled_input(event: InputEvent) -> void:
	if is_hidden:
		return
	
	if spinning_columns == 0:
		if event.is_action_pressed("attack"):
			#AudioManager.play_music(load("res://sound/levels/music_bg.wav"))
			#AudioManager.fade_in_music()
			spin_machine()
			#Player.money += 100
			#GUI.update_money(Player.money)
		elif event.is_action_pressed("dash"):
			SceneManager.deactivate_perk_machine()
			

func stop_spinning_callback():
	spinning_columns -= 1
	if spinning_columns == 0:
		play_button.show()
		if Player.has_money(currentPrice):
			roll_again_button.show()
			roll_button_cost.text = "COSTS " + str(currentPrice) + " "

func return_perk(type : Perk.PerkEnum) -> Array[Perk]:
	var to_return = []
	for perk in perks:
		if perk.type == type:
			to_return.append(perk)
			
	return to_return

func spin_machine():
	play_button.hide()
	roll_again_button.hide()
	if currentNumRolls == 0:
		currentPrice += 100
	else:
		currentPrice *= 2
		current_perk_modifier *= 2

	currentNumRolls += 1
	perks = []
	for i in range(3):
		perks.append(get_final_perk())
	
	icon_spinner_1.final_perk = perks[0]
	AudioManager.play_sfx(load("res://sound/perk_machine/coins_spin.wav"))
	icon_spinner_1.cycles = spin_length
	icon_spinner_1.spin()
	icon_spinner_1.value_multiplier = current_perk_modifier
	
	icon_spinner_2.final_perk = perks[1]
	icon_spinner_2.cycles = spin_length + 6
	icon_spinner_2.spin()
	icon_spinner_2.value_multiplier = current_perk_modifier
	
	icon_spinner_3.final_perk = perks[2]
	icon_spinner_3.cycles = spin_length + 12
	icon_spinner_3.spin()
	icon_spinner_3.value_multiplier = current_perk_modifier
	
	spinning_columns = 3	

func get_final_perk() -> Perk:
	var random = randi() % 100 + 1
	
	var i = randi() % BUFFS.size()
	if random <= base_buff_chance + current_baldness * baldness_chance_increase:
		return BUFFS[i]
	else:
		return DEBUFFS[i]

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
