extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var scissors: TurkItem = $Him/Scissors
@onready var exit: TurkItem = $Him/Exit
@onready var hair: TurkItem = $Him/Hair

const POPUP_UI_MUSIC = preload("uid://b37mocg28w6xw")

func _ready() -> void:
	AudioManager.fade_out_music()
	AudioManager.play_music(POPUP_UI_MUSIC)
	AudioManager.fade_in_music()
	
	scissors.modulate.a = 0.0
	exit.modulate.a = 0.0
	hair.modulate.a = 0.0

	animation_player.play("intro")
	await animation_player.animation_finished

	var tween := create_tween()
	tween.tween_property(scissors, "modulate:a", 1.0, 0.5) 
	tween.tween_property(exit, "modulate:a", 1.0, 0.5) 
	tween.tween_property(hair, "modulate:a", 1.0, 0.5) 

func bald_sfx():
	AudioManager.play_sfx(load("res://sound/turkish_lvl/popup_ui/THE_BALD.wav"), -5.0)
	pass
