extends Control

@onready var highlight: TextureRect = %Highlight

@onready var quit_gambling: TextureRect = $BG/QuitGambling
@onready var settings: TextureRect = $BG/Settings
@onready var continue_gambling: TextureRect = $BG/ContinueGambling

@export var positions : Array[Marker2D]

var menu_idx := 0

func _ready() -> void:
	AudioManager.play_music(load("res://sound/levels/music_bg.wav"))
	AudioManager.fade_in_music()
	animate()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("up"):
		
		menu_idx -= 1
		if menu_idx < 0:
			menu_idx = 3
		animate()
		print(menu_idx)
	if event.is_action_pressed("down"):
		menu_idx += 1
		if menu_idx > 3:
			menu_idx = 0
		animate()
		print(menu_idx)
	
	if event.is_action_pressed("attack"):
		AudioManager.play_sfx(load("res://sound/UI_sounds/click.wav"))
		match menu_idx:
			1:
				SceneManager.next_level()
			2:
				pass
				# TODO: settings
			3:
				get_tree().quit()
			_:
				pass
	

func animate():
	AudioManager.play_sfx(load("res://sound/UI_sounds/hovering.wav"), -2.0)
	highlight.modulate.a = 0.0
	highlight.global_position = positions[menu_idx].global_position
	var tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.2)
	
