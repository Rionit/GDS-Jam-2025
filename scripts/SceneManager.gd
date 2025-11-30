extends Node2D

const SLOT_MACHINE_ROOM = preload("uid://bw2tnuih4o3ux")

func transition_to_scene(path: PackedScene) -> void:
	await GUI.fade_in()            
	get_tree().change_scene_to_packed(path)
	await GUI.fade_out()

func next_level():
	pass
	# TODO: linear list of levels
	# get_level() 
	#transition_to_scene(level)
	activate_perk_machine()
	# wait
	# deactivate_perk_machine(), or do it from perkmachine
	

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack"):
		#transition_to_scene(SLOT_MACHINE_ROOM)
	
	if event.is_action_pressed("debug"):
		activate_perk_machine()

func activate_perk_machine():
	PerkMachine.show()
	PerkMachine.is_hidden = false
	
func deactivate_perk_machine():
	PerkMachine.hide()
	PerkMachine.is_hidden = true
		
