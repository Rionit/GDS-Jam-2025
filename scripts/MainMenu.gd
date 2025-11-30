extends Control

@onready var highlight: TextureRect = %Highlight

@onready var quit_gambling: TextureRect = $BG/QuitGambling
@onready var settings: TextureRect = $BG/Settings
@onready var continue_gambling: TextureRect = $BG/ContinueGambling

@export var positions : Array[Marker2D]

var menu_idx := 0


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("up"):
		menu_idx -= 1
		if menu_idx < 0:
			menu_idx = 3
		print(menu_idx)
	if event.is_action_pressed("down"):
		menu_idx += 1
		if menu_idx > 3:
			menu_idx = 0
		print(menu_idx)
	
	if event.is_action_pressed("attack"):
		match menu_idx:
			1:
				pass
				# TODO: play game
			2:
				pass
				# TODO: settings
			3:
				pass
				# TODO: exit game
			_:
				pass
	
	highlight.global_position = positions[menu_idx].global_position
