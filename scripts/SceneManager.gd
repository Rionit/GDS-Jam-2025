extends Node2D

const CRANE_ROOM = preload("uid://crx4aobrhhwq7")
const POKER_ROOM = preload("uid://bxvxx4ayrkyom")
const ROULETTE_ROOM = preload("uid://dvig0owve3xky")
const SLOT_MACHINE_ROOM = preload("uid://bw2tnuih4o3ux")
const TURKISH_ROOM = preload("uid://dydhxfa76s740")
const MAIN_MENU = preload("uid://b5gqinx15qlw0")
const TURKISH_GUY = preload("uid://phejuxsn6sro")

var levels : Array[PackedScene] = [
	SLOT_MACHINE_ROOM,
	POKER_ROOM,
	CRANE_ROOM,
	#ROULETTE_ROOM,
	TURKISH_ROOM,
	TURKISH_GUY,
	MAIN_MENU
]

var current_level := 0

func transition_to_scene(path: PackedScene) -> void:
	await GUI.fade_in()            
	get_tree().change_scene_to_packed(path)
	await GUI.fade_out()

func next_level():
	# TODO: linear list of levels
	if current_level >= levels.size():
		current_level = 0
	
	Player.position = Vector2(180, 620)
	
	await transition_to_scene(levels[current_level])
	if levels[current_level] != TURKISH_ROOM and levels[current_level] != TURKISH_GUY:
		activate_perk_machine()
	else:
		GUI.hider.hide()
	
	current_level += 1

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack"):
		#transition_to_scene(SLOT_MACHINE_ROOM)
	
	if event.is_action_pressed("debug"):
		activate_perk_machine()

func activate_perk_machine():
	GUI.hider.hide()
	PerkMachine.show()
	PerkMachine.roll_button_cost.text = "COSTS 0 "
	
	await get_tree().create_timer(2.0).timeout
	PerkMachine.is_hidden = false
	
func deactivate_perk_machine():
	GUI.hider.show()
	PerkMachine.currentNumRolls = 0
	PerkMachine.currentPrice = 0
	PerkMachine.current_perk_modifier = 1
	
	PerkMachine.hide()
	PerkMachine.is_hidden = true
	
	get_tree().current_scene.start_level()
