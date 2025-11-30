extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var scissors: TurkItem = $Him/Scissors
@onready var exit: TurkItem = $Him/Exit
@onready var hair: TurkItem = $Him/Hair

func _ready() -> void:
	scissors.modulate.a = 0.0
	exit.modulate.a = 0.0
	hair.modulate.a = 0.0

	animation_player.play("intro")
	await animation_player.animation_finished

	var tween := create_tween()
	tween.tween_property(scissors, "modulate:a", 1.0, 0.5) 
	tween.tween_property(exit, "modulate:a", 1.0, 0.5) 
	tween.tween_property(hair, "modulate:a", 1.0, 0.5) 
