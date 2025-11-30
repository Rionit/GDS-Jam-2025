extends Control

@onready var money_label: Label = $MarginContainer/HBoxContainer/Label

var current_value: int = 0
var tween: Tween

func update_money(target_value: int) -> void:
	if tween and tween.is_valid():
		tween.kill()  # stop previous tween if still running

	tween = create_tween()
	tween.tween_method(_update_money_text, current_value, target_value, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	current_value = target_value

func _update_money_text(value: float) -> void:
	money_label.text = str(int(value))
