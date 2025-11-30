extends Control

@onready var money_label: Label = %MoneyLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hider: Control = $Hider
@onready var sanity_label: Label = $Hider/MarginContainer/HBoxContainer2/SanityLabel

var current_value: int = 0
var tween: Tween

func update_money(target_value: int) -> void:
	if tween and tween.is_valid():
		tween.kill()  # stop previous tween if still running

	tween = create_tween()
	tween.tween_method(_update_money_text, current_value, target_value, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	current_value = target_value

func update_sanity(target_value: float) -> void:
	sanity_label.text = "Sanity: " + str(target_value)

func _update_money_text(value: float) -> void:
	money_label.text = str(int(value))

func fade_in():
	animation_player.play("fade_in")
	await animation_player.animation_finished

func fade_out():
	animation_player.play_backwards("fade_in")
	await animation_player.animation_finished
