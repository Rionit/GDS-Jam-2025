extends TextureRect
class_name TurkItem

signal selected_choice(choice: Choice)

enum Choice { SCISSORS, EXIT, HAIR }

@export var choice: Choice

@onready var highlight: TextureRect = $Highlight

var mouse_in := false

func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	highlight.modulate.a = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and mouse_in:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
		tween.tween_property(self, "scale", Vector2.ONE, 0.2)
		await tween.finished
		selected_choice.emit(choice)
		AudioManager.play_sfx(load("res://sound/UI_sounds/click.wav"))
		print("selected " + str(choice))

func on_mouse_entered():
	AudioManager.play_sfx(load("res://sound/UI_sounds/hovering.wav"))
	mouse_in = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(highlight, "modulate:a", 1.0, 0.3)
	tween.tween_property(highlight, "scale", Vector2(.9, .9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
	
func on_mouse_exited():
	mouse_in = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.3)
	tween.tween_property(highlight, "scale", Vector2.ONE, 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
